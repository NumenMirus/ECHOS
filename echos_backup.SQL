--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4 (Debian 14.4-1.pgdg110+1)
-- Dumped by pg_dump version 14.4 (Debian 14.4-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_double_song(); Type: FUNCTION; Schema: public; Owner: echos
--

CREATE FUNCTION public.check_double_song() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN

        if exists(select * from playlist_canzoni where id_canzone = new.id_canzone and id_playlist = new.id_playlist) then
            return null;
        end if;
        return new;
    end;
    $$;


ALTER FUNCTION public.check_double_song() OWNER TO echos;

--
-- Name: check_equals_name_playlist(); Type: FUNCTION; Schema: public; Owner: echos
--

CREATE FUNCTION public.check_equals_name_playlist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF NEW.titolo in (select titolo from playlist where id_utente=NEW.id_utente) THEN
        return NULL;
    END IF;
    RETURN NEW;
END;$$;


ALTER FUNCTION public.check_equals_name_playlist() OWNER TO echos;

--
-- Name: check_riproduzione(); Type: FUNCTION; Schema: public; Owner: echos
--

CREATE FUNCTION public.check_riproduzione() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN

        if exists(select * from utenti_ascolti where id_utente = new.id_utente and id_canzone = new.id_canzone) then
            update utenti_ascolti set n_ascolti = n_ascolti +1 where id_utente = new.id_utente and id_canzone = new.id_canzone;
            return null;
        end if;
        return new;

    end;
    $$;


ALTER FUNCTION public.check_riproduzione() OWNER TO echos;

--
-- Name: delete_song(); Type: FUNCTION; Schema: public; Owner: echos
--

CREATE FUNCTION public.delete_song() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN

        delete from album_canzoni where id_canzone = new.id;
        delete from canzoni where id = new.id;
        delete from playlist_canzoni where id_canzone = new.id;

    end;
    $$;


ALTER FUNCTION public.delete_song() OWNER TO echos;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: album; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.album (
    id_album integer NOT NULL,
    id_artista integer NOT NULL,
    singolo boolean DEFAULT false NOT NULL,
    scadenza date,
    restricted boolean DEFAULT false NOT NULL,
    anno date NOT NULL,
    titolo character varying(100) DEFAULT '0'::character varying NOT NULL
);


ALTER TABLE public.album OWNER TO echos;

--
-- Name: album_canzoni; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.album_canzoni (
    id_album integer NOT NULL,
    id_canzone integer NOT NULL
);


ALTER TABLE public.album_canzoni OWNER TO echos;

--
-- Name: album_artisti_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.album_artisti_view AS
 SELECT album.id_album,
    album.id_artista,
    album.singolo,
    album.titolo,
        CASE
            WHEN (EXISTS ( SELECT album_canzoni.id_album,
                album_canzoni.id_canzone
               FROM public.album_canzoni
              WHERE (album_canzoni.id_album = album.id_album))) THEN false
            ELSE true
        END AS vuoto
   FROM public.album;


ALTER TABLE public.album_artisti_view OWNER TO echos;

--
-- Name: canzoni; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.canzoni (
    id integer NOT NULL,
    id_artista integer NOT NULL,
    durata integer NOT NULL,
    id_genere integer,
    file bytea,
    riservato boolean DEFAULT false NOT NULL,
    data_inserimento date,
    extension character varying(10),
    titolo character varying(100),
    scadenza date,
    data_uscita date NOT NULL,
    n_riproduzioni integer DEFAULT 0
);
ALTER TABLE ONLY public.canzoni ALTER COLUMN n_riproduzioni SET STATISTICS 0;


ALTER TABLE public.canzoni OWNER TO echos;

--
-- Name: album_canzoni_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.album_canzoni_view AS
 SELECT album.id_album,
    album.titolo AS titolo_album,
    c.titolo AS titolo_canzone,
    c.id AS id_canzone
   FROM ((public.album
     JOIN public.album_canzoni ac ON ((album.id_album = ac.id_album)))
     JOIN public.canzoni c ON ((ac.id_canzone = c.id)));


ALTER TABLE public.album_canzoni_view OWNER TO echos;

--
-- Name: album_id_album_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.album_id_album_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.album_id_album_seq OWNER TO echos;

--
-- Name: album_id_album_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.album_id_album_seq OWNED BY public.album.id_album;


--
-- Name: artisti; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.artisti (
    nome_arte character varying(100) NOT NULL,
    id_artista integer NOT NULL,
    data_iscrizione date NOT NULL,
    id_utente integer NOT NULL
);


ALTER TABLE public.artisti OWNER TO echos;

--
-- Name: artisti_id_artista_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.artisti_id_artista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.artisti_id_artista_seq OWNER TO echos;

--
-- Name: artisti_id_artista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.artisti_id_artista_seq OWNED BY public.artisti.id_artista;


--
-- Name: canzoni_id_artista_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.canzoni_id_artista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.canzoni_id_artista_seq OWNER TO echos;

--
-- Name: canzoni_id_artista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.canzoni_id_artista_seq OWNED BY public.canzoni.id_artista;


--
-- Name: canzoni_id_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.canzoni_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.canzoni_id_seq OWNER TO echos;

--
-- Name: canzoni_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.canzoni_id_seq OWNED BY public.canzoni.id;


--
-- Name: generi_musicali; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.generi_musicali (
    id_genere integer NOT NULL,
    descrizione character varying(255),
    nome character varying(50) NOT NULL
);


ALTER TABLE public.generi_musicali OWNER TO echos;

--
-- Name: canzoni_per_riproduzioni_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.canzoni_per_riproduzioni_view AS
 SELECT canzoni.titolo,
    canzoni.id,
    gm.nome AS nome_genere,
    canzoni.n_riproduzioni,
    canzoni.data_uscita,
    a.nome_arte
   FROM ((public.canzoni
     JOIN public.artisti a ON ((a.id_artista = canzoni.id_artista)))
     JOIN public.generi_musicali gm ON ((gm.id_genere = canzoni.id_genere)))
  ORDER BY canzoni.n_riproduzioni DESC;


ALTER TABLE public.canzoni_per_riproduzioni_view OWNER TO echos;

--
-- Name: canzoni_popolari_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.canzoni_popolari_view AS
 SELECT canzoni.titolo,
    canzoni.id,
    gm.nome AS nome_genere,
    canzoni.n_riproduzioni,
    canzoni.data_uscita,
    a.nome_arte
   FROM ((public.canzoni
     JOIN public.artisti a ON ((a.id_artista = canzoni.id_artista)))
     JOIN public.generi_musicali gm ON ((gm.id_genere = canzoni.id_genere)))
  ORDER BY canzoni.n_riproduzioni DESC
 LIMIT 10;


ALTER TABLE public.canzoni_popolari_view OWNER TO echos;

--
-- Name: canzoni_recenti_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.canzoni_recenti_view AS
 SELECT canzoni.titolo,
    canzoni.id,
    gm.nome AS nome_genere,
    canzoni.data_inserimento,
    canzoni.data_uscita,
    a.nome_arte
   FROM ((public.canzoni
     JOIN public.artisti a ON ((a.id_artista = canzoni.id_artista)))
     JOIN public.generi_musicali gm ON ((gm.id_genere = canzoni.id_genere)))
  ORDER BY canzoni.data_inserimento DESC
 LIMIT 10;


ALTER TABLE public.canzoni_recenti_view OWNER TO echos;

--
-- Name: generi_musicali_id_genere_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.generi_musicali_id_genere_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.generi_musicali_id_genere_seq OWNER TO echos;

--
-- Name: generi_musicali_id_genere_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.generi_musicali_id_genere_seq OWNED BY public.generi_musicali.id_genere;


--
-- Name: n_riproduzioni_album_canzoni_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.n_riproduzioni_album_canzoni_view AS
 SELECT album.id_artista,
    album.id_album,
    album_canzoni.id_canzone,
    album.titolo AS titolo_album,
    canzoni.titolo AS titolo_canzone,
    canzoni.n_riproduzioni
   FROM ((public.album
     LEFT JOIN public.album_canzoni USING (id_album))
     LEFT JOIN public.canzoni ON ((canzoni.id = album_canzoni.id_canzone)));


ALTER TABLE public.n_riproduzioni_album_canzoni_view OWNER TO echos;

--
-- Name: playlist; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.playlist (
    id_playlist integer NOT NULL,
    id_utente integer NOT NULL,
    restricted boolean DEFAULT false NOT NULL,
    titolo character varying(100) NOT NULL
);


ALTER TABLE public.playlist OWNER TO echos;

--
-- Name: playlist_canzoni; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.playlist_canzoni (
    id_playlist integer NOT NULL,
    id_canzone integer NOT NULL
);


ALTER TABLE public.playlist_canzoni OWNER TO echos;

--
-- Name: playlist_canzoni_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.playlist_canzoni_view AS
 SELECT playlist.id_playlist,
    canzoni.id AS id_canzone,
    playlist.titolo AS titolo_playlist,
    canzoni.titolo AS titolo_canzone,
    playlist.restricted,
    playlist.id_utente
   FROM ((public.playlist
     LEFT JOIN public.playlist_canzoni USING (id_playlist))
     LEFT JOIN public.canzoni ON ((canzoni.id = playlist_canzoni.id_canzone)));


ALTER TABLE public.playlist_canzoni_view OWNER TO echos;

--
-- Name: playlist_id_playlist_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.playlist_id_playlist_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.playlist_id_playlist_seq OWNER TO echos;

--
-- Name: playlist_id_playlist_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.playlist_id_playlist_seq OWNED BY public.playlist.id_playlist;


--
-- Name: richieste_diventa_artista; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.richieste_diventa_artista (
    nome_arte character varying(100) NOT NULL,
    motivazione character varying(255) NOT NULL,
    stato_richiesta smallint DEFAULT '0'::smallint NOT NULL,
    id_utente integer NOT NULL
);


ALTER TABLE public.richieste_diventa_artista OWNER TO echos;

--
-- Name: richieste_diventa_artista_id_utente_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.richieste_diventa_artista_id_utente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.richieste_diventa_artista_id_utente_seq OWNER TO echos;

--
-- Name: richieste_diventa_artista_id_utente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.richieste_diventa_artista_id_utente_seq OWNED BY public.richieste_diventa_artista.id_utente;


--
-- Name: utenti_ascolti; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.utenti_ascolti (
    id_utente integer NOT NULL,
    id_canzone integer NOT NULL,
    n_ascolti integer
);


ALTER TABLE public.utenti_ascolti OWNER TO echos;

--
-- Name: statistiche_utente_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.statistiche_utente_view AS
 SELECT u.id_utente,
    u.id_canzone,
    c.titolo AS titolo_canzone,
    c.id_artista,
    c.id_genere,
    u.n_ascolti,
    gm.nome AS nome_genere,
    a.nome_arte
   FROM (((public.utenti_ascolti u
     JOIN public.canzoni c ON ((u.id_canzone = c.id)))
     JOIN public.generi_musicali gm ON ((c.id_genere = gm.id_genere)))
     JOIN public.artisti a ON ((c.id_artista = a.id_artista)));


ALTER TABLE public.statistiche_utente_view OWNER TO echos;

--
-- Name: top_cinque_generi_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.top_cinque_generi_view AS
 SELECT gm.nome AS nome_genere,
    count(gm.nome) AS n_riproduzioni
   FROM (((public.utenti_ascolti u
     JOIN public.canzoni c ON ((u.id_canzone = c.id)))
     JOIN public.generi_musicali gm ON ((c.id_genere = gm.id_genere)))
     JOIN public.artisti a ON ((c.id_artista = a.id_artista)))
  GROUP BY gm.nome
  ORDER BY (count(gm.nome)) DESC
 LIMIT 5;


ALTER TABLE public.top_cinque_generi_view OWNER TO echos;

--
-- Name: top_five_artists_view; Type: VIEW; Schema: public; Owner: echos
--

CREATE VIEW public.top_five_artists_view AS
 SELECT top.id_artista,
    top.fama,
    top.nome_arte
   FROM ( SELECT temp.id_artista,
            art.nome_arte,
            (COALESCE(temp.ascolti) / COALESCE(temp.n_canzoni)) AS fama
           FROM (( SELECT a.id_artista,
                    b.ascolti,
                    a.n_canzoni
                   FROM (( SELECT canzoni.id_artista,
                            count(canzoni.id_artista) AS n_canzoni
                           FROM public.canzoni
                          GROUP BY canzoni.id_artista
                          ORDER BY (count(canzoni.id_artista)) DESC) a
                     JOIN ( SELECT canzoni.id_artista,
                            sum(canzoni.n_riproduzioni) AS ascolti
                           FROM public.canzoni
                          GROUP BY canzoni.id_artista) b ON ((a.id_artista = b.id_artista)))) temp
             JOIN public.artisti art ON ((art.id_artista = temp.id_artista)))) top
  ORDER BY top.fama DESC
 LIMIT 5;


ALTER TABLE public.top_five_artists_view OWNER TO echos;

--
-- Name: utenti; Type: TABLE; Schema: public; Owner: echos
--

CREATE TABLE public.utenti (
    nome character varying(30) NOT NULL,
    cognome character varying(30) NOT NULL,
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    mail character varying(100) NOT NULL,
    id_artista integer,
    premium boolean DEFAULT false NOT NULL,
    psw character varying NOT NULL,
    data_di_nascita date
);


ALTER TABLE public.utenti OWNER TO echos;

--
-- Name: utenti_id_seq; Type: SEQUENCE; Schema: public; Owner: echos
--

CREATE SEQUENCE public.utenti_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.utenti_id_seq OWNER TO echos;

--
-- Name: utenti_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: echos
--

ALTER SEQUENCE public.utenti_id_seq OWNED BY public.utenti.id;


--
-- Name: album id_album; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.album ALTER COLUMN id_album SET DEFAULT nextval('public.album_id_album_seq'::regclass);


--
-- Name: artisti id_artista; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.artisti ALTER COLUMN id_artista SET DEFAULT nextval('public.artisti_id_artista_seq'::regclass);


--
-- Name: canzoni id; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.canzoni ALTER COLUMN id SET DEFAULT nextval('public.canzoni_id_seq'::regclass);


--
-- Name: canzoni id_artista; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.canzoni ALTER COLUMN id_artista SET DEFAULT nextval('public.canzoni_id_artista_seq'::regclass);


--
-- Name: generi_musicali id_genere; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.generi_musicali ALTER COLUMN id_genere SET DEFAULT nextval('public.generi_musicali_id_genere_seq'::regclass);


--
-- Name: playlist id_playlist; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.playlist ALTER COLUMN id_playlist SET DEFAULT nextval('public.playlist_id_playlist_seq'::regclass);


--
-- Name: richieste_diventa_artista id_utente; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.richieste_diventa_artista ALTER COLUMN id_utente SET DEFAULT nextval('public.richieste_diventa_artista_id_utente_seq'::regclass);


--
-- Name: utenti id; Type: DEFAULT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti ALTER COLUMN id SET DEFAULT nextval('public.utenti_id_seq'::regclass);


--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.album (id_album, id_artista, singolo, scadenza, restricted, anno, titolo) FROM stdin;
22	2	f	2022-04-27	f	2022-05-28	album1
23	3	f	\N	f	2022-05-02	Album1
24	2	f	\N	f	2022-05-22	Album2
26	2	f	2022-06-11	t	2022-05-20	Riservato1
30	40814	t	\N	f	2022-04-13	30
32	40814	f	2022-05-16	f	2022-05-02	lode
34	40819	f	\N	f	2022-02-01	stazione1
38	40821	f	\N	f	2022-05-10	werty
\.


--
-- Data for Name: album_canzoni; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.album_canzoni (id_album, id_canzone) FROM stdin;
23	116766
23	116767
22	116769
22	116770
30	116792
34	116794
38	116802
\.


--
-- Data for Name: artisti; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.artisti (nome_arte, id_artista, data_iscrizione, id_utente) FROM stdin;
SuperMarioOneBrother	2	2022-05-04	2
Anto	3	2022-05-06	4
Novy vs. Eniac	14846	2022-05-12	0
Ghymes	14847	2022-05-12	0
Lokua Kanza	14848	2022-05-12	0
Xploding Plastix	14849	2022-05-12	0
Tocotronic	14850	2022-05-12	0
The Swinging Blue Jeans	14851	2022-05-12	0
John Anderson	14852	2022-05-12	0
The Young Rascals	14853	2022-05-12	0
Bert Kaempfert And His Orchestra	14854	2022-05-12	0
Nita Whitaker	14855	2022-05-12	0
Glamma Kid	14856	2022-05-12	0
Yvonne De Carlo	14857	2022-05-12	0
Inti Illimani	14858	2022-05-12	0
Deeds Of Flesh	14859	2022-05-12	0
Kitty Wells	14860	2022-05-12	0
Columbia Symphony Orchestra;Igor Stravinsky	14861	2022-05-12	0
Mariachi Arriba Juarez	14862	2022-05-12	0
Ronny Eriksson	14863	2022-05-12	0
Throwing Muses	14864	2022-05-12	0
Still Standing	14865	2022-05-12	0
Max Morath	14866	2022-05-12	0
Afrika Bambaataa	14867	2022-05-12	0
Dublin City Ramblers	14868	2022-05-12	0
Xi	14869	2022-05-12	0
Death Cab for Cutie	14870	2022-05-12	0
John Fogerty	14871	2022-05-12	0
Simon Dupree & The Big Sound	14872	2022-05-12	0
August Burns Red	14873	2022-05-12	0
autoKratz	14874	2022-05-12	0
Valet	14875	2022-05-12	0
Mubali	14876	2022-05-12	0
Arthur Bliss	14877	2022-05-12	0
Gwen Guthrie	14878	2022-05-12	0
Fabulous Furniture / Martin Mull	14879	2022-05-12	0
Gemma Fox	14880	2022-05-12	0
O Rappa	14881	2022-05-12	0
Gato Barbieri	14882	2022-05-12	0
Still Remains	14883	2022-05-12	0
Blood Red	14884	2022-05-12	0
Guardian	14885	2022-05-12	0
John Hooker	14886	2022-05-12	0
Beggars Opera	14887	2022-05-12	0
Yael Naïm	14888	2022-05-12	0
The Geraldine Fibbers	14889	2022-05-12	0
Deacon Blue	14890	2022-05-12	0
Phantom Ghost	14891	2022-05-12	0
Lida Husik	14892	2022-05-12	0
Rapid Ric	14893	2022-05-12	0
Ferlin Husky & Jean Shepard	14894	2022-05-12	0
Jogger	14895	2022-05-12	0
Rainbirds	14896	2022-05-12	0
Huey Dunbar	14897	2022-05-12	0
Doug MacLeod	14898	2022-05-12	0
Silje Nergaard	14899	2022-05-12	0
Passenger 10	14900	2022-05-12	0
Terry Riley	14901	2022-05-12	0
Kari Tapio	14902	2022-05-12	0
Sick Puppies	14903	2022-05-12	0
Eisbrecher	14904	2022-05-12	0
Billy Dean	14905	2022-05-12	0
Zeltingerband	14906	2022-05-12	0
Tilopa	14907	2022-05-12	0
Demi Lovato	14908	2022-05-12	0
J'ai toujours rêvé d'être un gangster	14909	2022-05-12	0
Toto	14910	2022-05-12	0
Sipho Mabuse	14911	2022-05-12	0
The Raunch Hands Bigg Topp	14912	2022-05-12	0
Milton Nascimento	14913	2022-05-12	0
Entre Ríos	14914	2022-05-12	0
2-Illeven	14915	2022-05-12	0
Farida Khanum	14916	2022-05-12	0
Lord Kossity	14917	2022-05-12	0
Full Blown Cherry	14918	2022-05-12	0
Fred Simon	14919	2022-05-12	0
Southern Culture On The Skids	14920	2022-05-12	0
Saturday Looks Good To Me	14921	2022-05-12	0
Stan Mosley	14922	2022-05-12	0
Roger Clyne	14923	2022-05-12	0
Mothers Pride	14924	2022-05-12	0
St. Martin's Orchestra	14925	2022-05-12	0
The Beatnuts Featuring Al Tariq	14926	2022-05-12	0
Chris Thile	14927	2022-05-12	0
National Pops Orchestra	14928	2022-05-12	0
Amaswazi Emvelo	14929	2022-05-12	0
Mick Est Tout Seul	14930	2022-05-12	0
DJ Devious	14931	2022-05-12	0
The Arrogant Sons Of Bitches	14932	2022-05-12	0
The Dolly Rocker Movement	14933	2022-05-12	0
The Rippingtons / Brandon Fields	14934	2022-05-12	0
Wishkey	14935	2022-05-12	0
AL-PHA-X	14936	2022-05-12	0
I HEART HUCKABEES	14937	2022-05-12	0
Andy Palacio & the Garifuna Collective	14938	2022-05-12	0
Dick Dale	14939	2022-05-12	0
Keep Of Kalessin	14940	2022-05-12	0
Reach The Sky	14941	2022-05-12	0
Pablo Fetti	14942	2022-05-12	0
Banana Slug String Band	14943	2022-05-12	0
Fulgeance	14944	2022-05-12	0
Dolor	14945	2022-05-12	0
Aesop Rock	14946	2022-05-12	0
Mike Badger	14947	2022-05-12	0
The Out Crowd	14948	2022-05-12	0
Deadsoil	14949	2022-05-12	0
Moving Cloud	14950	2022-05-12	0
David Cook	14951	2022-05-12	0
Gene McDaniels	14952	2022-05-12	0
Puppetshow	14953	2022-05-12	0
VERNON REID & MASQUE	14954	2022-05-12	0
Cheryl Lynn	14955	2022-05-12	0
Dive Vs. Diskonnekted	14956	2022-05-12	0
Sudhanshu	14957	2022-05-12	0
Joan Armatrading	14958	2022-05-12	0
Chango Spasiuk	14959	2022-05-12	0
Mike Foyle vs. Signalrunners	14960	2022-05-12	0
A.P.E	14961	2022-05-12	0
Dave Brockie Experience	14962	2022-05-12	0
Unknown Instructors	14963	2022-05-12	0
John Popper	14964	2022-05-12	0
The Ataris	14965	2022-05-12	0
Root	14966	2022-05-12	0
The Wonder Years	14967	2022-05-12	0
Ellen McIlwaine	14968	2022-05-12	0
I Against I	14969	2022-05-12	0
Andomat 3000 & Jan	14970	2022-05-12	0
The Crazy World Of Arthur Brown	14971	2022-05-12	0
Jude Taylor & His Burning Flames	14972	2022-05-12	0
Sort Sol	14973	2022-05-12	0
Mario Aureo	14974	2022-05-12	0
Grady Tate	14975	2022-05-12	0
Gregory Miller	14976	2022-05-12	0
Rui Da Silva	14977	2022-05-12	0
Iomos Marad	14978	2022-05-12	0
Monique Marvez	14979	2022-05-12	0
Excalion	14980	2022-05-12	0
S.Y.P.H.	14981	2022-05-12	0
Tic Tac Toe	14982	2022-05-12	0
Foghorn Stringband	14983	2022-05-12	0
Drumsound And Simon 'Bassline' Smith	14984	2022-05-12	0
Magnus Carlsson	14985	2022-05-12	0
Barclay James Harvest	14986	2022-05-12	0
*Shels	14987	2022-05-12	0
Blu Cantrell	14988	2022-05-12	0
Carlos Chaouen	14989	2022-05-12	0
Pseudo Echo	14990	2022-05-12	0
Fred Astaire and Ginger Rogers	14991	2022-05-12	0
The Sun Harbor's Chorus-Documentary Recordings	14992	2022-05-12	0
Lionel Hampton	14993	2022-05-12	0
Statik Selektah	14994	2022-05-12	0
Soul Central feat. Abigail Bailey	14995	2022-05-12	0
Joe Satriani	14996	2022-05-12	0
Rockwell	14997	2022-05-12	0
Nils Landgren & Johan Norberg	14998	2022-05-12	0
At War With Self	14999	2022-05-12	0
Chico Buarque	15000	2022-05-12	0
Stick McGhee	15001	2022-05-12	0
Thinking Fellers Union Local 282	15002	2022-05-12	0
Ananda Shankar	15003	2022-05-12	0
Formacja Niezywych Schabuff	15004	2022-05-12	0
Dottie Peoples	15005	2022-05-12	0
Danity Kane	15006	2022-05-12	0
Oh Well	15007	2022-05-12	0
Muddy Waters / Son Simms Four	15008	2022-05-12	0
Freddie King	15009	2022-05-12	0
Parliament	15010	2022-05-12	0
9 Shocks Terror	15011	2022-05-12	0
Luza	15012	2022-05-12	0
Carrie Newcomer	15013	2022-05-12	0
U Brown	15014	2022-05-12	0
Wagon Cookin'	15015	2022-05-12	0
Ultraje A Rigor	15016	2022-05-12	0
High Rising	15017	2022-05-12	0
The Cleveland Orchestra;Pierre Boulez	15018	2022-05-12	0
Ever We Fall	15019	2022-05-12	0
Edward Shearmur	15020	2022-05-12	0
Favours for Sailors	15021	2022-05-12	0
Ariel Abshire	15022	2022-05-12	0
Suba feat. Cibelle	15023	2022-05-12	0
New Fast Automatic Daffodils	15024	2022-05-12	0
The Zutons	15025	2022-05-12	0
Leila Forouhar	15026	2022-05-12	0
Nicholas Payton	15027	2022-05-12	0
Wolfsheim	15028	2022-05-12	0
Eric B And Rakim	15029	2022-05-12	0
Pole Folder	15030	2022-05-12	0
Four Tet	15031	2022-05-12	0
Sam Butera & The Witnesses	15032	2022-05-12	0
Paul Taylor / Regina Belle	15033	2022-05-12	0
Rosemary Clooney	15034	2022-05-12	0
The Impossible Shapes	15035	2022-05-12	0
Nino Nardini	15036	2022-05-12	0
Advance Patrol	15037	2022-05-12	0
Chalie Boy	15038	2022-05-12	0
Gold City	15039	2022-05-12	0
Jackson Berkey_ Mannheim Steamroller	15040	2022-05-12	0
Jane Jensen	15041	2022-05-12	0
Kate Ryan	15042	2022-05-12	0
Olga tanon	15043	2022-05-12	0
Cheka	15044	2022-05-12	0
Knight Area	15045	2022-05-12	0
Ocean	15046	2022-05-12	0
Shirley Scott	15047	2022-05-12	0
Robert Shaw;Judith Raskin;Florence Kopleff;Richard Lewis;Thomas Paul;Robert Conant;Robert Arnold	15048	2022-05-12	0
The Buggles	15049	2022-05-12	0
Boris Brejcha	15050	2022-05-12	0
Chulito Camacho	15051	2022-05-12	0
Psyclon Nine	15052	2022-05-12	0
The Diplomats	15053	2022-05-12	0
Neikka RPM	15054	2022-05-12	0
Robert Gordon	15055	2022-05-12	0
Susan Aglukark	15056	2022-05-12	0
De Phazz	15057	2022-05-12	0
Bebe And Cece Winans	15058	2022-05-12	0
Blueboy	15059	2022-05-12	0
The Names	15060	2022-05-12	0
Lifelike	15061	2022-05-12	0
Thriller U	15062	2022-05-12	0
Monsieur Lune	15063	2022-05-12	0
Somadrone	15064	2022-05-12	0
Halfway to Gone	15065	2022-05-12	0
Dabuz System	15066	2022-05-12	0
Drumcorps	15067	2022-05-12	0
Puoskari	15068	2022-05-12	0
Chris Caffery	15069	2022-05-12	0
The Hullaballoos	15070	2022-05-12	0
The Ordinary Boys	15071	2022-05-12	0
DJ Encore / Engelina	15072	2022-05-12	0
Charles Dutoit	15073	2022-05-12	0
Inactive Messiah	15074	2022-05-12	0
Tony Allen	15075	2022-05-12	0
Eko Fresh	15076	2022-05-12	0
BadboE	15077	2022-05-12	0
Che'Nelle	15078	2022-05-12	0
Michael Splint	15079	2022-05-12	0
Vinjay	15080	2022-05-12	0
Grobschnitt	15081	2022-05-12	0
Dave Holland Big Band	15082	2022-05-12	0
Blue Foundation	15083	2022-05-12	0
The Diplomats / Jim Jones	15084	2022-05-12	0
The M-G-M Studio Chorus	15085	2022-05-12	0
Within Temptation	15086	2022-05-12	0
My Dad Is Dead	15087	2022-05-12	0
Offshore	15088	2022-05-12	0
Jae Millz / Jadakiss	15089	2022-05-12	0
Sauce Money	15090	2022-05-12	0
Georges Bizet	15091	2022-05-12	0
Andrew Spencer Meets Blue Nature	15092	2022-05-12	0
Patrick Bruel	15093	2022-05-12	0
Ricochet Klashnekoff	15094	2022-05-12	0
Riccardo Muti	15095	2022-05-12	0
Abra Moore	15096	2022-05-12	0
Duke Pearson	15097	2022-05-12	0
Candlebox	15098	2022-05-12	0
Bulletboys	15099	2022-05-12	0
Akissforjersey	15100	2022-05-12	0
Hellogoodbye	15101	2022-05-12	0
Ann Wilson	15102	2022-05-12	0
Joe Christmas	15103	2022-05-12	0
Candi Staton	15104	2022-05-12	0
Freddie McGregor	15105	2022-05-12	0
Andomat3000 & Jan	15106	2022-05-12	0
Trilogy	15107	2022-05-12	0
Brownie McGhee	15108	2022-05-12	0
Killing Joke	15109	2022-05-12	0
E-Rotic	15110	2022-05-12	0
The Bronx Casket Co.	15111	2022-05-12	0
Frank Ti-Aya Feat. Yardi Don	15112	2022-05-12	0
Last Winter	15113	2022-05-12	0
Double Image	15114	2022-05-12	0
Alabama 3 / Tenor Fly	15115	2022-05-12	0
Ceremonial Snips	15116	2022-05-12	0
Index For Potential Suicide	15117	2022-05-12	0
Serge Devant feat. Nadia Ali	15118	2022-05-12	0
Goatsblood	15119	2022-05-12	0
Skambankt	15120	2022-05-12	0
Beatfanatic	15121	2022-05-12	0
C-Funk	15122	2022-05-12	0
Tom Pulse vs. Sydney Youngblood	15123	2022-05-12	0
The Guilty Brothers Experience	15124	2022-05-12	0
Maria Solheim	15125	2022-05-12	0
The Revolutionaries	15126	2022-05-12	0
Hidden Agenda	15127	2022-05-12	0
Adelaide Hall	15128	2022-05-12	0
Future Sound Of London	15129	2022-05-12	0
Super Heroines	15130	2022-05-12	0
Mallorca Lee	15131	2022-05-12	0
Dexter Wansel	15132	2022-05-12	0
Agent Blue	15133	2022-05-12	0
Victor Young	15134	2022-05-12	0
Lou Gramm	15135	2022-05-12	0
Kinder vom Kleistpark	15136	2022-05-12	0
Michael Cera & Ellen Page	15137	2022-05-12	0
51717	15138	2022-05-12	0
Gunther & the Sunshine Girls	15139	2022-05-12	0
Gideon	15140	2022-05-12	0
Tito Gomez	15141	2022-05-12	0
Anais Mitchell [feat. Ben Knox Miller and Justin Vernon]	15142	2022-05-12	0
Jordan Rudess	15143	2022-05-12	0
Vince Taylor	15144	2022-05-12	0
The Lewis Family	15145	2022-05-12	0
The Jets	15146	2022-05-12	0
Taylor Hicks	15147	2022-05-12	0
KOVENANT_ THE	15148	2022-05-12	0
Dionne Warwick	15149	2022-05-12	0
Qwote	15150	2022-05-12	0
Once Nothing	15151	2022-05-12	0
Cássia Eller	15152	2022-05-12	0
Frans Bauer	15153	2022-05-12	0
Red Café	15154	2022-05-12	0
Dennis DeYoung	15155	2022-05-12	0
Andreas Tilliander	15156	2022-05-12	0
Monster Movie	15157	2022-05-12	0
Kudai	15158	2022-05-12	0
P.O.S	15159	2022-05-12	0
Classix Nouveaux	15160	2022-05-12	0
Rosa Balistreri	15161	2022-05-12	0
Charlie Haden Quartet West	15162	2022-05-12	0
MERCILESS	15163	2022-05-12	0
Penumbra	15164	2022-05-12	0
Bad Azz featuring E. White	15165	2022-05-12	0
Two Dollar Pistols	15166	2022-05-12	0
Troy Shondell	15167	2022-05-12	0
James Keelaghan	15168	2022-05-12	0
Andrew Spencer	15169	2022-05-12	0
Azeem	15170	2022-05-12	0
3LW	15171	2022-05-12	0
Satan's Pilgrims	15172	2022-05-12	0
Magazine	15173	2022-05-12	0
Maria Jimenez	15174	2022-05-12	0
The Cave Singers	15175	2022-05-12	0
Lichtenberg	15176	2022-05-12	0
Tyrone Wells	15177	2022-05-12	0
Banda Los Recoditos	15178	2022-05-12	0
Topmodelz	15179	2022-05-12	0
Hans Theessink	15180	2022-05-12	0
Pulsedriver	15181	2022-05-12	0
Jorge Cafrune	15182	2022-05-12	0
Manishevitz	15183	2022-05-12	0
Hellbastard	15184	2022-05-12	0
Die Aeronauten	15185	2022-05-12	0
Authentic	15186	2022-05-12	0
Hayko Cepkin	15187	2022-05-12	0
Hank Snow	15188	2022-05-12	0
Wally Badarou	15189	2022-05-12	0
Jacques Higelin	15190	2022-05-12	0
Aisha Duo	15191	2022-05-12	0
Piero Umiliani	15192	2022-05-12	0
The Gentrys	15193	2022-05-12	0
Bryan White	15194	2022-05-12	0
Red Red Meat	15195	2022-05-12	0
Julian Jeweil	15196	2022-05-12	0
Los Miserables	15197	2022-05-12	0
Natty King	15198	2022-05-12	0
Buddy Guy	15199	2022-05-12	0
Steve Ross	15200	2022-05-12	0
Holly Cole	15201	2022-05-12	0
Lester Flatt	15202	2022-05-12	0
Thomas Lemmer	15203	2022-05-12	0
Underwater	15204	2022-05-12	0
Whirlwind Heat	15205	2022-05-12	0
Faster Pussycat	15206	2022-05-12	0
Poni Hoax	15207	2022-05-12	0
ANGELZOOM	15208	2022-05-12	0
The Intelligence	15209	2022-05-12	0
Dee Dee Warwick	15210	2022-05-12	0
Cabaret Voltaire	15211	2022-05-12	0
Cadillac Don & J-Money	15212	2022-05-12	0
Flatt & Alvis	15213	2022-05-12	0
Furry Lewis	15214	2022-05-12	0
ALL:MY:FAULTS	15215	2022-05-12	0
Ton Koopman	15216	2022-05-12	0
Wendy Moten	15217	2022-05-12	0
Pep Love & Jay Biz	15218	2022-05-12	0
Frost feat. Romero	15219	2022-05-12	0
Los Iracundos	15220	2022-05-12	0
The Rakes	15221	2022-05-12	0
Plüsch	15222	2022-05-12	0
The Bottle Rockets	15223	2022-05-12	0
Rico Pabón	15224	2022-05-12	0
BONESHAKERS	15225	2022-05-12	0
Zeraphine	15226	2022-05-12	0
Tom Pulse	15227	2022-05-12	0
Lee Ritenour / Harvey Mason / Bob James	15228	2022-05-12	0
Angie Stone and Eddie Levert_ Sr.(of The O'Jays)	15229	2022-05-12	0
James Galway	15230	2022-05-12	0
Mantronix	15231	2022-05-12	0
XL5	15232	2022-05-12	0
Elaine Stritch	15233	2022-05-12	0
Roza Eskenazi	15234	2022-05-12	0
Leena Conquest	15235	2022-05-12	0
Simple Kid	15236	2022-05-12	0
Wanda Sá	15237	2022-05-12	0
Canibus	15238	2022-05-12	0
Space Tribe	15239	2022-05-12	0
De-Phazz	15240	2022-05-12	0
Red Foley	15241	2022-05-12	0
Zámbó Jimmy	15242	2022-05-12	0
Clay Allison	15243	2022-05-12	0
Darrell Scott	15244	2022-05-12	0
Lauren Hill	15245	2022-05-12	0
Cold Sweat	15246	2022-05-12	0
Andain	15247	2022-05-12	0
Peter Blegvad	15248	2022-05-12	0
Los Diablitos	15249	2022-05-12	0
Twiztid	15250	2022-05-12	0
Hagalaz' Runedance	15251	2022-05-12	0
Tiny Dancers	15252	2022-05-12	0
Dennis Brown & Prince Mohammed	15253	2022-05-12	0
Pixie Lott	15254	2022-05-12	0
Tycoon	15255	2022-05-12	0
Black Light Burns	15256	2022-05-12	0
Jon B	15257	2022-05-12	0
My Name Is Nobody	15258	2022-05-12	0
Will Saul	15259	2022-05-12	0
Kathryn Williams	15260	2022-05-12	0
Sevara Nazarkhan	15261	2022-05-12	0
Supastition	15262	2022-05-12	0
Jill Barber	15263	2022-05-12	0
Locanda Delle Fate	15264	2022-05-12	0
5 Blind Boys Of Alabama	15265	2022-05-12	0
Sabrina	15266	2022-05-12	0
Alien Sex Fiend	15267	2022-05-12	0
Eitan Reiter	15268	2022-05-12	0
Tam Tam Go!	15269	2022-05-12	0
Mark Lindsay	15270	2022-05-12	0
Niederflur	15271	2022-05-12	0
Varios	15272	2022-05-12	0
Trio Töykeät	15273	2022-05-12	0
Airscape	15274	2022-05-12	0
Glen Hansard & Marketa Irglova	15275	2022-05-12	0
Hacienda	15276	2022-05-12	0
Young MC	15277	2022-05-12	0
Editors	15278	2022-05-12	0
Kumbia Kings	15279	2022-05-12	0
Hatfield And The North	15280	2022-05-12	0
Squash Bowels	15281	2022-05-12	0
Steve Cropper / Pop Staples / Albert King	15282	2022-05-12	0
Dan Barta	15283	2022-05-12	0
El Hombre Burbuja	15284	2022-05-12	0
The Remains	15285	2022-05-12	0
T-Connection	15286	2022-05-12	0
Jennifer OConnor	15287	2022-05-12	0
Frank Klepacki	15288	2022-05-12	0
Boris Vian	15289	2022-05-12	0
Ice Cube	15290	2022-05-12	0
Legião Urbana	15291	2022-05-12	0
Second Silence	15292	2022-05-12	0
Candie Payne	15293	2022-05-12	0
Swervedriver	15294	2022-05-12	0
Polly Bergen	15295	2022-05-12	0
Lansing-Dreiden	15296	2022-05-12	0
Dobet Gnahoré	15297	2022-05-12	0
Les Thugs	15298	2022-05-12	0
Jughead's Revenge	15299	2022-05-12	0
Houston	15300	2022-05-12	0
Fritz Wunderlich/Berliner Symphoniker/Berislav Klobucar	15301	2022-05-12	0
The Barmitzvah Brothers	15302	2022-05-12	0
Jerry Jeff Walker	15303	2022-05-12	0
Jars Of Clay	15304	2022-05-12	0
Robkay & Snooky	15305	2022-05-12	0
Mojinos Escozios	15306	2022-05-12	0
Dispatch	15307	2022-05-12	0
Space DJZ	15308	2022-05-12	0
Inca Ore	15309	2022-05-12	0
Joe Krown	15310	2022-05-12	0
Slumber Party	15311	2022-05-12	0
Dixie Witch	15312	2022-05-12	0
Raheem Devaughn	15313	2022-05-12	0
Energy 52	15314	2022-05-12	0
Hell	15315	2022-05-12	0
Gordon MacRae_ Shirley Jones_ Gene Nelson_ Gloria Grahame_ Charlotte Greenwood	15316	2022-05-12	0
The Sunshine Fix	15317	2022-05-12	0
Viola	15318	2022-05-12	0
Thelonious Monster	15319	2022-05-12	0
Baggi Begovic	15320	2022-05-12	0
Wildchild	15321	2022-05-12	0
The Knights of the New Crusade	15322	2022-05-12	0
JFC	15323	2022-05-12	0
Adham Shaikh	15324	2022-05-12	0
Newsboys	15325	2022-05-12	0
Black Devil Disco Club With Prins Thomas	15326	2022-05-12	0
The Young Offenders Institute	15327	2022-05-12	0
Dntel	15328	2022-05-12	0
Dust Rhinos	15329	2022-05-12	0
Morten Abel	15330	2022-05-12	0
Tin Cup Prophette	15331	2022-05-12	0
Evergreen Terrace	15332	2022-05-12	0
Kain van Stone	15333	2022-05-12	0
David Newman	15334	2022-05-12	0
Shizuo	15335	2022-05-12	0
Rings	15336	2022-05-12	0
Unnatural Helpers	15337	2022-05-12	0
Cumpagnia Del Fil De Fer	15338	2022-05-12	0
Susan Egan	15339	2022-05-12	0
Everton Blender	15340	2022-05-12	0
Die 3	15341	2022-05-12	0
Charlie Shavers	15342	2022-05-12	0
Suburban Kids With Biblical Names	15343	2022-05-12	0
Tommy Torres	15344	2022-05-12	0
Fiddler's Green	15345	2022-05-12	0
Dirty South	15346	2022-05-12	0
Fred Fortin	15347	2022-05-12	0
Carl Belew	15348	2022-05-12	0
Assasin	15349	2022-05-12	0
Tweet/Bilal	15350	2022-05-12	0
One Reason	15351	2022-05-12	0
SLAPBAK	15352	2022-05-12	0
Lukie D	15353	2022-05-12	0
the J Michaels Band	15354	2022-05-12	0
Descendants Of Cain	15355	2022-05-12	0
Blue October	15356	2022-05-12	0
Andy Belling	15357	2022-05-12	0
Outformation	15358	2022-05-12	0
Tommy Hools	15359	2022-05-12	0
Asylum Street Spankers	15360	2022-05-12	0
Coffin Nails	15361	2022-05-12	0
Rod Lee	15362	2022-05-12	0
Fucked Up	15363	2022-05-12	0
Axenstar	15364	2022-05-12	0
Airbase	15365	2022-05-12	0
The Spinners	15366	2022-05-12	0
JOE TEX	15367	2022-05-12	0
Electric President	15368	2022-05-12	0
SOJA	15369	2022-05-12	0
Emerson_ Lake & Palmer	15370	2022-05-12	0
Pantera	15371	2022-05-12	0
Susana Félix	15372	2022-05-12	0
Common	15373	2022-05-12	0
Piano Red	15374	2022-05-12	0
Alado Sincera	15375	2022-05-12	0
Soul Oddity	15376	2022-05-12	0
Pleasure P	15377	2022-05-12	0
Old Man's Child	15378	2022-05-12	0
Criminal Manne	15379	2022-05-12	0
Stephen Malkmus	15380	2022-05-12	0
My Ruin	15381	2022-05-12	0
Bob Wills & His Texas Playboys / Rusty McDonald	15382	2022-05-12	0
Echologist feat. The Spaceape	15383	2022-05-12	0
Stuck-Ups_ The	15384	2022-05-12	0
T. Rex	15385	2022-05-12	0
Darius_ Finlay	15386	2022-05-12	0
Goldfish	15387	2022-05-12	0
Crystal Shores	15388	2022-05-12	0
Funkstörung	15389	2022-05-12	0
Bloem	15390	2022-05-12	0
Eva Avila/Nikki Yanofsky/Derek Miller	15391	2022-05-12	0
Curse Ov Dialect	15392	2022-05-12	0
Azuria	15393	2022-05-12	0
Beat Ben featuring Aiki	15394	2022-05-12	0
Humphrey;Humphrey feat. Rohff	15395	2022-05-12	0
Jamie's Elsewhere	15396	2022-05-12	0
Oliver Onions	15397	2022-05-12	0
Alphabeat	15398	2022-05-12	0
Joe Hill Louis	15399	2022-05-12	0
Bobbie Gentry	15400	2022-05-12	0
Dale Watson	15401	2022-05-12	0
Mid-State Orange	15402	2022-05-12	0
Bette Midler	15403	2022-05-12	0
The Golden Filter	15404	2022-05-12	0
Shearwater	15405	2022-05-12	0
Gigolo Tony	15406	2022-05-12	0
Clarence "Guitar" Sims	15407	2022-05-12	0
Tanzwut	15408	2022-05-12	0
Fettes Brot	15409	2022-05-12	0
Maj Karma	15410	2022-05-12	0
Aramirè	15411	2022-05-12	0
Monkey	15412	2022-05-12	0
Slam & Howie And The Reserve Men	15413	2022-05-12	0
Joey Scarbury	15414	2022-05-12	0
Neuraxis	15415	2022-05-12	0
Ramón Ayala	15416	2022-05-12	0
The Stone Roses	15417	2022-05-12	0
Cyndi Lauper	15418	2022-05-12	0
U-N-I	15419	2022-05-12	0
Beardo_ Beardo	15420	2022-05-12	0
Joe	15421	2022-05-12	0
Stephanie Cooke	15422	2022-05-12	0
João Gilberto	15423	2022-05-12	0
The Viceroys	15424	2022-05-12	0
Caravan	15425	2022-05-12	0
Hip Hop Hoodios	15426	2022-05-12	0
The Pretenders	15427	2022-05-12	0
Orphan Songs	15428	2022-05-12	0
Esoterica	15429	2022-05-12	0
Brick & Lace	15430	2022-05-12	0
DJ Spooky_ Bill Laswell_ Scanner_ Freeform_ Michael Mayer_ Kurt Schwitters	15431	2022-05-12	0
Fluf	15432	2022-05-12	0
Juan Socorro	15433	2022-05-12	0
Daniel Boone	15434	2022-05-12	0
Nump	15435	2022-05-12	0
Iz & Diz	15436	2022-05-12	0
Joey Dee & The Starliters	15437	2022-05-12	0
Cleo Laine	15438	2022-05-12	0
Bruce Carroll	15439	2022-05-12	0
Sezen Aksu	15440	2022-05-12	0
Equipe 84	15441	2022-05-12	0
Nakatomi Plaza	15442	2022-05-12	0
Banda Pequeños Musical	15443	2022-05-12	0
Diana Krall / Ray Brown / Stanley Turrentine	15444	2022-05-12	0
Zbigniew Preisner	15445	2022-05-12	0
Chick Corea_ Gary Burton	15446	2022-05-12	0
Wild Bill Moore	15447	2022-05-12	0
Heartless Bastards	15448	2022-05-12	0
Cory Branan	15449	2022-05-12	0
Stan Kolev	15450	2022-05-12	0
Stereoheroes	15451	2022-05-12	0
Petula Clark & Joe "Mr. Piano" Henderson	15452	2022-05-12	0
Cujo	15453	2022-05-12	0
Japan	15454	2022-05-12	0
Elton John	15455	2022-05-12	0
Kajagoogoo	15456	2022-05-12	0
Lan Ge	15457	2022-05-12	0
Terence Fixmer	15458	2022-05-12	0
Nuova Equipe 84	15459	2022-05-12	0
Pearl Bailey	15460	2022-05-12	0
John Wesley Harding	15461	2022-05-12	0
Galy Galiano	15462	2022-05-12	0
Sukshinder Shinda	15463	2022-05-12	0
El-P	15464	2022-05-12	0
Luther Johnson	15465	2022-05-12	0
Ana Bekuta	15466	2022-05-12	0
Charalambides	15467	2022-05-12	0
The Original Five Blind Boys Of Mississippi	15468	2022-05-12	0
Jimi Hendrix	15469	2022-05-12	0
Philip Oakey & Giorgio Moroder	15470	2022-05-12	0
Farewell To Freeway	15471	2022-05-12	0
Billy Paul	15472	2022-05-12	0
Krafty Kuts & Tim Deluxe	15473	2022-05-12	0
Big Bopper	15474	2022-05-12	0
Eugenio Finardi	15475	2022-05-12	0
Sergio Daniel Tiempo	15476	2022-05-12	0
Prince Po	15477	2022-05-12	0
Luna City Express	15478	2022-05-12	0
Dharma Bums	15479	2022-05-12	0
Thin White Rope	15480	2022-05-12	0
S.e.x.appeal	15481	2022-05-12	0
The Life And Times	15482	2022-05-12	0
Barbara Lewis	15483	2022-05-12	0
Gaye Adegbalola	15484	2022-05-12	0
Luther Vandross	15485	2022-05-12	0
Dj Nephets	15486	2022-05-12	0
All Leather	15487	2022-05-12	0
Cro-Mags	15488	2022-05-12	0
4 Lyn	15489	2022-05-12	0
Josh Gabriel Presents Winter Kills	15490	2022-05-12	0
Latinos Band	15491	2022-05-12	0
Malmo	15492	2022-05-12	0
DJ Deeon	15493	2022-05-12	0
Arthur Adams	15494	2022-05-12	0
Seed	15495	2022-05-12	0
Duncan James	15496	2022-05-12	0
Brian Regan	15497	2022-05-12	0
Emmylou Harris	15498	2022-05-12	0
Snooks Eaglin	15499	2022-05-12	0
Kispal Es A Borz	15500	2022-05-12	0
Cynthia	15501	2022-05-12	0
Brain Police	15502	2022-05-12	0
Love Inc.	15503	2022-05-12	0
Kaysh	15504	2022-05-12	0
Stanley Clarke & George Duke	15505	2022-05-12	0
Dixie Hustler	15506	2022-05-12	0
Lenny Escudero	15507	2022-05-12	0
Syke 'n' Sugarstarr	15508	2022-05-12	0
De Kreuners	15509	2022-05-12	0
Husalah of the Mob Figaz	15510	2022-05-12	0
Richard Marx	15511	2022-05-12	0
Saosin	15512	2022-05-12	0
Knights Of The Abyss	15513	2022-05-12	0
Culture Box	15514	2022-05-12	0
The Format	15515	2022-05-12	0
F.l.y.	15516	2022-05-12	0
Kawabata Makoto_ Anla Courtis & Rokugenkin	15517	2022-05-12	0
Doug Gray	15518	2022-05-12	0
Jennifer Knapp	15519	2022-05-12	0
Stu Hamm	15520	2022-05-12	0
Taquicardia	15521	2022-05-12	0
Kansas	15522	2022-05-12	0
BB King	15523	2022-05-12	0
Andromeda	15524	2022-05-12	0
Roken is Dodelijk	15525	2022-05-12	0
Kurt Carr & The Kurt Carr Singers	15526	2022-05-12	0
Adolph Hofner	15527	2022-05-12	0
Savoy Brown Blues Band	15528	2022-05-12	0
Martin Sexton	15529	2022-05-12	0
Regina Belle	15530	2022-05-12	0
Sniff 'n' The Tears	15531	2022-05-12	0
Recoil	15532	2022-05-12	0
Tye Tribbett & G.A.	15533	2022-05-12	0
Max B & DJ Lazy K	15534	2022-05-12	0
Apathy	15535	2022-05-12	0
Reno & Smiley	15536	2022-05-12	0
Fat & Frantic	15537	2022-05-12	0
PRIMEsth	15538	2022-05-12	0
Charlie Musselwhite	15539	2022-05-12	0
C-Murder / Soulja Slim / Magic	15540	2022-05-12	0
José Roberto Bertrami	15541	2022-05-12	0
Bill Murk	15542	2022-05-12	0
Pat Metheny_ Lyle Mays_ Mark Egan_ Dan Gottlieb	15543	2022-05-12	0
DJ Khaled	15544	2022-05-12	0
Luciano Pavarotti	15545	2022-05-12	0
The Rembrandts	15546	2022-05-12	0
Eastern Lane	15547	2022-05-12	0
Pimentola	15548	2022-05-12	0
Clap Your Hands Say Yeah	15549	2022-05-12	0
Burning Babylon	15550	2022-05-12	0
Glashaus	15551	2022-05-12	0
Jay McShann	15552	2022-05-12	0
John Parr	15553	2022-05-12	0
Jimmy Edgar	15554	2022-05-12	0
Lee Michaels	15555	2022-05-12	0
Slaughter & The Dogs	15556	2022-05-12	0
Deep Dish	15557	2022-05-12	0
The Alter Boys	15558	2022-05-12	0
Matteah Baim	15559	2022-05-12	0
Mazell	15560	2022-05-12	0
Nicolai Rimsky-Korsakov	15561	2022-05-12	0
Figli di Madre Ignota	15562	2022-05-12	0
Mechanical Poet	15563	2022-05-12	0
Hell Is For Heroes	15564	2022-05-12	0
Red Sparowes	15565	2022-05-12	0
Dewey Corley	15566	2022-05-12	0
Brooklyn Bounce vs. Alex M. & Marc van Damme	15567	2022-05-12	0
Tenpole Tudor	15568	2022-05-12	0
Cliff Bennett & The Rebel Rousers	15569	2022-05-12	0
Bon Voyage	15570	2022-05-12	0
The Stingers ATX	15571	2022-05-12	0
Elizeth Cardoso	15572	2022-05-12	0
Bettye Swan	15573	2022-05-12	0
The Beyond	15574	2022-05-12	0
Buckwheat Zydeco	15575	2022-05-12	0
Killerpilze	15576	2022-05-12	0
I See Hawks In L.A.	15577	2022-05-12	0
Timbuktu	15578	2022-05-12	0
Circus Night	15579	2022-05-12	0
DJ Mehdi feat. Chromeo	15580	2022-05-12	0
K's Choice	15581	2022-05-12	0
Fruteland Jackson	15582	2022-05-12	0
Ghost in the Machine	15583	2022-05-12	0
Song Zuying	15584	2022-05-12	0
Brian Hyland	15585	2022-05-12	0
Edhels	15586	2022-05-12	0
Moskwa TV	15587	2022-05-12	0
Gareth Emery & Jon O'Bir	15588	2022-05-12	0
Cannonball Adderley / Milt Jackson	15589	2022-05-12	0
All Star United	15590	2022-05-12	0
Cabballero	15591	2022-05-12	0
Look See Proof	15592	2022-05-12	0
Manta Ray	15593	2022-05-12	0
Scumbucket	15594	2022-05-12	0
Ginger Frolic	15595	2022-05-12	0
Mark B & Blade	15596	2022-05-12	0
Dzem	15597	2022-05-12	0
Cserháti Zsuzsa	15598	2022-05-12	0
Beatnuts featuring NOGOODUS	15599	2022-05-12	0
Des'ree	15600	2022-05-12	0
Squarepusher	15601	2022-05-12	0
Los Rieleros Del Norte	15602	2022-05-12	0
Natural Born Grooves feat. Thea Austin	15603	2022-05-12	0
Marta Topferova	15604	2022-05-12	0
The Pink Noise	15605	2022-05-12	0
Goodie MoB	15606	2022-05-12	0
Richi M.	15607	2022-05-12	0
Carlos Kotkin	15608	2022-05-12	0
Boxcutter	15609	2022-05-12	0
Jens Friebe	15610	2022-05-12	0
Jean-François Paillard	15611	2022-05-12	0
Cali Life Style	15612	2022-05-12	0
Indexi	15613	2022-05-12	0
Nima Gorji	15614	2022-05-12	0
Walter Schreifels	15615	2022-05-12	0
Mal	15616	2022-05-12	0
Rihanna / Elephant Man	15617	2022-05-12	0
Stendal Blast	15618	2022-05-12	0
Poney Express	15619	2022-05-12	0
Tippa Irie	15620	2022-05-12	0
Horace Andy	15621	2022-05-12	0
Theodor Zox	15622	2022-05-12	0
Martha & The Vandellas	15623	2022-05-12	0
Zombie Zombie	15624	2022-05-12	0
Dj Cam	15625	2022-05-12	0
Blackmore's Night	15626	2022-05-12	0
Scott Brown	15627	2022-05-12	0
!Bazz feat. Leverne	15628	2022-05-12	0
The Three Sounds	15629	2022-05-12	0
Steeple Remove	15630	2022-05-12	0
Vic Godard & Subway Sect	15631	2022-05-12	0
Neon Neon	15632	2022-05-12	0
Loopin	15633	2022-05-12	0
Belgian Asociality	15634	2022-05-12	0
Remote Control Egypt	15635	2022-05-12	0
Aberdeen	15636	2022-05-12	0
LL Cool J	15637	2022-05-12	0
Pat Farrell	15638	2022-05-12	0
Jon Lord	15639	2022-05-12	0
Someday Never	15640	2022-05-12	0
Los Tiki Phantoms	15641	2022-05-12	0
Satanic Surfers	15642	2022-05-12	0
Know the Score	15643	2022-05-12	0
Clarence Fountain	15644	2022-05-12	0
The Nam Shub of Enki	15645	2022-05-12	0
Jessy Dixon	15646	2022-05-12	0
Danny And The Juniors	15647	2022-05-12	0
Livingston Taylor	15648	2022-05-12	0
Alton Ellis	15649	2022-05-12	0
Haircut 100	15650	2022-05-12	0
Washington	15651	2022-05-12	0
Josie Kreuzer	15652	2022-05-12	0
Sviatoslav Richter (piano)	15653	2022-05-12	0
The Smiths	15654	2022-05-12	0
Nelly / Avery Storm	15655	2022-05-12	0
Zagar feat. Underground Divas	15656	2022-05-12	0
Cap'n Jazz	15657	2022-05-12	0
Fat Bastard	15658	2022-05-12	0
Soulwax	15659	2022-05-12	0
Dillinger Four	15660	2022-05-12	0
Gilberto Santa Rosa	15661	2022-05-12	0
Johnatron	15662	2022-05-12	0
Cinder	15663	2022-05-12	0
Henri René and His Orchestra	15664	2022-05-12	0
Entrance	15665	2022-05-12	0
Charlie Hunter & Bobby Previte	15666	2022-05-12	0
Disconcerts	15667	2022-05-12	0
Charlie Christian / Dizzy Gillespie	15668	2022-05-12	0
Capleton	15669	2022-05-12	0
Tiffany Evans	15670	2022-05-12	0
Dobet Gnahore	15671	2022-05-12	0
Psalm One	15672	2022-05-12	0
Oktober Skyline	15673	2022-05-12	0
Thug Dirt	15674	2022-05-12	0
Aphex Twin	15675	2022-05-12	0
pexbaA	15676	2022-05-12	0
Bob Weir	15677	2022-05-12	0
Marco	15678	2022-05-12	0
Growing	15679	2022-05-12	0
Blood Has Been Shed	15680	2022-05-12	0
Gordon MacRae_ Shirley Jones & Cast	15681	2022-05-12	0
Dandy	15682	2022-05-12	0
Rita Chiarelli	15683	2022-05-12	0
Francesco De Masi	15684	2022-05-12	0
Nana Caymmi E Danilo Caymmi	15685	2022-05-12	0
Frankie Lymon And The Teenagers	15686	2022-05-12	0
Pifco	15687	2022-05-12	0
Frank Chacksfield	15688	2022-05-12	0
Slowpho	15689	2022-05-12	0
Michael de Jong	15690	2022-05-12	0
Electrostatic	15691	2022-05-12	0
Aqua	15692	2022-05-12	0
Ana	15693	2022-05-12	0
Pearly Queen	15694	2022-05-12	0
Fatback	15695	2022-05-12	0
Albin De La Simone	15696	2022-05-12	0
Sasha / Turbulence	15697	2022-05-12	0
Boyracer	15698	2022-05-12	0
ANA BELEN Y VICTOR MANUEL	15699	2022-05-12	0
Richard Dolby	15700	2022-05-12	0
Bloody Dead And Sexy	15701	2022-05-12	0
Karol XVII & MB Valence	15702	2022-05-12	0
Hooray! For Everything	15703	2022-05-12	0
Mormon Tabernacle Choir	15704	2022-05-12	0
Rosinha De Valenca	15705	2022-05-12	0
Flatt & Scruggs	15706	2022-05-12	0
Dope Smugglaz	15707	2022-05-12	0
Holy Hail	15708	2022-05-12	0
Patty Griffin	15709	2022-05-12	0
Madvillain	15710	2022-05-12	0
Totta Näslund	15711	2022-05-12	0
Super Flu	15712	2022-05-12	0
Shaun Escoffery	15713	2022-05-12	0
Fat Joe featuring Lil Wayne	15714	2022-05-12	0
Q-Project	15715	2022-05-12	0
Kevin Mahogany	15716	2022-05-12	0
Marisela	15717	2022-05-12	0
Frank Chacksfield  Orchestra	15718	2022-05-12	0
Single Cell Orchestra	15719	2022-05-12	0
José José	15720	2022-05-12	0
Baby Bash / Sugar Free / Money Mike / Chingo Bling	15721	2022-05-12	0
Walter Jackson	15722	2022-05-12	0
Boozoo Bajou	15723	2022-05-12	0
Ron Carter	15724	2022-05-12	0
Roman Salzger	15725	2022-05-12	0
A-Team	15726	2022-05-12	0
Young Widows	15727	2022-05-12	0
Bud Powell	15728	2022-05-12	0
The Glenn Miller Orchestra	15729	2022-05-12	0
A Silent Film	15730	2022-05-12	0
Luiz Melodia	15731	2022-05-12	0
Inhume	15732	2022-05-12	0
Mutkattomat	15733	2022-05-12	0
Velvet Salsa All Stars	15734	2022-05-12	0
Louis Prima And Keely Smith	15735	2022-05-12	0
Aghora	15736	2022-05-12	0
Basic Channel	15737	2022-05-12	0
Masai Bey	15738	2022-05-12	0
Dr. Buzzard's Original Savannah Band	15739	2022-05-12	0
Jack Webb	15740	2022-05-12	0
Coogans Bluff	15741	2022-05-12	0
Sterling Void	15742	2022-05-12	0
Fred Waring and The Pennsylvanians	15743	2022-05-12	0
Harald Kloser	15744	2022-05-12	0
Jamiroquai	15745	2022-05-12	0
Cam'Ron	15746	2022-05-12	0
Jody Bernal	15747	2022-05-12	0
B Angie B	15748	2022-05-12	0
Nobody & Mystic Chords Of Memory	15749	2022-05-12	0
Turbo Fruits	15750	2022-05-12	0
Phil Harris	15751	2022-05-12	0
Krisiun	15752	2022-05-12	0
Miami Sound Machine	15753	2022-05-12	0
Ben Harper And Relentless7	15754	2022-05-12	0
Bob McKenzie / Doug McKenzie	15755	2022-05-12	0
Boat	15756	2022-05-12	0
A Plus	15757	2022-05-12	0
Jane Olivor	15758	2022-05-12	0
Toni Cottura	15759	2022-05-12	0
Ink Spots	15760	2022-05-12	0
Pharaoh's Daughter	15761	2022-05-12	0
Mousse T.	15762	2022-05-12	0
Nero's Day At Disneyland	15763	2022-05-12	0
David Lanz/Paul Speer	15764	2022-05-12	0
Tyrades	15765	2022-05-12	0
Romantika Sound	15766	2022-05-12	0
Bryan Adams	15767	2022-05-12	0
Nitty Gritty	15768	2022-05-12	0
Il disordine delle cose	15769	2022-05-12	0
The Dead Milkmen	15770	2022-05-12	0
Hugh Cornwell	15771	2022-05-12	0
Loriot	15772	2022-05-12	0
G. Love	15773	2022-05-12	0
The Year of Our Lord	15774	2022-05-12	0
KC Flightt	15775	2022-05-12	0
Rookie	15776	2022-05-12	0
Alexisonfire	15777	2022-05-12	0
Allergic to Whores / Mccarthy Commission	15778	2022-05-12	0
The Accused	15779	2022-05-12	0
Mean Creek	15780	2022-05-12	0
Unleashed	15781	2022-05-12	0
Hirax	15782	2022-05-12	0
Het Gloren	15783	2022-05-12	0
Memory Tapes	15784	2022-05-12	0
Dave Brubeck	15785	2022-05-12	0
John Cale	15786	2022-05-12	0
Tarkio	15787	2022-05-12	0
Solo Los Solo	15788	2022-05-12	0
Lights of Euphoria	15789	2022-05-12	0
Socialburn	15790	2022-05-12	0
Hymie's Basement	15791	2022-05-12	0
Screen	15792	2022-05-12	0
Mory Kante	15793	2022-05-12	0
Noir Désir	15794	2022-05-12	0
TV Rock Feat. Rudy	15795	2022-05-12	0
Ida Corr	15796	2022-05-12	0
Misel Quitno	15797	2022-05-12	0
The Polka Band	15798	2022-05-12	0
Oasis	15799	2022-05-12	0
Beni	15800	2022-05-12	0
Hot Club Of Detroit	15801	2022-05-12	0
Marilyn Horne;Mormon Tabernacle Choir;Columbia Symphony Orchestra;Dr. Jerold Ottley	15802	2022-05-12	0
Dublin Gospel Choir	15803	2022-05-12	0
Dr. Dre	15804	2022-05-12	0
Jack Livingston Marching Band	15805	2022-05-12	0
Los Alegres De Teran	15806	2022-05-12	0
C.C. Adcock	15807	2022-05-12	0
Walter Hawkins	15808	2022-05-12	0
Turn Pale	15809	2022-05-12	0
Chicory Tip	15810	2022-05-12	0
I Roy	15811	2022-05-12	0
Chalino Sanchez	15812	2022-05-12	0
T Lavitz	15813	2022-05-12	0
I Ribelli	15814	2022-05-12	0
Bigwig	15815	2022-05-12	0
Keak Da Sneak	15816	2022-05-12	0
A Challenge Of Honour	15817	2022-05-12	0
Afterlife featuring Matti Dinah	15818	2022-05-12	0
Inkwell	15819	2022-05-12	0
Square One Feat. Alison Hinds	15820	2022-05-12	0
Bonfire	15821	2022-05-12	0
William Shakespeare	15822	2022-05-12	0
Moments In Grace	15823	2022-05-12	0
Elton Britt	15824	2022-05-12	0
Alien Project	15825	2022-05-12	0
Ed Burleson	15826	2022-05-12	0
madrugá flamenca	15827	2022-05-12	0
Dream Evil	15828	2022-05-12	0
Lonnie Donegan and his Skiffle Group	15829	2022-05-12	0
Distance	15830	2022-05-12	0
Steve Bug	15831	2022-05-12	0
Knastboxer	15832	2022-05-12	0
The Ruby Suns	15833	2022-05-12	0
X-Raided featuring B.Parker_ C-Dubb	15834	2022-05-12	0
Rockin' Rebels	15835	2022-05-12	0
Big In Japan	15836	2022-05-12	0
The Waxwings	15837	2022-05-12	0
Finn's Motel	15838	2022-05-12	0
Vanessa Daou	15839	2022-05-12	0
Die Symphony	15840	2022-05-12	0
Aleks Syntek/Benny	15841	2022-05-12	0
The Kills	15842	2022-05-12	0
Beny More	15843	2022-05-12	0
Mickey Gilley	15844	2022-05-12	0
YACHT	15845	2022-05-12	0
José Augusto	15846	2022-05-12	0
U.D.I.	15847	2022-05-12	0
Sator	15848	2022-05-12	0
David Saylor	15849	2022-05-12	0
Italian Secret Service	15850	2022-05-12	0
It's A Musical	15851	2022-05-12	0
Bebe	15852	2022-05-12	0
Twice As Nice	15853	2022-05-12	0
DARK NEBULA	15854	2022-05-12	0
La Dama Se Esconde	15855	2022-05-12	0
Second Opinion	15856	2022-05-12	0
Frankie Goes To Hollywood	15857	2022-05-12	0
Mahogany	15858	2022-05-12	0
The Gay Corporation	15859	2022-05-12	0
Yerba Brava	15860	2022-05-12	0
Skunk D.F.	15861	2022-05-12	0
Kevin Seconds	15862	2022-05-12	0
Momus	15863	2022-05-12	0
Zadera	15864	2022-05-12	0
Joe Smooth	15865	2022-05-12	0
Rex Allen_ Jr.	15866	2022-05-12	0
Yo-Yo Ma;Philip Glass Ensemble	15867	2022-05-12	0
Jack McDuff / Joey DeFrancesco	15868	2022-05-12	0
T. W. Walsh	15869	2022-05-12	0
Dolly Parton	15870	2022-05-12	0
Billy Joel	15871	2022-05-12	0
Alejandra Guzman	15872	2022-05-12	0
The Tyde	15873	2022-05-12	0
Cutty Ranks	15874	2022-05-12	0
Texas Terri Bomb!	15875	2022-05-12	0
Albert Vorne	15876	2022-05-12	0
Ultrakurt	15877	2022-05-12	0
Sophie Zelmani	15878	2022-05-12	0
Françoise Hardy	15879	2022-05-12	0
Jason van Wyk & Vast Vision Feat. Johanna	15880	2022-05-12	0
Dinastía Norteña_ Oro Norteño	15881	2022-05-12	0
Andrea Parker featuring DJ Assault & DJ Godfather	15882	2022-05-12	0
A Woman's Journey - Vickie Winans_ Brenda Nicholas	15883	2022-05-12	0
Eardrum	15884	2022-05-12	0
Tacks_ the Boy Disaster	15885	2022-05-12	0
The Meters	15886	2022-05-12	0
Tim Koch	15887	2022-05-12	0
Samael	15888	2022-05-12	0
Peter Visti	15889	2022-05-12	0
Positive K	15890	2022-05-12	0
Hamilton Camp	15891	2022-05-12	0
Jennifer Hudson featuring Fantasia	15892	2022-05-12	0
The Pop Hit Crew	15893	2022-05-12	0
Matthew Dear	15894	2022-05-12	0
Law Found Guilt	15895	2022-05-12	0
Vaea Vahinemoea-Bakker	15896	2022-05-12	0
Los Manolos	15897	2022-05-12	0
Chris Smither	15898	2022-05-12	0
Houari Benchenet	15899	2022-05-12	0
Stan Van Samang	15900	2022-05-12	0
Young Dru	15901	2022-05-12	0
Daughterboy Jao	15902	2022-05-12	0
Mestre Marçal	15903	2022-05-12	0
Francky Vincent	15904	2022-05-12	0
Lone Justice	15905	2022-05-12	0
Muchachito Bombo Infierno	15906	2022-05-12	0
The Noise Next Door	15907	2022-05-12	0
Malik Alston	15908	2022-05-12	0
Red Dragon	15909	2022-05-12	0
Dominik Eulberg	15910	2022-05-12	0
Volsoc	15911	2022-05-12	0
Richard Berry	15912	2022-05-12	0
Japandroids	15913	2022-05-12	0
Inaya Day vs. Native Sons	15914	2022-05-12	0
The Dutchess & The Duke	15915	2022-05-12	0
Lord Creator	15916	2022-05-12	0
Samantha Fox	15917	2022-05-12	0
Trae	15918	2022-05-12	0
J-Dilla	15919	2022-05-12	0
Shola Ama	15920	2022-05-12	0
Rebbie Jackson	15921	2022-05-12	0
Green Apple Quick Step	15922	2022-05-12	0
Instant Asshole	15923	2022-05-12	0
Golden Animals	15924	2022-05-12	0
The Sleeper	15925	2022-05-12	0
Amjad Ali Khan_ Shafat Ahmed Khan	15926	2022-05-12	0
Cold World  Hustlers	15927	2022-05-12	0
Louis Jordan with Johnny Otis Featuring Shuggie Otis	15928	2022-05-12	0
Hi-Tack	15929	2022-05-12	0
Evan Parker	15930	2022-05-12	0
The Boats	15931	2022-05-12	0
José Carreras;Eva Marton;Michael Tilson Thomas;Juan Pons	15932	2022-05-12	0
Cern & Dabs	15933	2022-05-12	0
Luigi Lusini	15934	2022-05-12	0
Sound Dimension	15935	2022-05-12	0
Max Mutzke	15936	2022-05-12	0
Coyote Oldman	15937	2022-05-12	0
Foetus	15938	2022-05-12	0
K-Rings Brothers	15939	2022-05-12	0
Juan Luis Guerra	15940	2022-05-12	0
Saravah Soul	15941	2022-05-12	0
Hans Werner Olm	15942	2022-05-12	0
8 Wonders	15943	2022-05-12	0
Office Gossip	15944	2022-05-12	0
Chantal Chamandy	15945	2022-05-12	0
The Inbreds	15946	2022-05-12	0
Kassav'	15947	2022-05-12	0
The Hi-Lo's	15948	2022-05-12	0
DHC Meinhof	15949	2022-05-12	0
Tokio Hotel	15950	2022-05-12	0
Lillebjørn Nilsen	15951	2022-05-12	0
Lucien Foort feat. I-Fan	15952	2022-05-12	0
Rodney P / Farma G / Mystro / Braintax	15953	2022-05-12	0
Karen Mok	15954	2022-05-12	0
Claire Guyot	15955	2022-05-12	0
Strich Acht	15956	2022-05-12	0
Steve Ellington Band	15957	2022-05-12	0
The Reach	15958	2022-05-12	0
ÄI-TIEM	15959	2022-05-12	0
The Count Bishops	15960	2022-05-12	0
Aberfeldy	15961	2022-05-12	0
Seek	15962	2022-05-12	0
The Vandals	15963	2022-05-12	0
Nevrotic Explosion	15964	2022-05-12	0
Coco Electrik	15965	2022-05-12	0
UMOJA	15966	2022-05-12	0
Raul Mezcolanza & Ian Hendrix	15967	2022-05-12	0
Stefan Diestelmann	15968	2022-05-12	0
Bishop Allen	15969	2022-05-12	0
Preston School Of Industry	15970	2022-05-12	0
Dennis Brown Presents Prince Jammy	15971	2022-05-12	0
Grass Widow	15972	2022-05-12	0
Nati Cano's Mariachi Los Camperos	15973	2022-05-12	0
Verka Serduchka	15974	2022-05-12	0
Space Monkey	15975	2022-05-12	0
Axegrinder	15976	2022-05-12	0
Earthling	15977	2022-05-12	0
Pin Group	15978	2022-05-12	0
Bare Egil Band	15979	2022-05-12	0
Staggered Crossing	15980	2022-05-12	0
Colossus	15981	2022-05-12	0
Trivium	15982	2022-05-12	0
John Lee Hooker Jr	15983	2022-05-12	0
Chris Farlowe And The Thunderbirds	15984	2022-05-12	0
Tabu Ley Rochereau	15985	2022-05-12	0
Article One	15986	2022-05-12	0
Residual Echoes	15987	2022-05-12	0
Cocktail Slippers	15988	2022-05-12	0
Miranda Sex Garden	15989	2022-05-12	0
Extra Virgin	15990	2022-05-12	0
Stefano Bollani	15991	2022-05-12	0
Roundhead	15992	2022-05-12	0
Synaesthesia	15993	2022-05-12	0
Melvins	15994	2022-05-12	0
Workout Soundtracks	15995	2022-05-12	0
Yesterday's New Quintet	15996	2022-05-12	0
Fuck Buttons	15997	2022-05-12	0
Les Gourmets	15998	2022-05-12	0
Dynamic Illusion	15999	2022-05-12	0
Mac Curtis	16000	2022-05-12	0
La Fiebre	16001	2022-05-12	0
The Guess Who	16002	2022-05-12	0
The Plastic Cloud	16003	2022-05-12	0
Bavu Blakes	16004	2022-05-12	0
Javier Ruibal	16005	2022-05-12	0
Ascii.Disko	16006	2022-05-12	0
Home Grown	16007	2022-05-12	0
Disflex 6	16008	2022-05-12	0
A Global Threat	16009	2022-05-12	0
Orbit	16010	2022-05-12	0
Casey	16011	2022-05-12	0
Maximilian Hecker	16012	2022-05-12	0
Pilate	16013	2022-05-12	0
Massimo	16014	2022-05-12	0
Eisblut	16015	2022-05-12	0
Geraldo Pino & The Heartbeats	16016	2022-05-12	0
Jarvis Cocker	16017	2022-05-12	0
Diana Ross & The Supremes	16018	2022-05-12	0
Voice Mail	16019	2022-05-12	0
Fu	16020	2022-05-12	0
Sérgio Cassiano	16021	2022-05-12	0
Reba McEntire / Brian Stokes Mitchell	16022	2022-05-12	0
Coast 2 Coast feat. Le Sal And Phoenix	16023	2022-05-12	0
Madonna	16024	2022-05-12	0
Morten Harket	16025	2022-05-12	0
Jimmy Rogers	16026	2022-05-12	0
Thierry Hazard	16027	2022-05-12	0
Lab Report	16028	2022-05-12	0
Daniel Lemma	16029	2022-05-12	0
Nat Stuckey	16030	2022-05-12	0
Fred Neil	16031	2022-05-12	0
John Brown	16032	2022-05-12	0
Ástor Piazzolla	16033	2022-05-12	0
Movies With Heroes	16034	2022-05-12	0
Warriors_ The	16035	2022-05-12	0
The Deep Dark Woods	16036	2022-05-12	0
Térez Montcalm	16037	2022-05-12	0
Brownie McGhee & Sonny Terry	16038	2022-05-12	0
Little Bruce_ Y.S._ Compound Click_ Trill Real	16039	2022-05-12	0
Blackmail	16040	2022-05-12	0
Pequeña Compañia (F)	16041	2022-05-12	0
Rasmus Faber	16042	2022-05-12	0
Harold Melvin;Harold Melvin and The Blue Notes	16043	2022-05-12	0
Luis Bacalov	16044	2022-05-12	0
Fluxion	16045	2022-05-12	0
Think Twice	16046	2022-05-12	0
La Caravane Passe	16047	2022-05-12	0
Richard Galliano	16048	2022-05-12	0
Audio Science	16049	2022-05-12	0
Vena Cava	16050	2022-05-12	0
Conquering Lion	16051	2022-05-12	0
You Am I	16052	2022-05-12	0
Marillion	16053	2022-05-12	0
Kevin Hewick	16054	2022-05-12	0
Exotique	16055	2022-05-12	0
P.H.A.T.T. & Solar Scape	16056	2022-05-12	0
Oum Kalthoum	16057	2022-05-12	0
Cobla Mil.Lenària	16058	2022-05-12	0
Nik P.	16059	2022-05-12	0
Bombay Dub Orchestra	16060	2022-05-12	0
Nikka Costa	16061	2022-05-12	0
Michael J. Sheehy	16062	2022-05-12	0
Fred Åkerström	16063	2022-05-12	0
Raul Seixas	16064	2022-05-12	0
Sister Sledge	16065	2022-05-12	0
Gerard Joling	16066	2022-05-12	0
DAT Politics	16067	2022-05-12	0
L.E.S. Stitches	16068	2022-05-12	0
Ávalon	16069	2022-05-12	0
The Aggrolites	16070	2022-05-12	0
Kruiz	16071	2022-05-12	0
Con Funk Shun	16072	2022-05-12	0
The Waitresses	16073	2022-05-12	0
Bill Haley & His Comets	16074	2022-05-12	0
Little Jimmy Taylor	16075	2022-05-12	0
Pride And Fall	16076	2022-05-12	0
Pino Donaggio	16077	2022-05-12	0
Papa Dee	16078	2022-05-12	0
Steve Angello	16079	2022-05-12	0
Ben Kweller	16080	2022-05-12	0
DJ Clue / Made Men	16081	2022-05-12	0
Failure	16082	2022-05-12	0
Johnny Jenkins	16083	2022-05-12	0
Quest Pistols	16084	2022-05-12	0
Shuta Hasunuma	16085	2022-05-12	0
Los Parientes De Playa Vicente	16086	2022-05-12	0
Riviera Regime	16087	2022-05-12	0
Team Dresch	16088	2022-05-12	0
By The Grace Of God	16089	2022-05-12	0
The Demigodz	16090	2022-05-12	0
Ashley Matte	16091	2022-05-12	0
Wilco	16092	2022-05-12	0
The Nihilists	16093	2022-05-12	0
Ian Dury & The Blockheads	16094	2022-05-12	0
The Wilde Flowers	16095	2022-05-12	0
Emeneya	16096	2022-05-12	0
The Creators feat. Diamond D	16097	2022-05-12	0
Bill Wells & Maher Shalal Hash Baz	16098	2022-05-12	0
Los Corraleros De Majagual	16099	2022-05-12	0
Eskimo	16100	2022-05-12	0
Bill Evans Trio	16101	2022-05-12	0
The Swellers	16102	2022-05-12	0
Losing Focus	16103	2022-05-12	0
Philly Cream	16104	2022-05-12	0
Afterhours	16105	2022-05-12	0
Ednita Nazario	16106	2022-05-12	0
Orquesta Sublime	16107	2022-05-12	0
Close Shave	16108	2022-05-12	0
Ashanti Waugh	16109	2022-05-12	0
Outolintu	16110	2022-05-12	0
Four Bitchin' Babes	16111	2022-05-12	0
Nat "King" Cole	16112	2022-05-12	0
Olli Schulz Und Der Hund Marie	16113	2022-05-12	0
Anthony David	16114	2022-05-12	0
SINISTER	16115	2022-05-12	0
Chris Zippel	16116	2022-05-12	0
Sergio Rivero	16117	2022-05-12	0
Tribes Of Neurot	16118	2022-05-12	0
Mr. Grillo	16119	2022-05-12	0
28 Days	16120	2022-05-12	0
Marc Et Claude	16121	2022-05-12	0
Apple One	16122	2022-05-12	0
Secret Machines	16123	2022-05-12	0
Kid Loco/Parov Stelar	16124	2022-05-12	0
Rahsaan Roland Kirk	16125	2022-05-12	0
Ennio Morricone	16126	2022-05-12	0
Czar*Nok	16127	2022-05-12	0
The Cadillacs	16128	2022-05-12	0
Antonymes	16129	2022-05-12	0
Larry Carlton	16130	2022-05-12	0
Eric Darius featuring Norman Brown	16131	2022-05-12	0
Drawn & Quartered	16132	2022-05-12	0
Godflesh	16133	2022-05-12	0
NANA/DARKMAN	16134	2022-05-12	0
Freddy Fender	16135	2022-05-12	0
Brooke Waggoner	16136	2022-05-12	0
Lars Klein	16137	2022-05-12	0
Audience	16138	2022-05-12	0
David Bromberg	16139	2022-05-12	0
Eminem / 50 Cent / Cashis / Lloyd Banks	16140	2022-05-12	0
Little Twitch	16141	2022-05-12	0
Brother Beyond	16142	2022-05-12	0
The Electric Prunes	16143	2022-05-12	0
Bring Me The Horizon	16144	2022-05-12	0
Enrique Morente	16145	2022-05-12	0
Tactical Thinking	16146	2022-05-12	0
Lushlife	16147	2022-05-12	0
Quadro Nuevo	16148	2022-05-12	0
Blodwyn Pig	16149	2022-05-12	0
Adam Brand	16150	2022-05-12	0
Red Animal War	16151	2022-05-12	0
House Of Lords	16152	2022-05-12	0
Keith Sweat	16153	2022-05-12	0
Audiosmog	16154	2022-05-12	0
The Jelly Jam	16155	2022-05-12	0
Moving Gelatine Plates	16156	2022-05-12	0
Headlights	16157	2022-05-12	0
Girl Talk	16158	2022-05-12	0
Hubert-Félix Thiéfaine	16159	2022-05-12	0
Even As We Speak	16160	2022-05-12	0
One-Way Mirror	16161	2022-05-12	0
Room 5	16162	2022-05-12	0
Qomolangma Tomato	16163	2022-05-12	0
Barbra Streisand;Yves Montand	16164	2022-05-12	0
Stash & Sarah Bettens	16165	2022-05-12	0
Lady Sweety	16166	2022-05-12	0
Casey Bill Weldon	16167	2022-05-12	0
Diesel Boy	16168	2022-05-12	0
Braintax	16169	2022-05-12	0
Luscious Jackson	16170	2022-05-12	0
Royksopp	16171	2022-05-12	0
The Friggs	16172	2022-05-12	0
Madrugada	16173	2022-05-12	0
Manolo Otero	16174	2022-05-12	0
The Divorce	16175	2022-05-12	0
Nat King Cole	16176	2022-05-12	0
Tom McRae	16177	2022-05-12	0
Haji & Emanuel	16178	2022-05-12	0
The Asteroid No. 4	16179	2022-05-12	0
Kanye West / Adam Levine	16180	2022-05-12	0
Gemelli Diversi	16181	2022-05-12	0
Royal Philharmonic Orchestra/Sir Thomas Beecham	16182	2022-05-12	0
Juan Habichuela / Manolo Caracol	16183	2022-05-12	0
Ciao Bella	16184	2022-05-12	0
Jasmina Maschina	16185	2022-05-12	0
Karpe Diem	16186	2022-05-12	0
Pat Boone	16187	2022-05-12	0
Pierangelo Bertoli	16188	2022-05-12	0
Biosphere & Higher Intelligence Agency	16189	2022-05-12	0
The Takeovers	16190	2022-05-12	0
Draw Me A Cow	16191	2022-05-12	0
The Heptones	16192	2022-05-12	0
Nightsky Bequest	16193	2022-05-12	0
Future Cut	16194	2022-05-12	0
7 Notas 7 Colores	16195	2022-05-12	0
Habib Koite	16196	2022-05-12	0
Ridan	16197	2022-05-12	0
CREMATORY	16198	2022-05-12	0
Teenage Bad Girl	16199	2022-05-12	0
2-Pac	16200	2022-05-12	0
Freddie Cruger	16201	2022-05-12	0
Carlos Bonell	16202	2022-05-12	0
You Dee	16203	2022-05-12	0
Emma	16204	2022-05-12	0
AR Rahman	16205	2022-05-12	0
The Wailers	16206	2022-05-12	0
Buffalo Killers	16207	2022-05-12	0
Cut 'N' Move	16208	2022-05-12	0
Lazybatusu	16209	2022-05-12	0
Cross Movement	16210	2022-05-12	0
Bebe Winans / Debra Winans Lowe	16211	2022-05-12	0
Schatsi	16212	2022-05-12	0
Enchant	16213	2022-05-12	0
George Acosta	16214	2022-05-12	0
Herbert Vianna	16215	2022-05-12	0
Belbury Poly	16216	2022-05-12	0
Labyrinth	16217	2022-05-12	0
Brimstone Howl	16218	2022-05-12	0
le Shuuk	16219	2022-05-12	0
Annie Haslam	16220	2022-05-12	0
ZZ Hill	16221	2022-05-12	0
Jill Scott	16222	2022-05-12	0
Post Image	16223	2022-05-12	0
Truls And The Trees	16224	2022-05-12	0
Nautical Almanac	16225	2022-05-12	0
Charlie Winston	16226	2022-05-12	0
The Polyphonic Spree	16227	2022-05-12	0
Bumblefoot	16228	2022-05-12	0
Unruly Child	16229	2022-05-12	0
Target Market	16230	2022-05-12	0
Afrojack	16231	2022-05-12	0
Honeymoon Suite	16232	2022-05-12	0
Harry Nilsson	16233	2022-05-12	0
The Boston Pops Orchestra / John Williams	16234	2022-05-12	0
George Clinton's Family Series Volume 2	16235	2022-05-12	0
Stan Getz & Oscar Peterson	16236	2022-05-12	0
Misconduct	16237	2022-05-12	0
Fifth Hour Hero	16238	2022-05-12	0
Rhythm Heritage	16239	2022-05-12	0
Dave Audé	16240	2022-05-12	0
Harold Budd	16241	2022-05-12	0
Sense Field	16242	2022-05-12	0
C-Murder/Master P	16243	2022-05-12	0
Imperials & Stamps Quartet	16244	2022-05-12	0
Ignorance	16245	2022-05-12	0
Desperate Measures	16246	2022-05-12	0
BBE	16247	2022-05-12	0
The Sylvers	16248	2022-05-12	0
Giorgio Moroder / Harold Faltermeyer	16249	2022-05-12	0
Nicola Di Bari	16250	2022-05-12	0
Paul Di'Anno & Dennis Stratton	16251	2022-05-12	0
Angélique Kidjo	16252	2022-05-12	0
Joey Ramone	16253	2022-05-12	0
Eliane Elias	16254	2022-05-12	0
Digitalism	16255	2022-05-12	0
Dead Poetic	16256	2022-05-12	0
Trial By Fire	16257	2022-05-12	0
Fernando Ortega	16258	2022-05-12	0
Wang Chung	16259	2022-05-12	0
The Synthesizer	16260	2022-05-12	0
The DJ Rodriguez	16261	2022-05-12	0
E-Unit featuring Simone K	16262	2022-05-12	0
La Fuga	16263	2022-05-12	0
Vinicius Cantuaria	16264	2022-05-12	0
Anna Ternheim	16265	2022-05-12	0
Bright Light Fever	16266	2022-05-12	0
Rheinallt H. Rowlands	16267	2022-05-12	0
Belle & Sebastian	16268	2022-05-12	0
Lady Laistee	16269	2022-05-12	0
Wendy Phillips	16270	2022-05-12	0
17	16271	2022-05-12	0
The Rippingtons / Russ Freeman	16272	2022-05-12	0
Pink Grease	16273	2022-05-12	0
Janusz Olejniczak	16274	2022-05-12	0
Blood On The Wall	16275	2022-05-12	0
Rokia Traoré	16276	2022-05-12	0
Joe Jackson	16277	2022-05-12	0
Teodoro Reyes	16278	2022-05-12	0
Department of Eagles	16279	2022-05-12	0
Louie Ramirez	16280	2022-05-12	0
Natas	16281	2022-05-12	0
Bandabardò	16282	2022-05-12	0
Dave Dudley	16283	2022-05-12	0
The Lonely Island / Justin Timberlake	16284	2022-05-12	0
B.o.B	16285	2022-05-12	0
Mica Paris	16286	2022-05-12	0
DJ Choose & Michael Splint	16287	2022-05-12	0
Corbin Bleu	16288	2022-05-12	0
Midnight Cowboys_ Midnight Cowboys	16289	2022-05-12	0
Comiccon	16290	2022-05-12	0
Blind Lemon Jefferson	16291	2022-05-12	0
Sessiones Reggae	16292	2022-05-12	0
Hieroglyphics	16293	2022-05-12	0
Blood Red Throne	16294	2022-05-12	0
Katiana	16295	2022-05-12	0
EnMass	16296	2022-05-12	0
The Shadows Of Knight	16297	2022-05-12	0
Storsveit Nix Noltes	16298	2022-05-12	0
Zaïko Langa-Langa	16299	2022-05-12	0
Duo Dinamico	16300	2022-05-12	0
The Vagrants	16301	2022-05-12	0
Queen Latifah	16302	2022-05-12	0
keller williams	16303	2022-05-12	0
Jive Bunny	16304	2022-05-12	0
Stacy Lattisaw	16305	2022-05-12	0
Panda	16306	2022-05-12	0
Freak Nasty AKA Big Easy	16307	2022-05-12	0
Boris the Sprinkler	16308	2022-05-12	0
Cassius	16309	2022-05-12	0
Jordan_ Louis	16310	2022-05-12	0
The Idle Race	16311	2022-05-12	0
Natural High	16312	2022-05-12	0
Mitch Hedberg	16313	2022-05-12	0
Erik Og Kriss	16314	2022-05-12	0
Clarence Profit	16315	2022-05-12	0
Racetrack Babies	16316	2022-05-12	0
Earl Klugh	16317	2022-05-12	0
impulsonic	16318	2022-05-12	0
Lazard	16319	2022-05-12	0
Deep Puddle Dynamics	16320	2022-05-12	0
Dead Voices On Air Versus Not Breathing	16321	2022-05-12	0
Craig Wedren	16322	2022-05-12	0
Olivia Newton-John	16323	2022-05-12	0
Ras Shiloh	16324	2022-05-12	0
Jem	16325	2022-05-12	0
Ann Lee	16326	2022-05-12	0
Chakra's Dream	16327	2022-05-12	0
LOOK DAGGERS	16328	2022-05-12	0
The J. Geils Band	16329	2022-05-12	0
Louis Smith	16330	2022-05-12	0
The Firesign Theatre	16331	2022-05-12	0
Eddie Jones	16332	2022-05-12	0
Junior Boys	16333	2022-05-12	0
The Yellow Press	16334	2022-05-12	0
Blues	16335	2022-05-12	0
Charlie Wilson & His Hillbillies	16336	2022-05-12	0
Peter Hammill	16337	2022-05-12	0
Eric Idle	16338	2022-05-12	0
Carnival in Coal	16339	2022-05-12	0
Vinícius de Moraes	16340	2022-05-12	0
Rednex	16341	2022-05-12	0
The Comfies	16342	2022-05-12	0
Scott Joplin	16343	2022-05-12	0
Tangle Edge	16344	2022-05-12	0
Victoria Williams	16345	2022-05-12	0
Theory Of A Deadman	16346	2022-05-12	0
Liquid Trio Experiment	16347	2022-05-12	0
Flairs	16348	2022-05-12	0
Heather Headley	16349	2022-05-12	0
Bobby Darin	16350	2022-05-12	0
Dance Gavin Dance	16351	2022-05-12	0
Guido & Maurizio De Angelis	16352	2022-05-12	0
A-Mei	16353	2022-05-12	0
1980/81 Cup Final Squad_ Chas & Dave	16354	2022-05-12	0
Pólo Norte;Miguel Angelo	16355	2022-05-12	0
Golden Bug	16356	2022-05-12	0
Gotthard	16357	2022-05-12	0
Lords Of Acid	16358	2022-05-12	0
Paul Avgerinos	16359	2022-05-12	0
Jody McBrayer	16360	2022-05-12	0
Ian Gillan	16361	2022-05-12	0
Yello / Stina Nordenstam	16362	2022-05-12	0
Mick Farren	16363	2022-05-12	0
The Chariot	16364	2022-05-12	0
Tears For Fears	16365	2022-05-12	0
Coronatus	16366	2022-05-12	0
You Say Party! We Say Die!	16367	2022-05-12	0
Ursula 1000	16368	2022-05-12	0
The Litter	16369	2022-05-12	0
Moi Caprice	16370	2022-05-12	0
Glenn Medeiros	16371	2022-05-12	0
La Victoria de Mexico	16372	2022-05-12	0
Rooney	16373	2022-05-12	0
Vikki Carr	16374	2022-05-12	0
Snake Sedrick	16375	2022-05-12	0
Frank Bretschneider	16376	2022-05-12	0
S.S. Bumblebee	16377	2022-05-12	0
The Late B.P. Helium	16378	2022-05-12	0
Danny Diablo	16379	2022-05-12	0
Jose Menese	16380	2022-05-12	0
The Pipettes	16381	2022-05-12	0
Cæcilie Norby	16382	2022-05-12	0
Spencer Davis Group	16383	2022-05-12	0
Mariana Aydar	16384	2022-05-12	0
Vincent Oliver	16385	2022-05-12	0
Danielle Dax	16386	2022-05-12	0
Gustavo Santaolalla	16387	2022-05-12	0
Agent Orange	16388	2022-05-12	0
Autograph	16389	2022-05-12	0
Danko Jones	16390	2022-05-12	0
Pirkka-Pekka Petelius	16391	2022-05-12	0
Gillan	16392	2022-05-12	0
Jetboy	16393	2022-05-12	0
Bellini	16394	2022-05-12	0
Maria Bethânia	16395	2022-05-12	0
The Biddu Orchestra	16396	2022-05-12	0
Bryan Adams & Melanie C	16397	2022-05-12	0
Sergio Mendes	16398	2022-05-12	0
Onward To Olympas	16399	2022-05-12	0
Menage A 3 (mano Kid Mesa)	16400	2022-05-12	0
Bugz In The Attic	16401	2022-05-12	0
Kim Leoni	16402	2022-05-12	0
Constance Demby	16403	2022-05-12	0
Soul G And Tony Match	16404	2022-05-12	0
Telex	16405	2022-05-12	0
Mike Patton	16406	2022-05-12	0
Number Twelve Looks Like You	16407	2022-05-12	0
Marcus	16408	2022-05-12	0
Himekami	16409	2022-05-12	0
Mr. SOS	16410	2022-05-12	0
Juelz Santana_ Lil Wayne	16411	2022-05-12	0
King B.A.V.	16412	2022-05-12	0
XIU XIU	16413	2022-05-12	0
Dion & The Belmonts	16414	2022-05-12	0
Carly Binding	16415	2022-05-12	0
The Hookers	16416	2022-05-12	0
Armin Van Buuren vs M.I.K.E.	16417	2022-05-12	0
Dj Sammy	16418	2022-05-12	0
Yma Sumac	16419	2022-05-12	0
The Hellacopters	16420	2022-05-12	0
Joy Zipper	16421	2022-05-12	0
The Cribs	16422	2022-05-12	0
SO SO Modern	16423	2022-05-12	0
Harry Chapin	16424	2022-05-12	0
Dúo Cadenza	16425	2022-05-12	0
Steve Lacy / Don Cherry	16426	2022-05-12	0
LMNO & Kev Brown	16427	2022-05-12	0
Dinah Washington	16428	2022-05-12	0
Jozif	16429	2022-05-12	0
Diomedes Diaz & Ivan Zuleta	16430	2022-05-12	0
Anita Harris	16431	2022-05-12	0
Agua Loca	16432	2022-05-12	0
Cosmosis	16433	2022-05-12	0
Lightning Seeds	16434	2022-05-12	0
Polkaholix	16435	2022-05-12	0
V	16436	2022-05-12	0
Nikolaus Harnoncourt and Concentus musicus Wien	16437	2022-05-12	0
Space Cat Vs. Onyx	16438	2022-05-12	0
Baton Rouge	16439	2022-05-12	0
Lusine	16440	2022-05-12	0
Freddy Fresh	16441	2022-05-12	0
Television Room	16442	2022-05-12	0
Louise Goffin	16443	2022-05-12	0
Nancys Rubias	16444	2022-05-12	0
Franz Waxman	16445	2022-05-12	0
Chillin' Room	16446	2022-05-12	0
Lily Allen	16447	2022-05-12	0
Rush	16448	2022-05-12	0
Tokyo Police Club	16449	2022-05-12	0
Cornel Campbell	16450	2022-05-12	0
Zhané	16451	2022-05-12	0
DJ Mehdi	16452	2022-05-12	0
UNKLE	16453	2022-05-12	0
Univers Zero	16454	2022-05-12	0
Leslie Phillips	16455	2022-05-12	0
Dale Hawkins	16456	2022-05-12	0
Soundisciples	16457	2022-05-12	0
Lee Andrews And The Hearts	16458	2022-05-12	0
Maria Callas	16459	2022-05-12	0
Toxic Narcotic	16460	2022-05-12	0
Arja Saijonmaa	16461	2022-05-12	0
The Nerves	16462	2022-05-12	0
Cassie Davis	16463	2022-05-12	0
Crea	16464	2022-05-12	0
Stellamara	16465	2022-05-12	0
Basement Jaxx	16466	2022-05-12	0
First Choice	16467	2022-05-12	0
The Big Pink	16468	2022-05-12	0
Isaacs	16469	2022-05-12	0
Lady Sovereign	16470	2022-05-12	0
Daevid Allen	16471	2022-05-12	0
Lorie	16472	2022-05-12	0
The Wilmington Chester Mass Choir	16473	2022-05-12	0
The Beyoncé Experience	16474	2022-05-12	0
X Marks The Pedwalk	16475	2022-05-12	0
Furry Phreaks feat. Terra Deva	16476	2022-05-12	0
Bobby Watson	16477	2022-05-12	0
Make Good Your Escape	16478	2022-05-12	0
J. Geils Band	16479	2022-05-12	0
The Most Serene Republic	16480	2022-05-12	0
Eric Burdon	16481	2022-05-12	0
Agnostic Front	16482	2022-05-12	0
Please Step Out Of The Vehicle	16483	2022-05-12	0
CHET LAM	16484	2022-05-12	0
Ruoska	16485	2022-05-12	0
NU VIRGOS	16486	2022-05-12	0
Bonita	16487	2022-05-12	0
Opus III	16488	2022-05-12	0
Jadell	16489	2022-05-12	0
Stress Assassin	16490	2022-05-12	0
Clear Blue Sky	16491	2022-05-12	0
Fairmont	16492	2022-05-12	0
Wailing Souls	16493	2022-05-12	0
Fake Problems	16494	2022-05-12	0
Sarah Cracknell	16495	2022-05-12	0
The Bronx Horns	16496	2022-05-12	0
Adequate Seven	16497	2022-05-12	0
Los Llayras	16498	2022-05-12	0
Sabda Brahma	16499	2022-05-12	0
k.d. lang	16500	2022-05-12	0
Chop Black	16501	2022-05-12	0
Susie Arioli	16502	2022-05-12	0
The Booth Brothers	16503	2022-05-12	0
Ganjaman & Floe Flex	16504	2022-05-12	0
Aelian	16505	2022-05-12	0
Atreyu	16506	2022-05-12	0
Popperklopper	16507	2022-05-12	0
Wildbirds & Peacedrums	16508	2022-05-12	0
Jimmy Roses	16509	2022-05-12	0
Pop Noir	16510	2022-05-12	0
Andrea True Connection	16511	2022-05-12	0
A.P.A.	16512	2022-05-12	0
Mark Ronson	16513	2022-05-12	0
Fromwood	16514	2022-05-12	0
Sam Mosley And Bob Johnson	16515	2022-05-12	0
The Flying Pickets	16516	2022-05-12	0
Charlotte Church	16517	2022-05-12	0
Rachel Harrington	16518	2022-05-12	0
Marisa Monte	16519	2022-05-12	0
Lions At Your Door	16520	2022-05-12	0
Miam Monster Miam	16521	2022-05-12	0
Dele Sosimi	16522	2022-05-12	0
Rico Rodriguez	16523	2022-05-12	0
Falsalarma	16524	2022-05-12	0
The Glass	16525	2022-05-12	0
Woody Herman & Orchestra	16526	2022-05-12	0
Steve Marriott	16527	2022-05-12	0
Hank Thompson And His Brazos Valley Boys	16528	2022-05-12	0
Kasso	16529	2022-05-12	0
A Room With A View	16530	2022-05-12	0
Tower Of Power	16531	2022-05-12	0
Hans De Booij	16532	2022-05-12	0
The Antlers	16533	2022-05-12	0
Esquivel	16534	2022-05-12	0
The Rain Parade	16535	2022-05-12	0
Tiefighter	16536	2022-05-12	0
Judy Garland_ Johnny Mercer	16537	2022-05-12	0
Andrea Parker	16538	2022-05-12	0
Aloha	16539	2022-05-12	0
The Fair Sex	16540	2022-05-12	0
The Platters	16541	2022-05-12	0
Del Reeves	16542	2022-05-12	0
Suthun Boy	16543	2022-05-12	0
The Samples	16544	2022-05-12	0
Bernard Fevre	16545	2022-05-12	0
Kris Kristofferson	16546	2022-05-12	0
Mindy McCready	16547	2022-05-12	0
Joe Strummer	16548	2022-05-12	0
David Wilcox	16549	2022-05-12	0
Ronski Speed	16550	2022-05-12	0
SeepeopleS	16551	2022-05-12	0
Herb Alpert And The Tijuana Brass	16552	2022-05-12	0
The Dave Brubeck ...	16553	2022-05-12	0
Maxine Brown	16554	2022-05-12	0
Charlie Haden	16555	2022-05-12	0
Turing Machine	16556	2022-05-12	0
Duchess Says	16557	2022-05-12	0
La Húngara	16558	2022-05-12	0
Charlie Haden / Tanya Haden	16559	2022-05-12	0
Wooden Wand_ The Omen Bones Band	16560	2022-05-12	0
ESG	16561	2022-05-12	0
Men_ Women & Children	16562	2022-05-12	0
Patricia Manterola	16563	2022-05-12	0
Erich Wolfgang Korngold	16564	2022-05-12	0
Masif DJs	16565	2022-05-12	0
Fred Locks	16566	2022-05-12	0
Klaus Badelt	16567	2022-05-12	0
No se lo digas a mama	16568	2022-05-12	0
Rudy Vallee	16569	2022-05-12	0
Sibongile Khumalo	16570	2022-05-12	0
Me'Shell Ndegeocello	16571	2022-05-12	0
Filippos Pliatsikas/Orhistra Sighronis Mousikis Tis ERT	16572	2022-05-12	0
Winston McAnuff	16573	2022-05-12	0
DEW-SCENTED	16574	2022-05-12	0
Oysterband	16575	2022-05-12	0
C.C.C.C.	16576	2022-05-12	0
Ani DiFranco	16577	2022-05-12	0
PP Arnold	16578	2022-05-12	0
The Crash	16579	2022-05-12	0
Harry Gregson-Williams_ John Powell	16580	2022-05-12	0
Shato	16581	2022-05-12	0
Jaci Velasquez	16582	2022-05-12	0
Heaven Shall Burn	16583	2022-05-12	0
Mum	16584	2022-05-12	0
Hello Goodbye	16585	2022-05-12	0
Everything Must Go	16586	2022-05-12	0
Steve Aoki	16587	2022-05-12	0
Kon Kan	16588	2022-05-12	0
Frank Boeijen	16589	2022-05-12	0
Gloria Lasso	16590	2022-05-12	0
María Elena Walsh	16591	2022-05-12	0
Caramba!	16592	2022-05-12	0
Lunachicks	16593	2022-05-12	0
Box	16594	2022-05-12	0
Chris Thomas King	16595	2022-05-12	0
Capercaillie	16596	2022-05-12	0
IndX	16597	2022-05-12	0
Whitechapel	16598	2022-05-12	0
The Invaders	16599	2022-05-12	0
Röyksopp	16600	2022-05-12	0
Yo-Yo Ma;David Zinman;Philadelphia Orchestra	16601	2022-05-12	0
Don Howland	16602	2022-05-12	0
a1	16603	2022-05-12	0
Blake Lewis	16604	2022-05-12	0
Richard In Your Mind	16605	2022-05-12	0
Guadalupe Pineda with Trio Los Soberanos	16606	2022-05-12	0
Grimple	16607	2022-05-12	0
Pure Pleazure	16608	2022-05-12	0
Yellowjackets	16609	2022-05-12	0
Fernanda Porto	16610	2022-05-12	0
El Tigrillo Palma	16611	2022-05-12	0
The Gear	16612	2022-05-12	0
David Meece	16613	2022-05-12	0
The Railway Children	16614	2022-05-12	0
Through the Eyes of the Dead	16615	2022-05-12	0
MC Mack	16616	2022-05-12	0
Modern Romance featuring John Du Prez	16617	2022-05-12	0
Tabula Rasa	16618	2022-05-12	0
Throw That Beat In The Garbagecan!	16619	2022-05-12	0
Halo Friendlies	16620	2022-05-12	0
Paul McLaney	16621	2022-05-12	0
RCola	16622	2022-05-12	0
The Royal Philharmonic Orchestra	16623	2022-05-12	0
Stahlhammer	16624	2022-05-12	0
Nichole Nordeman	16625	2022-05-12	0
The 3rd	16626	2022-05-12	0
Greg Laswell	16627	2022-05-12	0
Garland Jeffreys	16628	2022-05-12	0
Ferrante & Teicher	16629	2022-05-12	0
Nick Gravenites	16630	2022-05-12	0
Ignacio Peña	16631	2022-05-12	0
Sally & Vip-R	16632	2022-05-12	0
Matchbook Romance	16633	2022-05-12	0
Nodes Of Ranvier	16634	2022-05-12	0
Lynn Anderson	16635	2022-05-12	0
Will Young	16636	2022-05-12	0
The Fresh & Onlys	16637	2022-05-12	0
Alan Sorrenti	16638	2022-05-12	0
Mob Figaz	16639	2022-05-12	0
Thee Fine Lines	16640	2022-05-12	0
BlackBud	16641	2022-05-12	0
Adam Lambert	16642	2022-05-12	0
Jack DeJohnette_ John Abercrombie	16643	2022-05-12	0
Wall Of Voodoo	16644	2022-05-12	0
Åge Aleksandersen	16645	2022-05-12	0
Mostar Sevdah	16646	2022-05-12	0
Flame	16647	2022-05-12	0
Jack Radics	16648	2022-05-12	0
Mew	16649	2022-05-12	0
Hybrid	16650	2022-05-12	0
Marc Lavoine;Catherine Ringer	16651	2022-05-12	0
David West	16652	2022-05-12	0
Kansas City Kitty & Georgia Tom	16653	2022-05-12	0
Blackalicious	16654	2022-05-12	0
Baseball Furies	16655	2022-05-12	0
U Roy	16656	2022-05-12	0
Ashley Hutchings	16657	2022-05-12	0
Bebi Dol	16658	2022-05-12	0
Larkin Grimm	16659	2022-05-12	0
Nancy Ajram	16660	2022-05-12	0
James Morrison	16661	2022-05-12	0
Wayne Toups	16662	2022-05-12	0
Johnny Clarke	16663	2022-05-12	0
Wicked Jazz Sounds Band	16664	2022-05-12	0
J.Rawls & John Robinson are Jay Are	16665	2022-05-12	0
Anael Miller	16666	2022-05-12	0
She's Spanish_ I'm American	16667	2022-05-12	0
Lucha Reyes	16668	2022-05-12	0
The Adverts	16669	2022-05-12	0
Eurogliders	16670	2022-05-12	0
Lobi Traore	16671	2022-05-12	0
Al Kooper	16672	2022-05-12	0
Cowboy Mouth	16673	2022-05-12	0
Martin Eyerer	16674	2022-05-12	0
Naughty By Nature	16675	2022-05-12	0
Grave Plott	16676	2022-05-12	0
Kashief Lindo	16677	2022-05-12	0
Lise Westzynthius	16678	2022-05-12	0
(Hed) Planet Earth	16679	2022-05-12	0
Bill Cosby	16680	2022-05-12	0
Sam Paglia	16681	2022-05-12	0
candycream	16682	2022-05-12	0
John Birch	16683	2022-05-12	0
Deana Carter	16684	2022-05-12	0
John Abercrombie_ Mark Feldman_ Joey Baron_ Marc Johnson	16685	2022-05-12	0
Maggot Brain	16686	2022-05-12	0
Kid Massive	16687	2022-05-12	0
Idris Muhammad	16688	2022-05-12	0
Soil & Eclipse	16689	2022-05-12	0
Roey Marquis II.	16690	2022-05-12	0
Farrah	16691	2022-05-12	0
Ohlson har semester production	16692	2022-05-12	0
Eye To Eye	16693	2022-05-12	0
Copperhead	16694	2022-05-12	0
Unitus	16695	2022-05-12	0
Owls	16696	2022-05-12	0
EVERMORE	16697	2022-05-12	0
M	16698	2022-05-12	0
Jammin J	16699	2022-05-12	0
Bobby Short	16700	2022-05-12	0
Mantus	16701	2022-05-12	0
Frenzal Rhomb	16702	2022-05-12	0
Vorsprung Durch Technik	16703	2022-05-12	0
Malcolm Middleton	16704	2022-05-12	0
Legs on Earth	16705	2022-05-12	0
Eddie "Cleanhead" Vinson & The Young Blues Thrillers	16706	2022-05-12	0
Jorge Bolet	16707	2022-05-12	0
Lefties Soul Connection	16708	2022-05-12	0
Juan Diego Flórez / Fort Worth Symphony Orchestra / Miguel Harth-Bedoya	16709	2022-05-12	0
Blood_ Sweat & Tears	16710	2022-05-12	0
Sieg Über Die Sonne	16711	2022-05-12	0
Municipal Waste	16712	2022-05-12	0
Youves	16713	2022-05-12	0
Spandau Ballet	16714	2022-05-12	0
Giovanni Battista Pergolesi	16715	2022-05-12	0
Little Walter	16716	2022-05-12	0
Tea Leaf Green	16717	2022-05-12	0
Enya	16718	2022-05-12	0
Downhere	16719	2022-05-12	0
Romain Humeau	16720	2022-05-12	0
Fine Taste	16721	2022-05-12	0
Yonder Mountain String Band	16722	2022-05-12	0
Misty's Big Adventure	16723	2022-05-12	0
Poco	16724	2022-05-12	0
Rick Braun	16725	2022-05-12	0
Wonders	16726	2022-05-12	0
Big L / Tupac Shakur	16727	2022-05-12	0
Wintch Mob	16728	2022-05-12	0
Gemini	16729	2022-05-12	0
Quinoline Yellow	16730	2022-05-12	0
KiRA & James Warren featuring Rachel Lamb	16731	2022-05-12	0
French Possession	16732	2022-05-12	0
Freak Nasty	16733	2022-05-12	0
Burro Banton	16734	2022-05-12	0
Legacy Five	16735	2022-05-12	0
Upsilon Acrux	16736	2022-05-12	0
Evbointh	16737	2022-05-12	0
Igor Stravinsky	16738	2022-05-12	0
Florence + The Machine	16739	2022-05-12	0
Benzino	16740	2022-05-12	0
Francesco Currà	16741	2022-05-12	0
Up-Tight	16742	2022-05-12	0
Diamanda Galas	16743	2022-05-12	0
Geggy Tah	16744	2022-05-12	0
Project Pat	16745	2022-05-12	0
Bill Evans / Jim Hall	16746	2022-05-12	0
Shelby Lynne	16747	2022-05-12	0
The Deviants	16748	2022-05-12	0
CONSOLE	16749	2022-05-12	0
The Murmaids	16750	2022-05-12	0
Count Zero	16751	2022-05-12	0
Shark Island	16752	2022-05-12	0
Ebola	16753	2022-05-12	0
LSG	16754	2022-05-12	0
DJ Quik	16755	2022-05-12	0
Osvaldo Nugroho	16756	2022-05-12	0
Asha Bhosle	16757	2022-05-12	0
Harmful	16758	2022-05-12	0
Chi-AD	16759	2022-05-12	0
Thompson Twins	16760	2022-05-12	0
Tyrannosaurus Rex	16761	2022-05-12	0
Sun Eats Hours	16762	2022-05-12	0
Leo García	16763	2022-05-12	0
Sam The Sham & The Pharaohs	16764	2022-05-12	0
Duncan Dhu	16765	2022-05-12	0
B.J. THOMAS	16766	2022-05-12	0
El Matador	16767	2022-05-12	0
Burning Image	16768	2022-05-12	0
Electro All-Stars	16769	2022-05-12	0
Badly Drawn Boy	16770	2022-05-12	0
Cliff Richard	16771	2022-05-12	0
Virus	16772	2022-05-12	0
2002	16773	2022-05-12	0
Friends Of Dean Martinez	16774	2022-05-12	0
Lester Flatt;Earl Scruggs	16775	2022-05-12	0
Kolombo	16776	2022-05-12	0
Kristian Meurman	16777	2022-05-12	0
Ravesquad	16778	2022-05-12	0
Fran Perea	16779	2022-05-12	0
Robert Armani	16780	2022-05-12	0
Booker T. & The M.G.'s	16781	2022-05-12	0
Martin Devaney	16782	2022-05-12	0
The Four Pennies	16783	2022-05-12	0
Chieko Kinbara	16784	2022-05-12	0
David Benoit	16785	2022-05-12	0
Olivier Messiaen	16786	2022-05-12	0
Vip$	16787	2022-05-12	0
4 M International	16788	2022-05-12	0
Vincent de Jager	16789	2022-05-12	0
Vaquero	16790	2022-05-12	0
Phil Lesh & Friends	16791	2022-05-12	0
Nick Straker	16792	2022-05-12	0
Austin Collins	16793	2022-05-12	0
Doc Watson	16794	2022-05-12	0
LTJ X-Perience	16795	2022-05-12	0
Alex Bueno	16796	2022-05-12	0
Echt!	16797	2022-05-12	0
Dorinda Clark-Cole	16798	2022-05-12	0
Slim Cessna's Auto Club	16799	2022-05-12	0
Janis Ian	16800	2022-05-12	0
Skeletal Family	16801	2022-05-12	0
Cornell Campbell	16802	2022-05-12	0
The Soundtrack Of Our Lives (OEOC)	16803	2022-05-12	0
Stef Der Crashtest	16804	2022-05-12	0
Dearestazazel	16805	2022-05-12	0
Scissors for Sparrow	16806	2022-05-12	0
The Searchers	16807	2022-05-12	0
Fatima Spar Und Die Freedom Fries	16808	2022-05-12	0
The Oppressed	16809	2022-05-12	0
Jim Hart's Gemini	16810	2022-05-12	0
Mike Griffin & The Unknown Blues Band	16811	2022-05-12	0
Aes Dana	16812	2022-05-12	0
THOMAS DATT	16813	2022-05-12	0
5th Ward Boyz	16814	2022-05-12	0
Justin Currie	16815	2022-05-12	0
Mimi Ibarra	16816	2022-05-12	0
Erik Faber	16817	2022-05-12	0
Metallspürhunde	16818	2022-05-12	0
Party Day	16819	2022-05-12	0
Safri Duo	16820	2022-05-12	0
Johnny Otis	16821	2022-05-12	0
Dominic & Neil Stacey	16822	2022-05-12	0
Lowfish	16823	2022-05-12	0
3rd Force	16824	2022-05-12	0
La Peste	16825	2022-05-12	0
Funabashi feat. Angelina	16826	2022-05-12	0
Precious Bryant	16827	2022-05-12	0
O'Funk'illo	16828	2022-05-12	0
Youp van 't Hek	16829	2022-05-12	0
Moe Tucker	16830	2022-05-12	0
The Levon Helm Band	16831	2022-05-12	0
Gianni Togni	16832	2022-05-12	0
William Orbit	16833	2022-05-12	0
The Miracles	16834	2022-05-12	0
The Esquires	16835	2022-05-12	0
Eddie Harris	16836	2022-05-12	0
Dirty Vegas	16837	2022-05-12	0
Detroit's Most Wanted	16838	2022-05-12	0
Lunik	16839	2022-05-12	0
Miles Hunt	16840	2022-05-12	0
Sandy Bull	16841	2022-05-12	0
Johnny Kidd And The Pirates	16842	2022-05-12	0
Rick Danko	16843	2022-05-12	0
Jump_ Little Children	16844	2022-05-12	0
Viikate	16845	2022-05-12	0
The Chuck Wagon Gang	16846	2022-05-12	0
Afroman	16847	2022-05-12	0
Frank Chacksfield & His Orchestra	16848	2022-05-12	0
Concord Dawn	16849	2022-05-12	0
DZ	16850	2022-05-12	0
Shilts	16851	2022-05-12	0
Richard Thompson / Linda Thompson	16852	2022-05-12	0
Grégory Lemarchal	16853	2022-05-12	0
Eddy Meets Yannah	16854	2022-05-12	0
Lillian Glinn	16855	2022-05-12	0
Valencia	16856	2022-05-12	0
Third Sight	16857	2022-05-12	0
OOO	16858	2022-05-12	0
Hardkandy	16859	2022-05-12	0
James Horner;Rahat Nusrat Fateh Ali Khan	16860	2022-05-12	0
Thomas Dolby	16861	2022-05-12	0
Gerald Albright	16862	2022-05-12	0
Rupert Hine	16863	2022-05-12	0
Tracy Lawrence	16864	2022-05-12	0
Corb Lund	16865	2022-05-12	0
Mavado	16866	2022-05-12	0
Natassa Theodoridou	16867	2022-05-12	0
Ocha la Rocha	16868	2022-05-12	0
PAULA COLE	16869	2022-05-12	0
Dirty Sweet	16870	2022-05-12	0
Angelo Debarre	16871	2022-05-12	0
The Ineffable Orchestra / Irmin Hütter	16872	2022-05-12	0
Taxi Taxi	16873	2022-05-12	0
Billy Gilman	16874	2022-05-12	0
Electric Eels	16875	2022-05-12	0
Bryan Ferry	16876	2022-05-12	0
Laymen Terms	16877	2022-05-12	0
Beardfish	16878	2022-05-12	0
Louise Hoffsten	16879	2022-05-12	0
Lorrie Morgan	16880	2022-05-12	0
YoungBloodZ	16881	2022-05-12	0
Cheri Keaggy	16882	2022-05-12	0
Shape Of Broad Minds feat. Stacy Epps	16883	2022-05-12	0
Zydeco All-Stars	16884	2022-05-12	0
Maylene And The Sons Of Disaster	16885	2022-05-12	0
Big Circo	16886	2022-05-12	0
Thee Silver Mt. Zion Memorial Orchestra & Tra-La-La Band	16887	2022-05-12	0
Directions	16888	2022-05-12	0
Lionrock	16889	2022-05-12	0
Sisqo / Lovher	16890	2022-05-12	0
Extremoduro	16891	2022-05-12	0
El Chaval De La Peca	16892	2022-05-12	0
Sohodolls	16893	2022-05-12	0
Kathleen Madigan	16894	2022-05-12	0
The Mediaeval Baebes	16895	2022-05-12	0
Miossec	16896	2022-05-12	0
Ronnie van Bemmel	16897	2022-05-12	0
The Soundtrack of Our Lives	16898	2022-05-12	0
E-Town Concrete	16899	2022-05-12	0
Souls	16900	2022-05-12	0
Vordul Mega	16901	2022-05-12	0
Virus Syndicate	16902	2022-05-12	0
A-Ha	16903	2022-05-12	0
Don Dixon	16904	2022-05-12	0
Technoboy Feat. Shayla	16905	2022-05-12	0
Fennesz	16906	2022-05-12	0
Edaline	16907	2022-05-12	0
John Lennon	16908	2022-05-12	0
The Original Broadway Cast	16909	2022-05-12	0
Charlotte Hatherley	16910	2022-05-12	0
Allison Moorer	16911	2022-05-12	0
Popsicle	16912	2022-05-12	0
The Wellwater Conspiracy	16913	2022-05-12	0
Brother ape	16914	2022-05-12	0
Deas Vail	16915	2022-05-12	0
From Ashes Rise	16916	2022-05-12	0
Thrill Da Playa	16917	2022-05-12	0
Alexander Kowalski	16918	2022-05-12	0
The Great Crusades	16919	2022-05-12	0
Loop Doctors	16920	2022-05-12	0
Ja-Man All Stars	16921	2022-05-12	0
Cross My Heart	16922	2022-05-12	0
Linda Martini	16923	2022-05-12	0
3 Gars Su'l Sofa	16924	2022-05-12	0
Conjunto Chaney	16925	2022-05-12	0
Rio En Medio	16926	2022-05-12	0
Virtuocity	16927	2022-05-12	0
Tiziana Ghiglioni	16928	2022-05-12	0
Greg Ashley	16929	2022-05-12	0
The Melvins	16930	2022-05-12	0
Candy Dulfer	16931	2022-05-12	0
Chris Liebing	16932	2022-05-12	0
Gryphon	16933	2022-05-12	0
Nikola Gala	16934	2022-05-12	0
In Slaughter Natives	16935	2022-05-12	0
Marysia Sadowska	16936	2022-05-12	0
Jeff Foxworthy	16937	2022-05-12	0
Ben Vaughn	16938	2022-05-12	0
Fred Falke	16939	2022-05-12	0
Relient K	16940	2022-05-12	0
Memory Dean	16941	2022-05-12	0
Harmonica Shah	16942	2022-05-12	0
Orleans	16943	2022-05-12	0
Christy Moore	16944	2022-05-12	0
Motehra	16945	2022-05-12	0
The Crusaders	16946	2022-05-12	0
Amy MacDonald	16947	2022-05-12	0
Ringo Starr	16948	2022-05-12	0
Aaron Carter	16949	2022-05-12	0
Miúcha	16950	2022-05-12	0
Paxton	16951	2022-05-12	0
Drupi	16952	2022-05-12	0
Gene Autry	16953	2022-05-12	0
The Apathy Eulogy	16954	2022-05-12	0
Now Is Now	16955	2022-05-12	0
JS16	16956	2022-05-12	0
Vanessa Bell Armstrong	16957	2022-05-12	0
Rosebud	16958	2022-05-12	0
Riva	16959	2022-05-12	0
Smokey Wilson	16960	2022-05-12	0
Mono & Bär	16961	2022-05-12	0
Brainbox	16962	2022-05-12	0
Les Petits Chanteurs de Saint-Marc	16963	2022-05-12	0
Ruff Driverz	16964	2022-05-12	0
Amorphis	16965	2022-05-12	0
Ken Boothe	16966	2022-05-12	0
Scott Henderson	16967	2022-05-12	0
Magnus Carlson	16968	2022-05-12	0
Glossary	16969	2022-05-12	0
Hey Today!	16970	2022-05-12	0
Goa Doc	16971	2022-05-12	0
Toots Thielemans / Elis Regina	16972	2022-05-12	0
The Pribata Idaho	16973	2022-05-12	0
The Remote	16974	2022-05-12	0
Cheus Dj	16975	2022-05-12	0
Renato Russo	16976	2022-05-12	0
Home Town Hero	16977	2022-05-12	0
Q-Tip	16978	2022-05-12	0
Booker T. & The MG's	16979	2022-05-12	0
Rosetta Stone	16980	2022-05-12	0
Rusted Root	16981	2022-05-12	0
Monoral	16982	2022-05-12	0
Hot Buttered Rum	16983	2022-05-12	0
The Manhattans	16984	2022-05-12	0
Nas / The Last Poets	16985	2022-05-12	0
I Walk The Line	16986	2022-05-12	0
Shoestrings	16987	2022-05-12	0
Two Gallants	16988	2022-05-12	0
Bertie Higgins	16989	2022-05-12	0
Barry Adamson	16990	2022-05-12	0
Maynard Ferguson.	16991	2022-05-12	0
Ukulele	16992	2022-05-12	0
Seaweed	16993	2022-05-12	0
Snook	16994	2022-05-12	0
They Might Be Giants	16995	2022-05-12	0
The Walking Ruins	16996	2022-05-12	0
Freddie Roulette	16997	2022-05-12	0
Superbus	16998	2022-05-12	0
Clifton Chenier	16999	2022-05-12	0
Edwin Yearwood feat. Iron Tonque	17000	2022-05-12	0
Soul Avengerz	17001	2022-05-12	0
Pulcher Femina	17002	2022-05-12	0
John Lord Fonda	17003	2022-05-12	0
Emmylou Harris & John Starling	17004	2022-05-12	0
Anita Kerr	17005	2022-05-12	0
Shaila Dúrcal	17006	2022-05-12	0
Lone Kent	17007	2022-05-12	0
Marilyn Crispell	17008	2022-05-12	0
Warne Marsh	17009	2022-05-12	0
Big Black	17010	2022-05-12	0
Big Lou	17011	2022-05-12	0
Trini Lopez	17012	2022-05-12	0
Two Tons of Steel	17013	2022-05-12	0
Bow Wow featuring Young Capone & Cocaine J	17014	2022-05-12	0
Prospekt	17015	2022-05-12	0
Career Soldiers	17016	2022-05-12	0
Pilot Speed	17017	2022-05-12	0
Musetta	17018	2022-05-12	0
Great Big Sea	17019	2022-05-12	0
Three Is A Crowd	17020	2022-05-12	0
Mediengruppe Telekommander	17021	2022-05-12	0
Tony Vega	17022	2022-05-12	0
Male Or Female	17023	2022-05-12	0
Central Living	17024	2022-05-12	0
Marek Grechuta	17025	2022-05-12	0
Alvin Youngblood Hart	17026	2022-05-12	0
Gene Watson	17027	2022-05-12	0
Java	17028	2022-05-12	0
Mark Eteson & Jon Prior	17029	2022-05-12	0
Wilmington Chester Mass Choir	17030	2022-05-12	0
Metropolitan Jazz Affair	17031	2022-05-12	0
Alex Ubago	17032	2022-05-12	0
Nelja Ruusua	17033	2022-05-12	0
Monika Kruse	17034	2022-05-12	0
Mike Post feat. Larry Carlton	17035	2022-05-12	0
Red Alert	17036	2022-05-12	0
Bailter Space	17037	2022-05-12	0
Corey Harris	17038	2022-05-12	0
Stewart Francke	17039	2022-05-12	0
My Life With The Thrill Kill Kult	17040	2022-05-12	0
Sprites	17041	2022-05-12	0
Barry Manilow	17042	2022-05-12	0
Adrienne Pierce	17043	2022-05-12	0
Adam Sandler	17044	2022-05-12	0
Andrews Sisters	17045	2022-05-12	0
Paza Rahm	17046	2022-05-12	0
Mesh	17047	2022-05-12	0
L.E.G.A.C.Y.	17048	2022-05-12	0
Krokodil	17049	2022-05-12	0
Aerosmith / Run D.M.C.	17050	2022-05-12	0
Brook Benton	17051	2022-05-12	0
Kendel Carson	17052	2022-05-12	0
Stargard	17053	2022-05-12	0
Barkays	17054	2022-05-12	0
Eliades Ochoa	17055	2022-05-12	0
Mark Broom	17056	2022-05-12	0
Gabino Pampini	17057	2022-05-12	0
Gary Ferro	17058	2022-05-12	0
Rocky Hill	17059	2022-05-12	0
Jorge Palma	17060	2022-05-12	0
Monks Of Doom	17061	2022-05-12	0
Luk	17062	2022-05-12	0
Josh Ritter	17063	2022-05-12	0
Shocking Pinks	17064	2022-05-12	0
Godhead	17065	2022-05-12	0
Cheb Khaled	17066	2022-05-12	0
Weekend Nachos	17067	2022-05-12	0
Pig Irön	17068	2022-05-12	0
Maggotron	17069	2022-05-12	0
Catatonia	17070	2022-05-12	0
The Fureys	17071	2022-05-12	0
O.V. Wright	17072	2022-05-12	0
Fear My Thoughts	17073	2022-05-12	0
Les Brown	17074	2022-05-12	0
Elemental	17075	2022-05-12	0
Kind of Like Spitting	17076	2022-05-12	0
Andrew Bassie Campbell	17077	2022-05-12	0
Laura Fygi	17078	2022-05-12	0
De Heideroosjes	17079	2022-05-12	0
van Eyden feat. Susanne Webb	17080	2022-05-12	0
Camiel	17081	2022-05-12	0
Patrick Samson	17082	2022-05-12	0
Ramsi Aliani	17083	2022-05-12	0
High Contrast	17084	2022-05-12	0
Vic Chesnutt	17085	2022-05-12	0
Earl Zero_ The Soul Syndicate	17086	2022-05-12	0
Puff Daddy	17087	2022-05-12	0
Arab Strap	17088	2022-05-12	0
Four Piece Suit	17089	2022-05-12	0
Schoolyard Heroes	17090	2022-05-12	0
James William Hindle	17091	2022-05-12	0
Black Rebel Motorcycle Club	17092	2022-05-12	0
The Advent	17093	2022-05-12	0
The Game	17094	2022-05-12	0
Menudo	17095	2022-05-12	0
Jean Shepard	17096	2022-05-12	0
The Dirtball	17097	2022-05-12	0
Sound Team	17098	2022-05-12	0
Kid Loco	17099	2022-05-12	0
Atom And His Package	17100	2022-05-12	0
Hugh Masekela	17101	2022-05-12	0
Saint Louis Symphony Orchestra/Leonard Slatkin	17102	2022-05-12	0
Aaron Sprinkle	17103	2022-05-12	0
Los Soneros Del Barrio	17104	2022-05-12	0
Stanton Moore	17105	2022-05-12	0
Dick Haymes and Dick Haymes	17106	2022-05-12	0
Oliver Koletzki	17107	2022-05-12	0
Saffire	17108	2022-05-12	0
Enrico Ruggeri	17109	2022-05-12	0
John Abercrombie and John Ruocco	17110	2022-05-12	0
Telefon Tel Aviv	17111	2022-05-12	0
Erika	17112	2022-05-12	0
Louis La Roche	17113	2022-05-12	0
Alice In Chains	17114	2022-05-12	0
Cupid feat. Tay-Dizm	17115	2022-05-12	0
Dane Cook	17116	2022-05-12	0
The Supervillains	17117	2022-05-12	0
La Descente Du Coude	17118	2022-05-12	0
A Sunny Day In Glasgow	17119	2022-05-12	0
Schneller Autos Organisation	17120	2022-05-12	0
Blaine L. Reininger	17121	2022-05-12	0
Beam Vs. Cyrus	17122	2022-05-12	0
Killwhitney Dead	17123	2022-05-12	0
Prevail Within	17124	2022-05-12	0
Colm Wilkinson	17125	2022-05-12	0
Dela	17126	2022-05-12	0
David S. Ware Quartet	17127	2022-05-12	0
Skerik's Syncopated Taint Septet	17128	2022-05-12	0
Hawkeye	17129	2022-05-12	0
Panty Lions	17130	2022-05-12	0
Norma Jean Bell feat. Debbie Welch	17131	2022-05-12	0
Margo Smith	17132	2022-05-12	0
Maurice John Vaughn	17133	2022-05-12	0
Lyricson_ Taïro	17134	2022-05-12	0
Klute Ft. Calibre	17135	2022-05-12	0
The Challengers	17136	2022-05-12	0
Chicken Shack / Stan Webb	17137	2022-05-12	0
Heideroosjes	17138	2022-05-12	0
Lil O	17139	2022-05-12	0
Marc Kudisch / Various Artists	17140	2022-05-12	0
Eternal Flight	17141	2022-05-12	0
George Lewis And His New Orleans Stompers	17142	2022-05-12	0
Tim Carroll	17143	2022-05-12	0
RIDDLIN' KIDS	17144	2022-05-12	0
Grande Roses	17145	2022-05-12	0
Perturbazione	17146	2022-05-12	0
Jake Shimabukuro	17147	2022-05-12	0
The Young Knives	17148	2022-05-12	0
Kingdom	17149	2022-05-12	0
Royal Liverpool Philharmonic Orchestra/Libor Pesek	17150	2022-05-12	0
Southwest German Radio Symphony Orchestra	17151	2022-05-12	0
Pete Miser	17152	2022-05-12	0
And Then There Were None	17153	2022-05-12	0
Rachelle Ferrell	17154	2022-05-12	0
Paul Dempsey	17155	2022-05-12	0
Walls Of Jericho	17156	2022-05-12	0
Chris Brown	17157	2022-05-12	0
Stor	17158	2022-05-12	0
Bullitnuts	17159	2022-05-12	0
Yoskar Sarante	17160	2022-05-12	0
The Churchills	17161	2022-05-12	0
Budka Suflera	17162	2022-05-12	0
Spyder D.	17163	2022-05-12	0
Geraldine Hunt feat. Freddie James & Rosalind aka Cheri	17164	2022-05-12	0
David Thomas Broughton	17165	2022-05-12	0
Louis Armstrong	17166	2022-05-12	0
Herbert Knebels Affentheater	17167	2022-05-12	0
Ray Conniff;Billy Butterfield	17168	2022-05-12	0
Vixen	17169	2022-05-12	0
Metal Church	17170	2022-05-12	0
Deerhoof	17171	2022-05-12	0
Lil' Kim (Featuring Carl Thomas)	17172	2022-05-12	0
Hopes Die Last	17173	2022-05-12	0
Slayer	17174	2022-05-12	0
Teenage Jesus_ The Jerks	17175	2022-05-12	0
Microspasmi	17176	2022-05-12	0
Jimmy Thackery And The Drivers	17177	2022-05-12	0
Heir Apparent	17178	2022-05-12	0
Deaf Shepherd	17179	2022-05-12	0
Leroy Hutson	17180	2022-05-12	0
Silvério Pessoa	17181	2022-05-12	0
Amon Düül II	17182	2022-05-12	0
Charlie Haden / Carlos Paredes	17183	2022-05-12	0
Dizzy	17184	2022-05-12	0
Miami Horror	17185	2022-05-12	0
Vonda Shepard	17186	2022-05-12	0
Rauxa	17187	2022-05-12	0
Iron Monkey	17188	2022-05-12	0
The Away Team	17189	2022-05-12	0
Prana	17190	2022-05-12	0
HIM	17191	2022-05-12	0
The Chicharones	17192	2022-05-12	0
Pharaoh Overlord	17193	2022-05-12	0
JoeyStarr	17194	2022-05-12	0
Thorbjørn Risager	17195	2022-05-12	0
Tiles	17196	2022-05-12	0
Peasant	17197	2022-05-12	0
Falling Into Place	17198	2022-05-12	0
La Unión	17199	2022-05-12	0
Queens Club	17200	2022-05-12	0
James Taylor Quartet	17201	2022-05-12	0
Space March	17202	2022-05-12	0
Kris Wadsworth	17203	2022-05-12	0
The Clancy Brothers And Tommy Makem And Their Families	17204	2022-05-12	0
Keith Harling	17205	2022-05-12	0
Steal Vybe	17206	2022-05-12	0
Empire Brass	17207	2022-05-12	0
Neneh Cherry	17208	2022-05-12	0
Otep	17209	2022-05-12	0
The Fairways	17210	2022-05-12	0
Niraj Chag Featuring Faheem Mazhar	17211	2022-05-12	0
Jay Tripwire	17212	2022-05-12	0
Trackheadz	17213	2022-05-12	0
Black Watch Pipes & Drums	17214	2022-05-12	0
Marc Lavoine	17215	2022-05-12	0
Bobo Stenson_ Anders Jormin_ Jon Christensen	17216	2022-05-12	0
Subtara	17217	2022-05-12	0
Fiction 8	17218	2022-05-12	0
Bias B	17219	2022-05-12	0
Mylon LeFevre	17220	2022-05-12	0
The Fiestas	17221	2022-05-12	0
Mission	17222	2022-05-12	0
gsunge vo de 7 Spatze mit Chinderchor	17223	2022-05-12	0
Jesse Mae Hemphill	17224	2022-05-12	0
Cybotron	17225	2022-05-12	0
A.P.E.	17226	2022-05-12	0
Tristania	17227	2022-05-12	0
Karen Jo Fields	17228	2022-05-12	0
The Black Halos	17229	2022-05-12	0
Majke	17230	2022-05-12	0
Major League	17231	2022-05-12	0
Loco Zydeco	17232	2022-05-12	0
Dabrye	17233	2022-05-12	0
Voice Of A Generation	17234	2022-05-12	0
+ / - {Plus/Minus}	17235	2022-05-12	0
TEN MADISON	17236	2022-05-12	0
Sidi Omar	17237	2022-05-12	0
Litto Nebbia	17238	2022-05-12	0
Doppler Effect	17239	2022-05-12	0
Playa Fly	17240	2022-05-12	0
Big Maybelle	17241	2022-05-12	0
Fastball	17242	2022-05-12	0
Jean-Claude Pascal	17243	2022-05-12	0
Grupo De Expertos Solynieve	17244	2022-05-12	0
A&E	17245	2022-05-12	0
Joe Williams	17246	2022-05-12	0
Velvet Belly	17247	2022-05-12	0
Amistades Peligrosas	17248	2022-05-12	0
Coldcut feat. John Matthias	17249	2022-05-12	0
Fidel Nadal	17250	2022-05-12	0
Thee Flanders	17251	2022-05-12	0
Ray Charles	17252	2022-05-12	0
Rocé	17253	2022-05-12	0
Linda Hopkins	17254	2022-05-12	0
Agnieszka Chylinska	17255	2022-05-12	0
Nappy Roots	17256	2022-05-12	0
Diego el Cigala	17257	2022-05-12	0
The Falcon	17258	2022-05-12	0
NY Loose	17259	2022-05-12	0
Sting	17260	2022-05-12	0
Setrise	17261	2022-05-12	0
Slowdive	17262	2022-05-12	0
Cursed	17263	2022-05-12	0
Sarah Masen	17264	2022-05-12	0
ASP	17265	2022-05-12	0
Skaos	17266	2022-05-12	0
Bunji Garlin	17267	2022-05-12	0
Patric C	17268	2022-05-12	0
Murder At The Registry	17269	2022-05-12	0
Floyd Dixon	17270	2022-05-12	0
Nação Zumbi	17271	2022-05-12	0
Sugarloaf	17272	2022-05-12	0
Shinichi Osawa	17273	2022-05-12	0
Billie Holiday_ Lester Young	17274	2022-05-12	0
Head East	17275	2022-05-12	0
Mons Leidvin Takle	17276	2022-05-12	0
Zizi Possi	17277	2022-05-12	0
Robert Ffrench	17278	2022-05-12	0
The Ballad Bombs	17279	2022-05-12	0
Vice Squad	17280	2022-05-12	0
Sioen	17281	2022-05-12	0
Margie Bermejo	17282	2022-05-12	0
Rod Taylor	17283	2022-05-12	0
Bitter:Sweet	17284	2022-05-12	0
Subsonic Park	17285	2022-05-12	0
THE 69  EYES	17286	2022-05-12	0
Haj Ghorban Soleimani	17287	2022-05-12	0
The Nectarine No. 9	17288	2022-05-12	0
2 Minutos	17289	2022-05-12	0
Lucille Bogan	17290	2022-05-12	0
Damae feat. Londonbeat	17291	2022-05-12	0
Glen Brown / King Tubby	17292	2022-05-12	0
The Paynes	17293	2022-05-12	0
Mr.Cheeks	17294	2022-05-12	0
At The Drive-In	17295	2022-05-12	0
R. Kelly	17296	2022-05-12	0
Nelly	17297	2022-05-12	0
Tommy Flanagan & Tommy Cecil	17298	2022-05-12	0
Saru	17299	2022-05-12	0
The Havenots	17300	2022-05-12	0
John Sawyer	17301	2022-05-12	0
Bullet Boys	17302	2022-05-12	0
The Pearlfishers	17303	2022-05-12	0
Toxik	17304	2022-05-12	0
Bastian	17305	2022-05-12	0
Glenn Underground	17306	2022-05-12	0
Teddy Pendergrass	17307	2022-05-12	0
Pat Metheny/Ornette Coleman	17308	2022-05-12	0
Maj karman kauniit kuvat	17309	2022-05-12	0
Tim Knol	17310	2022-05-12	0
Will Holland feat. Line Froyset	17311	2022-05-12	0
The Sculptor	17312	2022-05-12	0
Chixdiggit!	17313	2022-05-12	0
Delbert McClinton	17314	2022-05-12	0
The Pasadenas	17315	2022-05-12	0
Nick Ingman	17316	2022-05-12	0
Rocazino	17317	2022-05-12	0
Marley Marl	17318	2022-05-12	0
King Floyd	17319	2022-05-12	0
Jools Holland	17320	2022-05-12	0
Big Daddy Kinsey	17321	2022-05-12	0
Gala	17322	2022-05-12	0
Electrodomesticos	17323	2022-05-12	0
Professor Nuts	17324	2022-05-12	0
Robben Ford	17325	2022-05-12	0
The Paradigm	17326	2022-05-12	0
Les Valentins	17327	2022-05-12	0
EDGUY	17328	2022-05-12	0
Current 93	17329	2022-05-12	0
The Vindictives	17330	2022-05-12	0
Kool Moe Dee	17331	2022-05-12	0
Karybde & Scylla	17332	2022-05-12	0
Daddy Dog	17333	2022-05-12	0
Sam Mangwana	17334	2022-05-12	0
Katie Noonan	17335	2022-05-12	0
Angélica Maria	17336	2022-05-12	0
Ingenting	17337	2022-05-12	0
St. Vincent	17338	2022-05-12	0
Karat	17339	2022-05-12	0
Straight Outta Junior High	17340	2022-05-12	0
Former Ghosts	17341	2022-05-12	0
Union 13	17342	2022-05-12	0
The Go Faster Nuns	17343	2022-05-12	0
Baumer	17344	2022-05-12	0
Donatella Rettore	17345	2022-05-12	0
Stanley Turrentine	17346	2022-05-12	0
The Christmas Jug Band	17347	2022-05-12	0
Elliott Sharp`s Terraplane	17348	2022-05-12	0
Broadfield Marchers	17349	2022-05-12	0
Ganz Schön Feist	17350	2022-05-12	0
Sean Na Na	17351	2022-05-12	0
Dadajugend polyform	17352	2022-05-12	0
Trance Atlantic Air Waves	17353	2022-05-12	0
The Telescopes	17354	2022-05-12	0
Soldiers of Twilight	17355	2022-05-12	0
Lostprophets	17356	2022-05-12	0
The Rah Band	17357	2022-05-12	0
Holy Fuck	17358	2022-05-12	0
Tout Simplement Noir	17359	2022-05-12	0
Oojami	17360	2022-05-12	0
Slim Harpo	17361	2022-05-12	0
The Highway QC's	17362	2022-05-12	0
Kaskade	17363	2022-05-12	0
Valley of the Giants	17364	2022-05-12	0
The White Octave	17365	2022-05-12	0
Lullabye Arkestra	17366	2022-05-12	0
Rubén González	17367	2022-05-12	0
Diatribe	17368	2022-05-12	0
Jeffrey Osborne	17369	2022-05-12	0
Mark Schultz	17370	2022-05-12	0
Albert Ayler	17371	2022-05-12	0
Jacks Of All Trades	17372	2022-05-12	0
Jill Phillips	17373	2022-05-12	0
Afrika Bambaataa & The Soul Sonic Force	17374	2022-05-12	0
Chris Rodriguez	17375	2022-05-12	0
Magnate Y Valentino	17376	2022-05-12	0
Project Jenny_ Project Jan	17377	2022-05-12	0
Point	17378	2022-05-12	0
Monkey Business	17379	2022-05-12	0
MC Harras & The Sendling 70 Pussy Riders	17380	2022-05-12	0
glisten	17381	2022-05-12	0
George Hales	17382	2022-05-12	0
K-Otix	17383	2022-05-12	0
Yölintu	17384	2022-05-12	0
Jade	17385	2022-05-12	0
Ocho y Media	17386	2022-05-12	0
The Pernice Brothers	17387	2022-05-12	0
Celso Fonseca	17388	2022-05-12	0
Nek	17389	2022-05-12	0
Boys Noize	17390	2022-05-12	0
Peter Pupping	17391	2022-05-12	0
The Secret Handshake	17392	2022-05-12	0
Keith Emerson	17393	2022-05-12	0
The Blue Bloods	17394	2022-05-12	0
Sing-Sing	17395	2022-05-12	0
Mannheim Steamroller	17396	2022-05-12	0
IAMX	17397	2022-05-12	0
Arpeggiators	17398	2022-05-12	0
Loefah	17399	2022-05-12	0
Senking	17400	2022-05-12	0
Iggy And The Stooges	17401	2022-05-12	0
Jim Bryson	17402	2022-05-12	0
Judy Kuhn	17403	2022-05-12	0
Billy Preston	17404	2022-05-12	0
Youthmovie Soundtrack Strategies	17405	2022-05-12	0
Splodgenessabounds	17406	2022-05-12	0
The Exciters	17407	2022-05-12	0
Sukhbir	17408	2022-05-12	0
The Number Twelve Looks Like You	17409	2022-05-12	0
Alannah Myles	17410	2022-05-12	0
Pat Krimson	17411	2022-05-12	0
Luni Coleone	17412	2022-05-12	0
Shadowfax	17413	2022-05-12	0
Tom Petty And The Heartbreakers / Stevie Nicks	17414	2022-05-12	0
Michael E. Johnson and The Killer Bees	17415	2022-05-12	0
Ricardo Aguirre	17416	2022-05-12	0
Gaudi + Nusrat Fateh Ali Khan	17417	2022-05-12	0
Sir Thomas Allen/Endellion String Quartet	17418	2022-05-12	0
Mondo Marcio	17419	2022-05-12	0
Hagen Rether	17420	2022-05-12	0
King Kapisi	17421	2022-05-12	0
Hazard	17422	2022-05-12	0
Diplo	17423	2022-05-12	0
Like Honey	17424	2022-05-12	0
Chromeo	17425	2022-05-12	0
Elan	17426	2022-05-12	0
The Low Frequency In Stereo	17427	2022-05-12	0
The Gurus	17428	2022-05-12	0
Modern Talking	17429	2022-05-12	0
Arnej	17430	2022-05-12	0
Primordial	17431	2022-05-12	0
Ariel	17432	2022-05-12	0
Evie	17433	2022-05-12	0
POLINA	17434	2022-05-12	0
Seachange	17435	2022-05-12	0
DARK ROOM NOTES	17436	2022-05-12	0
Georgie Fame	17437	2022-05-12	0
The Duckworth Lewis Method	17438	2022-05-12	0
Murcof	17439	2022-05-12	0
King Orgasmus One	17440	2022-05-12	0
Diego Torres	17441	2022-05-12	0
Engenheiros Do Hawaii	17442	2022-05-12	0
Fletcher Henderson And His Orchestra	17443	2022-05-12	0
Bobby Hutcherson_ George Cables_ Herbie Lewis_ Philly Joe Jones	17444	2022-05-12	0
Emir Kusturica & The No Smoking Orchestra	17445	2022-05-12	0
Parakeets	17446	2022-05-12	0
The Clark Sisters	17447	2022-05-12	0
Damn Yankees	17448	2022-05-12	0
The Infested	17449	2022-05-12	0
X-ecutioners	17450	2022-05-12	0
Lost Patrol Band	17451	2022-05-12	0
The Brothers Johnson	17452	2022-05-12	0
Casiotone For The Painfully Alone	17453	2022-05-12	0
Nenhum De Nós	17454	2022-05-12	0
Krikka Reggae	17455	2022-05-12	0
Admiral Bailey	17456	2022-05-12	0
Les Reines Prochaines	17457	2022-05-12	0
Lisa Bevill	17458	2022-05-12	0
UKW	17459	2022-05-12	0
Enemies Swe	17460	2022-05-12	0
Lorne Greene	17461	2022-05-12	0
Dr John	17462	2022-05-12	0
Machel Montano	17463	2022-05-12	0
Ariane Moffatt	17464	2022-05-12	0
Shelley Fabares	17465	2022-05-12	0
Jose Larralde	17466	2022-05-12	0
Toto Coelo Ii_Lacey B	17467	2022-05-12	0
The Karl Hendricks Trio	17468	2022-05-12	0
Justyna Steczkowska	17469	2022-05-12	0
Dave Barker / The Techniques All Stars	17470	2022-05-12	0
Rustic Overtones	17471	2022-05-12	0
Pearl Jam	17472	2022-05-12	0
Alan Jackson duet with George Strait	17473	2022-05-12	0
Chris Hillman	17474	2022-05-12	0
Marie Osmond	17475	2022-05-12	0
Jimmy Cliff	17476	2022-05-12	0
Kap Bambino	17477	2022-05-12	0
Mala Reputación	17478	2022-05-12	0
Terry Ganzie	17479	2022-05-12	0
Dms12	17480	2022-05-12	0
Princess Lover	17481	2022-05-12	0
R. Carlos Nakai Quartet	17482	2022-05-12	0
Choir	17483	2022-05-12	0
Overtone;Yollandi Nortjie	17484	2022-05-12	0
Normal Like You	17485	2022-05-12	0
Thunder Express	17486	2022-05-12	0
Mano Negra	17487	2022-05-12	0
TOK	17488	2022-05-12	0
Mad Professor / Mafia & Fluxy	17489	2022-05-12	0
Louise Johnson	17490	2022-05-12	0
Caribou	17491	2022-05-12	0
Lizz Wright	17492	2022-05-12	0
Luz Casal	17493	2022-05-12	0
Hermanas Huerta	17494	2022-05-12	0
Sean Cronin	17495	2022-05-12	0
Knotz	17496	2022-05-12	0
Arabesque	17497	2022-05-12	0
Dr Feelgood	17498	2022-05-12	0
Anthony Que	17499	2022-05-12	0
April March	17500	2022-05-12	0
Chantal Kreviazuk	17501	2022-05-12	0
Francisco Céspedes	17502	2022-05-12	0
Frog Pocket	17503	2022-05-12	0
Material Issue	17504	2022-05-12	0
Taylor Swift	17505	2022-05-12	0
Voices Of East Harlem	17506	2022-05-12	0
Marco Polo Ivx	17507	2022-05-12	0
Frank Strozier	17508	2022-05-12	0
Lazarus A.D.	17509	2022-05-12	0
Dwarves	17510	2022-05-12	0
Sparklehorse	17511	2022-05-12	0
mr76ix	17512	2022-05-12	0
Indigo Girls	17513	2022-05-12	0
Cracker	17514	2022-05-12	0
LU-LU	17515	2022-05-12	0
Deanna Bogart	17516	2022-05-12	0
Doug Stone	17517	2022-05-12	0
Jane Winther	17518	2022-05-12	0
Taken By Trees	17519	2022-05-12	0
Mr. Scruff	17520	2022-05-12	0
Stray	17521	2022-05-12	0
The Dead 60s	17522	2022-05-12	0
Galactic	17523	2022-05-12	0
Rich Kids	17524	2022-05-12	0
Angel Stoxx featuring natasha	17525	2022-05-12	0
Sandhy SonDoro	17526	2022-05-12	0
LITE	17527	2022-05-12	0
John Butler Trio	17528	2022-05-12	0
Uman	17529	2022-05-12	0
Drowning Pool	17530	2022-05-12	0
Amy Studt	17531	2022-05-12	0
Mr Untel	17532	2022-05-12	0
Waylon Thibodeaux	17533	2022-05-12	0
Jadakiss_ Styles P	17534	2022-05-12	0
UGK featuring Too $hort & Snoop Dogg	17535	2022-05-12	0
Prinz Pi	17536	2022-05-12	0
Gloriana	17537	2022-05-12	0
Webb Pierce & Red Sovine	17538	2022-05-12	0
Nuyorican Soul / Jocelyn Brown	17539	2022-05-12	0
Aereogramme	17540	2022-05-12	0
Excel	17541	2022-05-12	0
The Gaskets	17542	2022-05-12	0
Jorge Drexler	17543	2022-05-12	0
Gisbert Zu Knyphausen	17544	2022-05-12	0
Jim Cummings featuring Terrance Simien on Accordion	17545	2022-05-12	0
Victoria Beckham	17546	2022-05-12	0
Firefall	17547	2022-05-12	0
100 Pets	17548	2022-05-12	0
Wayne Carter	17549	2022-05-12	0
David Blue	17550	2022-05-12	0
The Phantom Limbs	17551	2022-05-12	0
Space Opera	17552	2022-05-12	0
Takahashi Hiroki	17553	2022-05-12	0
World Trade	17554	2022-05-12	0
Brass Tacks	17555	2022-05-12	0
Melendi	17556	2022-05-12	0
Steve Johnson	17557	2022-05-12	0
Snapper	17558	2022-05-12	0
BWB	17559	2022-05-12	0
Little Tony & The Tennessee Rebels	17560	2022-05-12	0
Unwed Sailor	17561	2022-05-12	0
VHS Or Beta	17562	2022-05-12	0
Ana Cañas	17563	2022-05-12	0
Dany Dan_ Smoker_ Al Peco_ S-Pi_ Six Coups MC_ Sultan_ Gued1_ Seven_ Abdel	17564	2022-05-12	0
Marc-André Hamelin	17565	2022-05-12	0
Home T & Trinity	17566	2022-05-12	0
Breakage & SP:MC	17567	2022-05-12	0
Thee 50's High Teens	17568	2022-05-12	0
Chris Fortier	17569	2022-05-12	0
The Mystic Underground	17570	2022-05-12	0
Conjunto Tipico Vallenato	17571	2022-05-12	0
Kites	17572	2022-05-12	0
Thought Industry	17573	2022-05-12	0
Messer Chups feat. Lydia Kavina	17574	2022-05-12	0
Point Of Grace	17575	2022-05-12	0
Future Leaders of the World	17576	2022-05-12	0
The J.B.'s	17577	2022-05-12	0
Norman Connors Featuring Phyllis Hyman	17578	2022-05-12	0
Ich + Ich	17579	2022-05-12	0
Cheikh Lô	17580	2022-05-12	0
The Walkmen	17581	2022-05-12	0
Monica	17582	2022-05-12	0
Yo Gotti	17583	2022-05-12	0
Natasha	17584	2022-05-12	0
Jackie Moore	17585	2022-05-12	0
Alec K. Redfearn and The Eyesores	17586	2022-05-12	0
Paint By Numbers	17587	2022-05-12	0
Fabio Stein & Claudia Cazacu	17588	2022-05-12	0
Bjørn Berge	17589	2022-05-12	0
BoDeans	17590	2022-05-12	0
Apocalypsis	17591	2022-05-12	0
Side Walk Slam	17592	2022-05-12	0
Hercules And Love Affair	17593	2022-05-12	0
Alice Coltrane	17594	2022-05-12	0
Avain	17595	2022-05-12	0
Rush Of Fools	17596	2022-05-12	0
Lord Invader	17597	2022-05-12	0
Sibiria	17598	2022-05-12	0
Tom Barabas	17599	2022-05-12	0
Ensemble Lucidarium	17600	2022-05-12	0
The Action	17601	2022-05-12	0
Burkhard Dallwitz	17602	2022-05-12	0
Walter Trout	17603	2022-05-12	0
Bobby V	17604	2022-05-12	0
Barbara Manning	17605	2022-05-12	0
Killa Tay	17606	2022-05-12	0
Dooley-O	17607	2022-05-12	0
Reysan Khan	17608	2022-05-12	0
Cartel De Santa Featuring Javu_ Piochaz Y Micho Del Duho	17609	2022-05-12	0
Grace Overthrone	17610	2022-05-12	0
Paul Revere & The Raiders	17611	2022-05-12	0
Alturas	17612	2022-05-12	0
Sebastien Leger	17613	2022-05-12	0
Stephen Simmons	17614	2022-05-12	0
Ivoryline	17615	2022-05-12	0
Showtek	17616	2022-05-12	0
Red Snapper	17617	2022-05-12	0
Lincoln Brewster	17618	2022-05-12	0
Over The Rhine	17619	2022-05-12	0
The Dresden Dolls	17620	2022-05-12	0
Battle of The Future Buddhas	17621	2022-05-12	0
Alex M.	17622	2022-05-12	0
Ravel	17623	2022-05-12	0
The Lionheart Brothers	17624	2022-05-12	0
Johnny Crockett	17625	2022-05-12	0
Junkfood Junkies	17626	2022-05-12	0
Big Al Downing	17627	2022-05-12	0
Stefano Noferini	17628	2022-05-12	0
ZU2T	17629	2022-05-12	0
Avril - Remix By Laurent Garnier	17630	2022-05-12	0
English Chamber Orchestra / Endymion Ensemble	17631	2022-05-12	0
Mijk Van Dijk	17632	2022-05-12	0
Spinal Tap	17633	2022-05-12	0
Nitty Gritty Dirt Band	17634	2022-05-12	0
Johnossi	17635	2022-05-12	0
Reef the Lost Cauze	17636	2022-05-12	0
Halou	17637	2022-05-12	0
OceanLab	17638	2022-05-12	0
Abyssinians	17639	2022-05-12	0
Taj Mahal	17640	2022-05-12	0
Alan Braxe	17641	2022-05-12	0
Sabrynaah Pope	17642	2022-05-12	0
The Controllers	17643	2022-05-12	0
Mad Mike	17644	2022-05-12	0
Iva Zanicchi	17645	2022-05-12	0
Gus Viseur	17646	2022-05-12	0
Eisregen	17647	2022-05-12	0
Vinícius Calderoni	17648	2022-05-12	0
Snoop Dogg ft. Typhoon	17649	2022-05-12	0
Bootsy Collins Feat. Mc Lyte	17650	2022-05-12	0
Lichtensteiner feat. DJ Ralli	17651	2022-05-12	0
The Chalets	17652	2022-05-12	0
Punish Yourself	17653	2022-05-12	0
Dave Grusin	17654	2022-05-12	0
Hard-FI	17655	2022-05-12	0
Jimmy Yancey	17656	2022-05-12	0
Africa's Chill Out	17657	2022-05-12	0
Clan Destined	17658	2022-05-12	0
Tennis	17659	2022-05-12	0
Rex Allen	17660	2022-05-12	0
Rising Sun	17661	2022-05-12	0
Nathan Abshire	17662	2022-05-12	0
Rosario	17663	2022-05-12	0
Preston Epps	17664	2022-05-12	0
Nacho Chapado & Smaz feat. Sue Mclaren	17665	2022-05-12	0
Lucha Villa	17666	2022-05-12	0
Far-Less	17667	2022-05-12	0
Barón Rojo	17668	2022-05-12	0
Highway 61 Revisited - Bob Dylan	17669	2022-05-12	0
Alvin Lee	17670	2022-05-12	0
Vocokesh	17671	2022-05-12	0
HardNox	17672	2022-05-12	0
Shade Sheist / Damizza	17673	2022-05-12	0
The New Raemon	17674	2022-05-12	0
Los Toros Band	17675	2022-05-12	0
Killing Floor	17676	2022-05-12	0
Dee Smoove & Voice Delegation	17677	2022-05-12	0
Sister Carol Feat. J. Osbourne	17678	2022-05-12	0
Russell Watson	17679	2022-05-12	0
Porch Ghouls	17680	2022-05-12	0
Giggs ft. J.Melo	17681	2022-05-12	0
Seán Cronin	17682	2022-05-12	0
Willie Nelson / Jonny Lang	17683	2022-05-12	0
Sir Simon Rattle/Berliner Philharmoniker/Karita Mattila/Thomas Quasthoff	17684	2022-05-12	0
Spade Cooley	17685	2022-05-12	0
Simple Plan	17686	2022-05-12	0
Belen Arjona	17687	2022-05-12	0
Chick Corea Akoustic Band	17688	2022-05-12	0
DJ Dazzle & Octagen	17689	2022-05-12	0
Tubby Hayes & His Orchestra	17690	2022-05-12	0
Goldheart Assembly	17691	2022-05-12	0
Ohbijou	17692	2022-05-12	0
Rihanna	17693	2022-05-12	0
2 In A Room	17694	2022-05-12	0
Chris Cain	17695	2022-05-12	0
Danielito Dj	17696	2022-05-12	0
The Forms	17697	2022-05-12	0
Brainchoke	17698	2022-05-12	0
SM-Trax	17699	2022-05-12	0
Jeanne Pruett	17700	2022-05-12	0
Marek Hemmann	17701	2022-05-12	0
Patrice Bäumel vs. Caitlin Devlin	17702	2022-05-12	0
Niko Schwind	17703	2022-05-12	0
Ronnie Spector	17704	2022-05-12	0
Anna Järvinen	17705	2022-05-12	0
Sabbat	17706	2022-05-12	0
Robert Owens	17707	2022-05-12	0
Shooting At Unarmed Men	17708	2022-05-12	0
Madlib The Beat Konducta	17709	2022-05-12	0
Mundo Cão	17710	2022-05-12	0
Marconi Union	17711	2022-05-12	0
Robin Bullock	17712	2022-05-12	0
Thr3shold	17713	2022-05-12	0
Charanga 76	17714	2022-05-12	0
Brown Boy	17715	2022-05-12	0
November Process	17716	2022-05-12	0
Mi Pequeña Radio	17717	2022-05-12	0
The Streets	17718	2022-05-12	0
Soweto	17719	2022-05-12	0
Dirt Bike Annie	17720	2022-05-12	0
Mayday	17721	2022-05-12	0
The Airborne Toxic Event	17722	2022-05-12	0
Asamov	17723	2022-05-12	0
Crazy Town	17724	2022-05-12	0
The Orange Alabaster Mushroom	17725	2022-05-12	0
Erika Machado	17726	2022-05-12	0
Zinc / Angela Hunte	17727	2022-05-12	0
JB Lenoir	17728	2022-05-12	0
Angela Johnson	17729	2022-05-12	0
The Faint	17730	2022-05-12	0
Y&T	17731	2022-05-12	0
Dhany	17732	2022-05-12	0
Tommy Steele	17733	2022-05-12	0
Basia Bulat	17734	2022-05-12	0
Jim Baird	17735	2022-05-12	0
Mumiy Troll	17736	2022-05-12	0
Helicopter Girl	17737	2022-05-12	0
The Smoking Popes	17738	2022-05-12	0
Moodorama	17739	2022-05-12	0
Olga Guillot	17740	2022-05-12	0
Big Head Todd and The Monsters	17741	2022-05-12	0
HELLBILLYS	17742	2022-05-12	0
Bubba Sparxxx	17743	2022-05-12	0
Train	17744	2022-05-12	0
Leo Kottke	17745	2022-05-12	0
Garcia	17746	2022-05-12	0
Sondre Lerche	17747	2022-05-12	0
Evelyn "Champagne" King	17748	2022-05-12	0
Yves Montand	17749	2022-05-12	0
El Arrebato	17750	2022-05-12	0
Audioslave	17751	2022-05-12	0
Bob Smith	17752	2022-05-12	0
Andrea Abbate	17753	2022-05-12	0
Bobby Bland	17754	2022-05-12	0
The Parlor Mob	17755	2022-05-12	0
Manchester Orchestra	17756	2022-05-12	0
Sylvie Vartan	17757	2022-05-12	0
South Froggies	17758	2022-05-12	0
Veruca Salt	17759	2022-05-12	0
Kruger	17760	2022-05-12	0
Paradigm	17761	2022-05-12	0
Lulu Santos	17762	2022-05-12	0
David Guetta - JD Davis - Joachim Garraud	17763	2022-05-12	0
High Contrast Vs Logistics	17764	2022-05-12	0
Cat Stevens	17765	2022-05-12	0
For All We Know	17766	2022-05-12	0
Ronny Jordan	17767	2022-05-12	0
Les Pistolets Roses	17768	2022-05-12	0
Electribe 101	17769	2022-05-12	0
ScholarMan	17770	2022-05-12	0
Fujiya & Miyagi	17771	2022-05-12	0
Skam	17772	2022-05-12	0
The Seahorses	17773	2022-05-12	0
Fler	17774	2022-05-12	0
Trout Fishing in America	17775	2022-05-12	0
Alek Stark	17776	2022-05-12	0
Blue Sky Boys	17777	2022-05-12	0
Turi	17778	2022-05-12	0
Songs Of Lemuria	17779	2022-05-12	0
Stephen DeRuby	17780	2022-05-12	0
Harpers Bizarre	17781	2022-05-12	0
Jessica Mauboy	17782	2022-05-12	0
Alexkid	17783	2022-05-12	0
Peace Orchestra	17784	2022-05-12	0
Charles De Goal	17785	2022-05-12	0
Motel ***	17786	2022-05-12	0
Maroon 5	17787	2022-05-12	0
Buraka Som Sistema	17788	2022-05-12	0
Discanto	17789	2022-05-12	0
Safety Scissors / Sutekh	17790	2022-05-12	0
Kool Savas	17791	2022-05-12	0
Billy Boy Arnold	17792	2022-05-12	0
Marty Gold	17793	2022-05-12	0
Greg Kihn	17794	2022-05-12	0
Discover	17795	2022-05-12	0
Vliegende Panters	17796	2022-05-12	0
Taylor Deupree	17797	2022-05-12	0
Renée Zellweger;Catherine Zeta-Jones;Taye Diggs	17798	2022-05-12	0
Johnny Lytle	17799	2022-05-12	0
Nino D'Angelo	17800	2022-05-12	0
Visage	17801	2022-05-12	0
si-cut.db	17802	2022-05-12	0
Roach Motel	17803	2022-05-12	0
Preservation Hall Jazz Band	17804	2022-05-12	0
Guitar Shorty	17805	2022-05-12	0
Shystie	17806	2022-05-12	0
Ben Taylor	17807	2022-05-12	0
Voo Voo	17808	2022-05-12	0
Righteous Brothers	17809	2022-05-12	0
Maya Azucena	17810	2022-05-12	0
Down Low feat. Rappers Against Racism	17811	2022-05-12	0
Takaaki Itoh	17812	2022-05-12	0
The Beautiful People	17813	2022-05-12	0
Soon	17814	2022-05-12	0
Crunchy Black	17815	2022-05-12	0
Biagio Antonacci	17816	2022-05-12	0
Operator	17817	2022-05-12	0
Hank Thompson	17818	2022-05-12	0
Ernie Halter	17819	2022-05-12	0
Pierre Boulez	17820	2022-05-12	0
Play Dead	17821	2022-05-12	0
The Valentines	17822	2022-05-12	0
Truth Hurts	17823	2022-05-12	0
These Arms Are Snakes	17824	2022-05-12	0
Wencke Myhre	17825	2022-05-12	0
Warren Clarke feat. Kathy Brown	17826	2022-05-12	0
Flowing Tears	17827	2022-05-12	0
Kinky	17828	2022-05-12	0
Psyched Up Janis	17829	2022-05-12	0
Padded Cell	17830	2022-05-12	0
La Pestilencia	17831	2022-05-12	0
Foals	17832	2022-05-12	0
The Unlovables	17833	2022-05-12	0
The Boat People	17834	2022-05-12	0
King Tubby & the Aggrovators	17835	2022-05-12	0
Ordo Rosarius Equilibrio	17836	2022-05-12	0
Turibio Santos	17837	2022-05-12	0
Ismael Silva	17838	2022-05-12	0
Journey	17839	2022-05-12	0
IZZ	17840	2022-05-12	0
Kyf Brewer	17841	2022-05-12	0
the silk demise	17842	2022-05-12	0
D:Fuse & Howard pres. Expansion	17843	2022-05-12	0
Mase featuring P. Diddy	17844	2022-05-12	0
Gil Scott-Heron	17845	2022-05-12	0
Armitage Shanks	17846	2022-05-12	0
Delafe y las flores azules	17847	2022-05-12	0
Love Unlimited	17848	2022-05-12	0
Moloko	17849	2022-05-12	0
Krazy Sandi	17850	2022-05-12	0
Kushida Akira	17851	2022-05-12	0
Charanga del Norte	17852	2022-05-12	0
Severed Heads	17853	2022-05-12	0
La Mano Ajena	17854	2022-05-12	0
Jonathan Miller	17855	2022-05-12	0
Bisso Na Bisso	17856	2022-05-12	0
Felicia Sanders	17857	2022-05-12	0
Kelpe	17858	2022-05-12	0
Ivana  Spagna	17859	2022-05-12	0
Bad Boys Blue	17860	2022-05-12	0
TLC	17861	2022-05-12	0
Blanc Faces	17862	2022-05-12	0
PC Synergy	17863	2022-05-12	0
Long Tall Texans	17864	2022-05-12	0
Ham Sandwich	17865	2022-05-12	0
Psycroptic	17866	2022-05-12	0
The Good_ The Bad and The Queen	17867	2022-05-12	0
Los Muñequitos De Matanzas	17868	2022-05-12	0
John Larner Featuring DJ Red Eye	17869	2022-05-12	0
Wailers	17870	2022-05-12	0
Manolo Tena	17871	2022-05-12	0
2 Dirty	17872	2022-05-12	0
The Offspring	17873	2022-05-12	0
Ben Lee	17874	2022-05-12	0
Nomadi	17875	2022-05-12	0
Arturo Benedetti Michelangeli	17876	2022-05-12	0
Westernhagen	17877	2022-05-12	0
Christophe Goze	17878	2022-05-12	0
Saint	17879	2022-05-12	0
Ancieto Molina	17880	2022-05-12	0
The Monochrome Set	17881	2022-05-12	0
Carmen Y Laura	17882	2022-05-12	0
Hawkshaw Hawkins	17883	2022-05-12	0
Sunloverz	17884	2022-05-12	0
Mark Masri feat. Jim Brickman And Amy Sky	17885	2022-05-12	0
Insomnium	17886	2022-05-12	0
Marc Ribot Y Los Cubanos Postizos	17887	2022-05-12	0
The Latin Brothers	17888	2022-05-12	0
Crooked Still	17889	2022-05-12	0
Billie Holiday	17890	2022-05-12	0
Psywarfare	17891	2022-05-12	0
Cepia	17892	2022-05-12	0
Waylon Jennings & Willie Nelson	17893	2022-05-12	0
Jerry Garcia;David Grisman;john kahn	17894	2022-05-12	0
Chris Tomlin	17895	2022-05-12	0
The Sutherland Brothers	17896	2022-05-12	0
Supermachiner	17897	2022-05-12	0
Bishi	17898	2022-05-12	0
Crystal	17899	2022-05-12	0
Fort Minor	17900	2022-05-12	0
Astrosoniq	17901	2022-05-12	0
Foolish Things	17902	2022-05-12	0
Charlie Rich	17903	2022-05-12	0
This Et Al	17904	2022-05-12	0
Riccardo Fogli	17905	2022-05-12	0
Muscles	17906	2022-05-12	0
Razed in Black	17907	2022-05-12	0
Andre Hazes	17908	2022-05-12	0
Kristiina Brask	17909	2022-05-12	0
Pepe Kalle	17910	2022-05-12	0
Moneyshot	17911	2022-05-12	0
Gothenburg Symphony Orchestra	17912	2022-05-12	0
The Nommos	17913	2022-05-12	0
Sickboy	17914	2022-05-12	0
Bob Sinclar	17915	2022-05-12	0
Vico C	17916	2022-05-12	0
Blind Dog	17917	2022-05-12	0
UB40	17918	2022-05-12	0
Estigma	17919	2022-05-12	0
Travel By Sea	17920	2022-05-12	0
Konstantinos Galanos	17921	2022-05-12	0
Beau Jocque	17922	2022-05-12	0
Claude Vonstroke	17923	2022-05-12	0
George Morel	17924	2022-05-12	0
Totally Insane ft Money Marc _ Scoot Dogg_ Backstreet Mentality	17925	2022-05-12	0
The Cranberries	17926	2022-05-12	0
Roland Klinkenberg	17927	2022-05-12	0
M. Walking On The Water	17928	2022-05-12	0
Lil Chris	17929	2022-05-12	0
Future Cut ft. DJ Kontrol	17930	2022-05-12	0
Gabriel Gordon	17931	2022-05-12	0
Sophie Solomon	17932	2022-05-12	0
The Milkshakes	17933	2022-05-12	0
Mark Wills	17934	2022-05-12	0
Matias Aguayo	17935	2022-05-12	0
Tony Allen / Res / Ray Lema / Baaba Maal / Positive Black Soul / Archie Shepp	17936	2022-05-12	0
The Sensational Nightingales	17937	2022-05-12	0
Birds of Prey	17938	2022-05-12	0
Elvis Crespo	17939	2022-05-12	0
Low Deep_ Digga_ Dogzy	17940	2022-05-12	0
Swizz Beatz / Ja Rule / Metallica	17941	2022-05-12	0
Gianni Morandi	17942	2022-05-12	0
Marea	17943	2022-05-12	0
Real De Catorce	17944	2022-05-12	0
Quazar	17945	2022-05-12	0
Tim 'Love' Lee	17946	2022-05-12	0
Hausmarke;Afrob	17947	2022-05-12	0
Su-Paka-Pooh	17948	2022-05-12	0
Big Mountain	17949	2022-05-12	0
The Murderers	17950	2022-05-12	0
Stream Of Passion	17951	2022-05-12	0
Ultramagnetic MC's	17952	2022-05-12	0
Harry Gregson-Williams	17953	2022-05-12	0
The Dubliners	17954	2022-05-12	0
Glenn Miller Orchestra	17955	2022-05-12	0
Benjamin Zephaniah	17956	2022-05-12	0
Rob Threezy	17957	2022-05-12	0
Q-Burns Abstract Message & Lisa Shaw	17958	2022-05-12	0
Lull	17959	2022-05-12	0
6CycleMind	17960	2022-05-12	0
Brunning Sunflower Blues Band	17961	2022-05-12	0
Busy Bee	17962	2022-05-12	0
Punkreas	17963	2022-05-12	0
Johnny Shines	17964	2022-05-12	0
The Bittersweets	17965	2022-05-12	0
Electric Flag	17966	2022-05-12	0
Setrise & Nurettin Colak	17967	2022-05-12	0
E.C.	17968	2022-05-12	0
Elektrik Mistress	17969	2022-05-12	0
The Pineapple Thief	17970	2022-05-12	0
The Morgans	17971	2022-05-12	0
FREAK NASTY PRESENTS VARIOUS ARTIST	17972	2022-05-12	0
Steve Earle	17973	2022-05-12	0
Fedayi  Pacha	17974	2022-05-12	0
Fukkk Offf	17975	2022-05-12	0
Jamaram	17976	2022-05-12	0
Koffee Brown Featuring Lady Luck	17977	2022-05-12	0
Marc Romboy	17978	2022-05-12	0
James Blundell	17979	2022-05-12	0
The Five Keys	17980	2022-05-12	0
The Deadly Snakes	17981	2022-05-12	0
Girl Pop Divas	17982	2022-05-12	0
The Cadets	17983	2022-05-12	0
Klashnekoff	17984	2022-05-12	0
The Clovers	17985	2022-05-12	0
Maria Carrasco	17986	2022-05-12	0
The Forty-Fives	17987	2022-05-12	0
Toddla T Feat. Herve & Serocee	17988	2022-05-12	0
Darude	17989	2022-05-12	0
Hiroshima Mon Amour	17990	2022-05-12	0
Lou Rhodes	17991	2022-05-12	0
Shirley Bassey	17992	2022-05-12	0
Kottonmouth	17993	2022-05-12	0
Stephanie McKay	17994	2022-05-12	0
Maria Taylor with Andy LeMaster	17995	2022-05-12	0
Avril	17996	2022-05-12	0
Massimiliano Damerini	17997	2022-05-12	0
Un Rodo Cora	17998	2022-05-12	0
Gary Go	17999	2022-05-12	0
Enslavement Of Beauty	18000	2022-05-12	0
Gail Pettis	18001	2022-05-12	0
Igor Rudov	18002	2022-05-12	0
Alphonse Mouzon	18003	2022-05-12	0
Breaks Co-Op	18004	2022-05-12	0
September Collective	18005	2022-05-12	0
Marmoset	18006	2022-05-12	0
volcano!	18007	2022-05-12	0
Al Bano & Romina Power	18008	2022-05-12	0
The Dangerous Summer	18009	2022-05-12	0
Randy Kohrs	18010	2022-05-12	0
The Jacka & Ampichino	18011	2022-05-12	0
Articolo 31	18012	2022-05-12	0
Pablo Casals	18013	2022-05-12	0
Mansun	18014	2022-05-12	0
The Dear Hunter	18015	2022-05-12	0
Pelle Carlberg	18016	2022-05-12	0
Victor Garcia	18017	2022-05-12	0
Teijo Joutsela and Humppa-Veikot	18018	2022-05-12	0
Jc Chasez	18019	2022-05-12	0
Royal Liverpool Philharmonic Orchestra	18020	2022-05-12	0
David Lanz	18021	2022-05-12	0
Teddybears Sthlm	18022	2022-05-12	0
Franz Welser-Most/London Philharmonic	18023	2022-05-12	0
Blenderhead	18024	2022-05-12	0
Junges Glueck	18025	2022-05-12	0
John '00' Fleming	18026	2022-05-12	0
Paul Weller	18027	2022-05-12	0
The Junior Varsity	18028	2022-05-12	0
Janet Jackson	18029	2022-05-12	0
The World On Higher Downs	18030	2022-05-12	0
La Habitacion Roja	18031	2022-05-12	0
Karsh Kale	18032	2022-05-12	0
For Against	18033	2022-05-12	0
To My Surprise	18034	2022-05-12	0
Cows	18035	2022-05-12	0
Wicked Allstars	18036	2022-05-12	0
Tony Malone And The Rapparees	18037	2022-05-12	0
Naughty By Nature / Queen Latifah	18038	2022-05-12	0
Blackfire	18039	2022-05-12	0
The Whiles	18040	2022-05-12	0
Hard-Ons	18041	2022-05-12	0
Ladyhawk	18042	2022-05-12	0
Rumskib	18043	2022-05-12	0
Let's Wrestle	18044	2022-05-12	0
Jacek Kaczmarski	18045	2022-05-12	0
Slow Gherkin	18046	2022-05-12	0
Big Jay Oakerson	18047	2022-05-12	0
Matthew Kramer	18048	2022-05-12	0
Ophelia Ragtime Orchestra & Seim Songkor	18049	2022-05-12	0
Susan Cowsill	18050	2022-05-12	0
Blind Faith	18051	2022-05-12	0
The 5 Royales	18052	2022-05-12	0
Red Rockers	18053	2022-05-12	0
Swingle Singers	18054	2022-05-12	0
Anouk	18055	2022-05-12	0
Low Profile	18056	2022-05-12	0
Ruff Ryders	18057	2022-05-12	0
Big Tone	18058	2022-05-12	0
Léopold Simoneau/Orchestre du Théâtre des Champs-Élysées/André Jouve	18059	2022-05-12	0
Xavier Rudd	18060	2022-05-12	0
Solistiyhtye Suomi	18061	2022-05-12	0
Aphrodite	18062	2022-05-12	0
The Brain	18063	2022-05-12	0
Andy Russell	18064	2022-05-12	0
Movie Sounds Unlimited	18065	2022-05-12	0
American Boychoir	18066	2022-05-12	0
Notes From Underground	18067	2022-05-12	0
A.A. Bondy	18068	2022-05-12	0
V/A Carohrani	18069	2022-05-12	0
Rosanne Cash Featuring Teddy Thompson	18070	2022-05-12	0
Chris Botti	18071	2022-05-12	0
Choirboys	18072	2022-05-12	0
Andrew Bird	18073	2022-05-12	0
The Dwarves	18074	2022-05-12	0
The Feelies	18075	2022-05-12	0
Wayne Shorter	18076	2022-05-12	0
Lucie Bílá	18077	2022-05-12	0
Swing	18078	2022-05-12	0
Frankie Yankovic & His Yanks	18079	2022-05-12	0
Nick Cave & The Bad Seeds	18080	2022-05-12	0
Eli	18081	2022-05-12	0
The Chap	18082	2022-05-12	0
Shoplifting	18083	2022-05-12	0
Fyah Blaze	18084	2022-05-12	0
Anna Domino	18085	2022-05-12	0
Small Black	18086	2022-05-12	0
temposhark	18087	2022-05-12	0
Panic Channel	18088	2022-05-12	0
Gene Vincent	18089	2022-05-12	0
The Cure	18090	2022-05-12	0
Ruper Ordorika	18091	2022-05-12	0
Slim Gaillard	18092	2022-05-12	0
Cars Can Be Blue	18093	2022-05-12	0
Ancient Vision	18094	2022-05-12	0
Utah Saints	18095	2022-05-12	0
Faze Action	18096	2022-05-12	0
England Dan & John Ford Coley	18097	2022-05-12	0
Young Divas	18098	2022-05-12	0
Ben Weasel	18099	2022-05-12	0
Dapayk solo	18100	2022-05-12	0
Bellamy Brothers	18101	2022-05-12	0
Buddy Jones	18102	2022-05-12	0
Major Lazer / Mr. Evil / Mapei	18103	2022-05-12	0
Nada Surf	18104	2022-05-12	0
Element (of Custom Made)	18105	2022-05-12	0
Willie Gonzalez	18106	2022-05-12	0
Disiz La Peste	18107	2022-05-12	0
Archie Shepp	18108	2022-05-12	0
Henry Kaiser & Sergei Kuriokhin	18109	2022-05-12	0
Soul Migrantz feat. Mista	18110	2022-05-12	0
Rollins Band	18111	2022-05-12	0
Patty Ryan	18112	2022-05-12	0
Color Filter	18113	2022-05-12	0
Dave Tarras	18114	2022-05-12	0
Sophie Milman	18115	2022-05-12	0
Agressiva 69	18116	2022-05-12	0
Walter Meego	18117	2022-05-12	0
Angel Canales	18118	2022-05-12	0
DJ KAYSLAY featuring Three 6 Mafia_ Lil Wyte_ Frayser Boy	18119	2022-05-12	0
Shit Robot	18120	2022-05-12	0
Horsepower Productions	18121	2022-05-12	0
Icecream Hands	18122	2022-05-12	0
Ethel Waters	18123	2022-05-12	0
The Old Soul	18124	2022-05-12	0
Ludovico Einaudi & Ballaké Sissoko	18125	2022-05-12	0
Zafra Negra	18126	2022-05-12	0
Levon Helm And The RCO All Sta	18127	2022-05-12	0
Ken Yokoyama	18128	2022-05-12	0
Headman	18129	2022-05-12	0
La Base	18130	2022-05-12	0
Lena Horne	18131	2022-05-12	0
40 Cal	18132	2022-05-12	0
Pomegranates	18133	2022-05-12	0
Tomskee Mask_ Mr Sche	18134	2022-05-12	0
Ultraviolence	18135	2022-05-12	0
Ricochet	18136	2022-05-12	0
Ritchie	18137	2022-05-12	0
Eric Demarsan	18138	2022-05-12	0
Vader	18139	2022-05-12	0
Lole y Manuel	18140	2022-05-12	0
Voicst	18141	2022-05-12	0
Asheni	18142	2022-05-12	0
Gunjack	18281	2022-05-12	0
Yume Bitsu	18282	2022-05-12	0
Agnes Baltsa / Athens Experimental Orchestra / Stavros Xarhakos / Kostas Papadopoulos	18143	2022-05-12	0
Daniel Johnston	18144	2022-05-12	0
Moshav Band	18145	2022-05-12	0
Jimi Jamison	18146	2022-05-12	0
Bird York	18147	2022-05-12	0
Diorama	18148	2022-05-12	0
Bad Sign	18149	2022-05-12	0
Razzy Bailey	18150	2022-05-12	0
Bert Jansch	18151	2022-05-12	0
Pumice	18152	2022-05-12	0
Roky Erickson and The Explosives	18153	2022-05-12	0
Indo G	18154	2022-05-12	0
Alice	18155	2022-05-12	0
Donna Lewis	18156	2022-05-12	0
Peter Himmelman	18157	2022-05-12	0
F.R. David	18158	2022-05-12	0
Guzzard	18159	2022-05-12	0
Myron Butler & Levi	18160	2022-05-12	0
Franklin Bruno	18161	2022-05-12	0
Argos	18162	2022-05-12	0
Sylvia Patricia	18163	2022-05-12	0
Willy Clay Band	18164	2022-05-12	0
Sola Rosa	18165	2022-05-12	0
BT Express	18166	2022-05-12	0
Alex Medina	18167	2022-05-12	0
Gary Chapman	18168	2022-05-12	0
Die Toten Hosen	18169	2022-05-12	0
The Dictators	18170	2022-05-12	0
Merci Miss Monroe	18171	2022-05-12	0
Bionikworld	18172	2022-05-12	0
Sangre Azul	18173	2022-05-12	0
Deep Forest	18174	2022-05-12	0
Pine Top Smith	18175	2022-05-12	0
Magida El Roumi	18176	2022-05-12	0
Queen Omega featuring Ambelique	18177	2022-05-12	0
Teenage Kicks	18178	2022-05-12	0
New Found Land	18179	2022-05-12	0
Sonny Landreth	18180	2022-05-12	0
The Dillinger Escape Plan	18181	2022-05-12	0
Mishon	18182	2022-05-12	0
Brian Laruso	18183	2022-05-12	0
TTR Allstars	18184	2022-05-12	0
Built To Spill / Caustic Resin	18185	2022-05-12	0
Stevie Wonder	18186	2022-05-12	0
Richie Stephens	18187	2022-05-12	0
Argent	18188	2022-05-12	0
Pour Habit	18189	2022-05-12	0
Assembly Now	18190	2022-05-12	0
Ina Deter Band	18191	2022-05-12	0
Benny Green	18192	2022-05-12	0
Triple Darkness	18193	2022-05-12	0
Benito Kamelas	18194	2022-05-12	0
The Notting Hillbillies	18195	2022-05-12	0
Pedro The Lion	18196	2022-05-12	0
Zion I	18197	2022-05-12	0
Bonobo Featuring Andreya Triana	18198	2022-05-12	0
Macacos do Chinês	18199	2022-05-12	0
J.J. Barnes	18200	2022-05-12	0
The Psycho Realm_ Sick Jacken	18201	2022-05-12	0
Brian Vander Ark	18202	2022-05-12	0
Stan Getz / Chet Baker	18203	2022-05-12	0
Trentemøller	18204	2022-05-12	0
Arise	18205	2022-05-12	0
Electronic pig	18206	2022-05-12	0
Lil Keke	18207	2022-05-12	0
Ike Yard	18208	2022-05-12	0
Krause	18209	2022-05-12	0
School Of Fish	18210	2022-05-12	0
Daddy Mory	18211	2022-05-12	0
Willa Ford	18212	2022-05-12	0
The Daredevil Christopher Wright	18213	2022-05-12	0
Zico Chain	18214	2022-05-12	0
Culture Club	18215	2022-05-12	0
Masif DJ's	18216	2022-05-12	0
Subversión X	18217	2022-05-12	0
MC A.D.E.	18218	2022-05-12	0
Jesse Dayton	18219	2022-05-12	0
Ozric Tentacles	18220	2022-05-12	0
Rocio Durcal	18221	2022-05-12	0
Duberman	18222	2022-05-12	0
Herbie Hancock / Corinne Bailey Rae	18223	2022-05-12	0
Adam Kesher	18224	2022-05-12	0
Eminem	18225	2022-05-12	0
theBREAX	18226	2022-05-12	0
Lil Bow Wow	18227	2022-05-12	0
Lange vs. Gareth Emery	18228	2022-05-12	0
John Mayall	18229	2022-05-12	0
Fei Comodo	18230	2022-05-12	0
Cutting Pink with Knives	18231	2022-05-12	0
Nahawa Doumbia	18232	2022-05-12	0
Timo Rautiainen & Trio Niskalaukaus	18233	2022-05-12	0
Girls Are Short	18234	2022-05-12	0
Blake Morgan	18235	2022-05-12	0
Joan Baez	18236	2022-05-12	0
Tal M. Klein	18237	2022-05-12	0
Chabuca Granda	18238	2022-05-12	0
B R Oad Way	18239	2022-05-12	0
Katalyst	18240	2022-05-12	0
A Triggering Myth	18241	2022-05-12	0
Andy Griffith	18242	2022-05-12	0
Lara Fabian	18243	2022-05-12	0
Sintax the Terrific	18244	2022-05-12	0
Opa Cupa	18245	2022-05-12	0
Miklós Rózsa	18246	2022-05-12	0
The Klezmer Conservatory Band	18247	2022-05-12	0
Rachael Sage	18248	2022-05-12	0
Marcela Biasi	18249	2022-05-12	0
Niyaz	18250	2022-05-12	0
Frankie Avalon	18251	2022-05-12	0
TV21	18252	2022-05-12	0
Coses	18253	2022-05-12	0
Ian Matthews	18254	2022-05-12	0
Steve Jablonski	18255	2022-05-12	0
Lunascape	18256	2022-05-12	0
Mr X	18257	2022-05-12	0
Casual	18258	2022-05-12	0
Tuff Darts	18259	2022-05-12	0
Miguel Aceves Mejia Con El Mariachi Vargas De Tecalitlan	18260	2022-05-12	0
Cesare Cremonini	18261	2022-05-12	0
Col. Bruce Hampton and the Late Bronze Age	18262	2022-05-12	0
A.T.P.	18263	2022-05-12	0
Louis Armstrong - Itinéraire d'un génie	18264	2022-05-12	0
John Travolta	18265	2022-05-12	0
Essam Gawish	18266	2022-05-12	0
Evol Waves	18267	2022-05-12	0
Hank Locklin	18268	2022-05-12	0
Pedro Laurenz	18269	2022-05-12	0
Philippe Sarde	18270	2022-05-12	0
Jerry Gaskill	18271	2022-05-12	0
Porno para Ricardo	18272	2022-05-12	0
Equals	18273	2022-05-12	0
Jackie Allen	18274	2022-05-12	0
Rob ´N´Raz Circus	18275	2022-05-12	0
Willie Wisely	18276	2022-05-12	0
Redd Kross	18277	2022-05-12	0
Your Name In Vain	18278	2022-05-12	0
Kellys	18279	2022-05-12	0
Cora E.	18280	2022-05-12	0
The Fairfield Four and NBB	18283	2022-05-12	0
You Me At Six	18284	2022-05-12	0
Magic Slim & The Teardrops	18285	2022-05-12	0
Les Sages Poetes De La Rue	18286	2022-05-12	0
Deemi featuring Styles P	18287	2022-05-12	0
Drop The Lime	18288	2022-05-12	0
The Outlaws	18289	2022-05-12	0
Brian Setzer	18290	2022-05-12	0
Felix Werder	18291	2022-05-12	0
Oscar Peterson	18292	2022-05-12	0
Gershon Kingsley	18293	2022-05-12	0
Jin Choi & Daso	18294	2022-05-12	0
September	18295	2022-05-12	0
Geri Halliwell	18296	2022-05-12	0
Andy Bell	18297	2022-05-12	0
CJ Sleez	18298	2022-05-12	0
Upa!	18299	2022-05-12	0
Milton Brown	18300	2022-05-12	0
Swell	18301	2022-05-12	0
F.P.	18302	2022-05-12	0
...And You Will Know Us By The Trail Of Dead	18303	2022-05-12	0
The Mad Lads	18304	2022-05-12	0
DJ Woodo vs. J:Loop aka The FunKartell	18305	2022-05-12	0
Killers	18306	2022-05-12	0
The Freestyle Fellowship	18307	2022-05-12	0
Skalariak	18308	2022-05-12	0
Sam Cooke	18309	2022-05-12	0
Lili Ivanova	18310	2022-05-12	0
Baby Rasta & Gringo	18311	2022-05-12	0
Gillian Welch	18312	2022-05-12	0
Thomas Godoj	18313	2022-05-12	0
Bear In Heaven	18314	2022-05-12	0
The Tranzmitors	18315	2022-05-12	0
Mike Sheridan & Mads Langer	18316	2022-05-12	0
Nobukazu Takemura	18317	2022-05-12	0
Hemdale	18318	2022-05-12	0
Dog Vs Cat	18319	2022-05-12	0
Big Mike Griffin	18320	2022-05-12	0
Abraham Laboriel	18321	2022-05-12	0
Charlie Patton	18322	2022-05-12	0
Faster Pussy cat	18323	2022-05-12	0
Jimmy Wakely	18324	2022-05-12	0
The Grip Weeds	18325	2022-05-12	0
Santos e Pecadores	18326	2022-05-12	0
Giora Feidman	18327	2022-05-12	0
Cechomor	18328	2022-05-12	0
Eddie Floyd	18329	2022-05-12	0
Nirvana	18330	2022-05-12	0
Drag The River	18331	2022-05-12	0
Triple Six Mafia	18332	2022-05-12	0
Tom Waits;Crystal Gayle	18333	2022-05-12	0
the apartments	18334	2022-05-12	0
Tammi Terrell	18335	2022-05-12	0
Rapsusklei	18336	2022-05-12	0
Pietro Mascagni	18337	2022-05-12	0
DANIEL KANDI	18338	2022-05-12	0
Planet P Project	18339	2022-05-12	0
Kowalsky meg a Vega	18340	2022-05-12	0
The Ataris / Useless ID	18341	2022-05-12	0
Franz Allers;Constance Towers	18342	2022-05-12	0
Celtic Woman	18343	2022-05-12	0
Grateful Dead	18344	2022-05-12	0
Cocoa Tea (feat. Cutty Ranks)	18345	2022-05-12	0
Los Hermanos Rosario	18346	2022-05-12	0
Evgeny Kissin	18347	2022-05-12	0
Morpheus Rising	18348	2022-05-12	0
Leny Andrade	18349	2022-05-12	0
Chris Rice	18350	2022-05-12	0
Sweet Trip	18351	2022-05-12	0
Early Man	18352	2022-05-12	0
Miki Dallon	18353	2022-05-12	0
Rohff	18354	2022-05-12	0
Chocolate Overdose	18355	2022-05-12	0
King Tubby Meets The Scientist	18356	2022-05-12	0
Rez Band	18357	2022-05-12	0
P J Proby	18358	2022-05-12	0
James Pants	18359	2022-05-12	0
Billy Ze Kick et Les Gamins En Folie	18360	2022-05-12	0
The Shape Shifters	18361	2022-05-12	0
Fabrice Servier	18362	2022-05-12	0
Raison D'être	18363	2022-05-12	0
Graham Parker	18364	2022-05-12	0
Kinito Mendez	18365	2022-05-12	0
Die Kassierer	18366	2022-05-12	0
Kill Paradise	18367	2022-05-12	0
7 Seconds	18368	2022-05-12	0
Disciple	18369	2022-05-12	0
Neil Norman & His Cosmic Orchestra	18370	2022-05-12	0
Sheryl Crow	18371	2022-05-12	0
Alain Souchon	18372	2022-05-12	0
Moodlex	18373	2022-05-12	0
No Lo Soporto	18374	2022-05-12	0
Stardeath And White Dwarfs	18375	2022-05-12	0
Together	18376	2022-05-12	0
Mazzy Star	18377	2022-05-12	0
Safety Scissors vs. Kit Clayton	18378	2022-05-12	0
Marco Resmann	18379	2022-05-12	0
Enrique Urquijo Y Los Problemas	18380	2022-05-12	0
SHADOW PROJECT	18381	2022-05-12	0
Thomas Newman	18382	2022-05-12	0
Chuck Brown	18383	2022-05-12	0
Sheila E	18384	2022-05-12	0
The Real Kids	18385	2022-05-12	0
John Paul	18386	2022-05-12	0
Patti Drew	18387	2022-05-12	0
Harmonia	18388	2022-05-12	0
Dilute	18389	2022-05-12	0
Piano Tribute Players	18390	2022-05-12	0
Guus Meeuwis	18391	2022-05-12	0
John Robinson	18392	2022-05-12	0
Hans Zimmer	18393	2022-05-12	0
David Bazan	18394	2022-05-12	0
The Lillingtons	18395	2022-05-12	0
Ikon	18396	2022-05-12	0
Maceo And All The King's Men	18397	2022-05-12	0
Laurel Canyon Ramblers	18398	2022-05-12	0
Trey Anastasio	18399	2022-05-12	0
Sonora Tropicana	18400	2022-05-12	0
Viktor Krauss	18401	2022-05-12	0
Lisa Germano	18402	2022-05-12	0
Sebadoh	18403	2022-05-12	0
Abdul Majeed Abdullah	18404	2022-05-12	0
Junior M.A.F.I.A.	18405	2022-05-12	0
Kiko Loureiro	18406	2022-05-12	0
Pagan's Mind	18407	2022-05-12	0
The Barron Knights	18408	2022-05-12	0
Ashley Walters	18409	2022-05-12	0
Kool Keith feat Kutmasta Kurt	18410	2022-05-12	0
La Portuaria	18411	2022-05-12	0
Maureen McGovern	18412	2022-05-12	0
Cândido	18413	2022-05-12	0
Leonard Cohen	18414	2022-05-12	0
4 Or 5 Magicians	18415	2022-05-12	0
Hamilton_ Chico	18416	2022-05-12	0
Klaatu	18417	2022-05-12	0
Shabba Ranks	18418	2022-05-12	0
Arkarna	18419	2022-05-12	0
Charles Manier	18420	2022-05-12	0
Sons Of The Pioneers	18421	2022-05-12	0
Outrageous Cherry	18422	2022-05-12	0
McGuire Sisters	18423	2022-05-12	0
Fred Astaire & Ginger Rogers	18424	2022-05-12	0
The Crimea	18425	2022-05-12	0
Lex Empress	18426	2022-05-12	0
Oesch's die Dritten	18427	2022-05-12	0
Furthermore	18428	2022-05-12	0
Vicente Infante	18429	2022-05-12	0
The Raleigh Ringers	18430	2022-05-12	0
Cascades	18431	2022-05-12	0
Guadaljarafe	18432	2022-05-12	0
Arkona	18433	2022-05-12	0
SUMO	18434	2022-05-12	0
Starmarket	18435	2022-05-12	0
Die Fantastischen Vier	18436	2022-05-12	0
Cold World Hustlers featuring Pookie_ Primo_ Shaw Tek_ Big Mack & Guce	18437	2022-05-12	0
SNAP!	18438	2022-05-12	0
Tony Yayo	18439	2022-05-12	0
Mock Orange	18440	2022-05-12	0
Harry James_ His Orchestra	18441	2022-05-12	0
Luca Bacchetti	18442	2022-05-12	0
Jeff Johnson	18443	2022-05-12	0
Rokker Zsolti	18444	2022-05-12	0
Malory	18445	2022-05-12	0
Stiff Little Fingers	18446	2022-05-12	0
John Vanderslice	18447	2022-05-12	0
Abdoulaye Diabaté	18448	2022-05-12	0
Adele	18449	2022-05-12	0
Lorrie Matheson	18450	2022-05-12	0
Restless	18451	2022-05-12	0
Gary Burton	18452	2022-05-12	0
Pru	18453	2022-05-12	0
Onda Vaselina	18454	2022-05-12	0
Chris Clark	18455	2022-05-12	0
Spice Girls	18456	2022-05-12	0
Frantic Flattops	18457	2022-05-12	0
Tomas Klus	18458	2022-05-12	0
Perrey And Kingsley	18459	2022-05-12	0
DJ Screw	18460	2022-05-12	0
Francisco Mário	18461	2022-05-12	0
John Oswald	18462	2022-05-12	0
Earl Wild	18463	2022-05-12	0
Young Buck	18464	2022-05-12	0
Michael McDonald	18465	2022-05-12	0
Consolidated	18466	2022-05-12	0
Smiley Lewis	18467	2022-05-12	0
Max Tundra	18468	2022-05-12	0
Fudge Fingas	18469	2022-05-12	0
Mount Sims	18470	2022-05-12	0
Vishwamohan Bhatt	18471	2022-05-12	0
Naked on the Vague	18472	2022-05-12	0
Clovis	18473	2022-05-12	0
Jeff Bates	18474	2022-05-12	0
Dexter Romweber	18475	2022-05-12	0
Aycan	18476	2022-05-12	0
Squeeze	18477	2022-05-12	0
Los Chunguitos	18478	2022-05-12	0
Chris Difford	18479	2022-05-12	0
INADE	18480	2022-05-12	0
Ad Bourke	18481	2022-05-12	0
Missy  Elliott feat. Lil' Kim and Mocha	18482	2022-05-12	0
Shaped By Fate	18483	2022-05-12	0
Thaddeus Hogarth	18484	2022-05-12	0
The Young Punx	18485	2022-05-12	0
Ágata	18486	2022-05-12	0
The Maine	18487	2022-05-12	0
La Excepcion	18488	2022-05-12	0
Funkerman	18489	2022-05-12	0
Wynton Marsalis;Kathleen Battle	18490	2022-05-12	0
Flesh 'n' Bone	18491	2022-05-12	0
G4 feat. Sir Cliff Richard	18492	2022-05-12	0
deadboy & the Elephantmen	18493	2022-05-12	0
Parker_ Maceo	18494	2022-05-12	0
Lionel Hamilton & His Orchestra	18495	2022-05-12	0
Joy Electric	18496	2022-05-12	0
The Be Good Tanyas	18497	2022-05-12	0
Roi Heenok	18498	2022-05-12	0
Sole	18499	2022-05-12	0
He-Lium	18500	2022-05-12	0
Diana Vickers	18501	2022-05-12	0
Sunny Day Real Estate	18502	2022-05-12	0
Carole Bayer Sager	18503	2022-05-12	0
joe grushecky & the houserockers	18504	2022-05-12	0
United Future Organization	18505	2022-05-12	0
Scum of the Earth	18506	2022-05-12	0
Lloyd Cole And The Commotions	18507	2022-05-12	0
Mr. John	18508	2022-05-12	0
Ba Cissoko	18509	2022-05-12	0
External Menace	18510	2022-05-12	0
Marcel Woods	18511	2022-05-12	0
Capital	18512	2022-05-12	0
Fear Factory (INT)	18513	2022-05-12	0
Heinrichs & Hirtenfellner	18514	2022-05-12	0
Ensemble	18515	2022-05-12	0
Jenni Vartiainen	18516	2022-05-12	0
John Lennon And The Plastic Ono Band (With The Flux Fiddlers)	18517	2022-05-12	0
Thao with The Get Down Stay Down	18518	2022-05-12	0
Edu K	18519	2022-05-12	0
Mario Lang	18520	2022-05-12	0
Cocoa Tea	18521	2022-05-12	0
Leama and Moor	18522	2022-05-12	0
Phonte featuring Cesar Comanche	18523	2022-05-12	0
Noisy Stylus	18524	2022-05-12	0
Count Your Blessings	18525	2022-05-12	0
Django Reinhardt - Coleman Hawkins	18526	2022-05-12	0
Björn Rosenström	18527	2022-05-12	0
Dennis Scott	18528	2022-05-12	0
The Ghastly Ones	18529	2022-05-12	0
Trick Daddy	18530	2022-05-12	0
Farid Ortiz	18531	2022-05-12	0
Underoath	18532	2022-05-12	0
Flybanger	18533	2022-05-12	0
Demir Demirkan	18534	2022-05-12	0
Nolwenn Leroy	18535	2022-05-12	0
Grateful Dead Tribute	18536	2022-05-12	0
Dave Alvin	18537	2022-05-12	0
Hans Zimmer & Klaus Badelt	18538	2022-05-12	0
In Case Of Fire	18539	2022-05-12	0
Zee Avi	18540	2022-05-12	0
Ray Davies	18541	2022-05-12	0
Anderson Bruford Wakeman Howe	18542	2022-05-12	0
Project Move	18543	2022-05-12	0
Anthony B	18544	2022-05-12	0
Daniel Lanois	18545	2022-05-12	0
Loops Haunt	18546	2022-05-12	0
Geeneus	18547	2022-05-12	0
Don McLean	18548	2022-05-12	0
Jam Hsiao	18549	2022-05-12	0
Hayley Westenra / Humphrey Berney	18550	2022-05-12	0
All Time Low	18551	2022-05-12	0
Ron Carter_ Cedar Walton Duo	18552	2022-05-12	0
Daniel Paul	18553	2022-05-12	0
Acid Factor_ Margie M	18554	2022-05-12	0
Ilya Soloviev	18555	2022-05-12	0
Babyface	18556	2022-05-12	0
The Curse Of The Golden Vampire	18557	2022-05-12	0
Kimera	18558	2022-05-12	0
Skankin' Pickle	18559	2022-05-12	0
Jena Berlin	18560	2022-05-12	0
Clint Eastwood	18561	2022-05-12	0
Dolly Parton & Lynn Anderson	18562	2022-05-12	0
Airbeat One Project	18563	2022-05-12	0
Bosca Banks	18564	2022-05-12	0
Jonas Brothers	18565	2022-05-12	0
The Rascals	18566	2022-05-12	0
The Bo-Keys	18567	2022-05-12	0
Seefeel	18568	2022-05-12	0
Venus	18569	2022-05-12	0
Trebunia Family Band	18570	2022-05-12	0
Studebaker John & The Hawks	18571	2022-05-12	0
Electronicat	18572	2022-05-12	0
Sounds Like Violence	18573	2022-05-12	0
Shakira vs Pacha All Stars	18574	2022-05-12	0
Taste	18575	2022-05-12	0
MC Mabon	18576	2022-05-12	0
La Pandilla	18577	2022-05-12	0
Guillaume Ledent	18578	2022-05-12	0
Ellen Allien	18579	2022-05-12	0
St. Lunatics	18580	2022-05-12	0
Mischief Brew	18581	2022-05-12	0
Rüdiger Hoffmann	18582	2022-05-12	0
D.Y.S.	18583	2022-05-12	0
Chris Willis	18584	2022-05-12	0
Carmen Amaya	18585	2022-05-12	0
Wilderness	18586	2022-05-12	0
Bonnie McKee	18587	2022-05-12	0
Black Tie Revue	18588	2022-05-12	0
Coverdale Page	18589	2022-05-12	0
Brian Tarquin	18590	2022-05-12	0
Brandtson	18591	2022-05-12	0
Los Del Rio	18592	2022-05-12	0
Up_ Bustle & Out	18593	2022-05-12	0
Natasha St-Pier	18594	2022-05-12	0
Todd Bodine & Ludwig Coenen	18595	2022-05-12	0
Leandro Lehart	18596	2022-05-12	0
Laura Welland	18597	2022-05-12	0
Bellyhouse	18598	2022-05-12	0
Einstürzende Neubauten	18599	2022-05-12	0
Cherry Ghost	18600	2022-05-12	0
Jair Rodrigues	18601	2022-05-12	0
Guadalupe Pineda;Trio Flores;Martinez & Muñoz	18602	2022-05-12	0
Silbermond	18603	2022-05-12	0
Shonky	18604	2022-05-12	0
A Few Good Men	18605	2022-05-12	0
Mr. Projectile	18606	2022-05-12	0
Lettermen	18607	2022-05-12	0
Blood Oranges	18608	2022-05-12	0
Maria Dolores Pradera	18609	2022-05-12	0
The Penelopes	18610	2022-05-12	0
Crumbsuckers	18611	2022-05-12	0
The Greenhornes	18612	2022-05-12	0
Heino	18613	2022-05-12	0
Minute By Minute	18614	2022-05-12	0
Ayabie	18615	2022-05-12	0
4 Elements	18616	2022-05-12	0
Tub Ring	18617	2022-05-12	0
Federation featuring E-40	18618	2022-05-12	0
Francis Davila	18619	2022-05-12	0
New Mexican Disaster Squad	18620	2022-05-12	0
Curtis Salgado	18621	2022-05-12	0
Joe Arroyo	18622	2022-05-12	0
Dakis	18623	2022-05-12	0
The Kinks	18624	2022-05-12	0
Karl Jenkins/Catrin Finch/Carmine Lauri/London Symphony Orchestra	18625	2022-05-12	0
Bob Da Rage Sense	18626	2022-05-12	0
Fuckpony	18627	2022-05-12	0
The Bonzo Dog Doo Dah Band	18628	2022-05-12	0
Dr. Hector & The Groove Injectors	18629	2022-05-12	0
B.T Express	18630	2022-05-12	0
Teki Latex	18631	2022-05-12	0
Flesh For Lulu	18632	2022-05-12	0
Mesmer	18633	2022-05-12	0
Whispers In The Shadow	18634	2022-05-12	0
Stray Cats	18635	2022-05-12	0
Deftones	18636	2022-05-12	0
Belvedere	18637	2022-05-12	0
Pinhead Circus	18638	2022-05-12	0
JIM PATTERSON	18639	2022-05-12	0
Carla Bruni	18640	2022-05-12	0
Bronze Nazareth	18641	2022-05-12	0
Spencer Wiggins	18642	2022-05-12	0
Camp Lo	18643	2022-05-12	0
Hard Rock Sofa	18644	2022-05-12	0
Leego	18645	2022-05-12	0
Chris Vickery	18646	2022-05-12	0
Gary Louris	18647	2022-05-12	0
Usherhouse	18648	2022-05-12	0
Jean Claude Ades feat. Rufus Martin	18649	2022-05-12	0
No Cash Value	18650	2022-05-12	0
The Rogers Sisters	18651	2022-05-12	0
Laruso	18652	2022-05-12	0
Mekong Delta	18653	2022-05-12	0
Mary Youngblood	18654	2022-05-12	0
The Raconteurs	18655	2022-05-12	0
William Elliott	18656	2022-05-12	0
Lemon Jelly	18657	2022-05-12	0
Tomas Andersson	18658	2022-05-12	0
DJ Nukem	18659	2022-05-12	0
Miraculix	18660	2022-05-12	0
Fessor's Big City Band	18661	2022-05-12	0
Hassisen Kone	18662	2022-05-12	0
Christina Stürmer	18663	2022-05-12	0
Dum Dum Girls	18664	2022-05-12	0
Seymour Bits	18665	2022-05-12	0
Kinnie Starr	18666	2022-05-12	0
Exile	18667	2022-05-12	0
Playa Smoove	18668	2022-05-12	0
Jazzamor	18669	2022-05-12	0
Sabrina Setlur	18670	2022-05-12	0
Mull Historical Society	18671	2022-05-12	0
Batch	18672	2022-05-12	0
Stanley Huang	18673	2022-05-12	0
The Friends Of Distinction	18674	2022-05-12	0
Anonymous 4	18675	2022-05-12	0
Dead Meadow	18676	2022-05-12	0
Don Reno	18677	2022-05-12	0
Nadia Finkielman	18678	2022-05-12	0
Mixtapes & Cellmates	18679	2022-05-12	0
Ayla Brown	18680	2022-05-12	0
Deodato	18681	2022-05-12	0
Rey Gordiflón	18682	2022-05-12	0
Jen Gloeckner	18683	2022-05-12	0
Barão Vermelho	18684	2022-05-12	0
Spazztic Blurr	18685	2022-05-12	0
The Flesh	18686	2022-05-12	0
Count Bass D	18687	2022-05-12	0
Aborym	18688	2022-05-12	0
AIDS Wolf	18689	2022-05-12	0
Woody Herman & His Orchestra	18690	2022-05-12	0
The Automatic	18691	2022-05-12	0
Wolf & Cub	18692	2022-05-12	0
Eraserheads	18693	2022-05-12	0
Busy Signal	18694	2022-05-12	0
Masters of Reality	18695	2022-05-12	0
William Orbit Feat. Beth Orton	18696	2022-05-12	0
Free Style	18697	2022-05-12	0
BuRo	18698	2022-05-12	0
Green Machine	18699	2022-05-12	0
Gonzalez	18700	2022-05-12	0
Tav Falco	18701	2022-05-12	0
15 Minutes Late	18702	2022-05-12	0
Owl City	18703	2022-05-12	0
The Keytones	18704	2022-05-12	0
Adr Lavey	18705	2022-05-12	0
Lo Borges	18706	2022-05-12	0
Sambassadeur	18707	2022-05-12	0
Charanga Forever	18708	2022-05-12	0
Sundiver	18709	2022-05-12	0
Julie Collings	18710	2022-05-12	0
Botany Bay	18711	2022-05-12	0
Tonino Carotone	18712	2022-05-12	0
Robert Hawkins	18713	2022-05-12	0
Siiri Sisask/Peeter Vähi	18714	2022-05-12	0
Eugenius	18715	2022-05-12	0
Rex The Dog	18716	2022-05-12	0
Element Of Crime	18717	2022-05-12	0
Shawn Camp	18718	2022-05-12	0
Les Négresses Vertes	18719	2022-05-12	0
Abdel Halim Hafez	18720	2022-05-12	0
Aylin Aslim	18721	2022-05-12	0
BeauSoleil	18722	2022-05-12	0
Laura Marling	18723	2022-05-12	0
William Shatner	18724	2022-05-12	0
Che	18725	2022-05-12	0
Mariachi Vargas de Tecalitlan	18726	2022-05-12	0
Mischa Daniels	18727	2022-05-12	0
Olimpo Cárdenas	18728	2022-05-12	0
Stefano Battaglia	18729	2022-05-12	0
Erland And The Carnival	18730	2022-05-12	0
The Honeyz	18731	2022-05-12	0
Michael Convertino	18732	2022-05-12	0
Delroy Wilson	18733	2022-05-12	0
The House Of Usher	18734	2022-05-12	0
Marina Lima	18735	2022-05-12	0
The Departure	18736	2022-05-12	0
Inner Circle / Jacob Miller	18737	2022-05-12	0
The Rivieras	18738	2022-05-12	0
Even In Blackouts	18739	2022-05-12	0
Entombed	18740	2022-05-12	0
Joe Veras	18741	2022-05-12	0
Libido	18742	2022-05-12	0
Nickelback	18743	2022-05-12	0
Pekka Pohjola	18744	2022-05-12	0
Johnny Alf	18745	2022-05-12	0
Porcupine Tree	18746	2022-05-12	0
Roseanna Vitro	18747	2022-05-12	0
Beautiful Sin	18748	2022-05-12	0
Trío Los Panchos	18749	2022-05-12	0
Fond Of Tigers	18750	2022-05-12	0
Los Campesinos	18751	2022-05-12	0
Kaizers Orchestra	18752	2022-05-12	0
The Yips	18753	2022-05-12	0
Army Of Lovers	18754	2022-05-12	0
Norther	18755	2022-05-12	0
Percy Faith & His Orchestra	18756	2022-05-12	0
Jarvis Cocker & Beth Ditto	18757	2022-05-12	0
The Wrens	18758	2022-05-12	0
Big L	18759	2022-05-12	0
Gran Coquivacoa_ Neguito Borjas	18760	2022-05-12	0
Hoxton Whores feat. Krysten Cummings	18761	2022-05-12	0
Max Gueli	18762	2022-05-12	0
The Movielife	18763	2022-05-12	0
So What	18764	2022-05-12	0
Roses Are Red	18765	2022-05-12	0
Andrew Hill	18766	2022-05-12	0
frank bretschneider & taylor deupree	18767	2022-05-12	0
Billie The Vision & The Dancers	18768	2022-05-12	0
The Crack	18769	2022-05-12	0
Let's Active	18770	2022-05-12	0
Siobhan McCarthy / Louise Plowright / Jenny Galloway / Neal Wright	18771	2022-05-12	0
Evolution	18772	2022-05-12	0
Luniz Featuring Michael Marshall	18773	2022-05-12	0
Creedence Clearwater Revival	18774	2022-05-12	0
Joelho De Porco	18775	2022-05-12	0
Lambert_ Hendricks & Ross	18776	2022-05-12	0
Horse Feathers	18777	2022-05-12	0
Sorcery	18778	2022-05-12	0
Survivor	18779	2022-05-12	0
Los Ronaldos	18780	2022-05-12	0
American Blues	18781	2022-05-12	0
The Weavers	18782	2022-05-12	0
Mitsoobishy Jacson	18783	2022-05-12	0
Embryo	18784	2022-05-12	0
The Vichy Government	18785	2022-05-12	0
Jealousy	18786	2022-05-12	0
Leon McAuliffe	18787	2022-05-12	0
Perfect Stranger	18788	2022-05-12	0
X	18789	2022-05-12	0
Avery	18790	2022-05-12	0
Paul Colman Trio	18791	2022-05-12	0
Ti N'enfants	18792	2022-05-12	0
Cassy & die Krokokids	18793	2022-05-12	0
Smoker	18794	2022-05-12	0
Freak Power	18795	2022-05-12	0
Plasmatics	18796	2022-05-12	0
Infinite Livez	18797	2022-05-12	0
Kommunity FK	18798	2022-05-12	0
Twinemen	18799	2022-05-12	0
Joakim	18800	2022-05-12	0
Nereus Joseph	18801	2022-05-12	0
The Commitments / Andrew Strong	18802	2022-05-12	0
Gian Marco	18803	2022-05-12	0
Dropkick Murphys	18804	2022-05-12	0
Bruni Bergeron	18805	2022-05-12	0
The Pietasters	18806	2022-05-12	0
NARNIA	18807	2022-05-12	0
The Aggrovators	18808	2022-05-12	0
Cymarshall Law feat. DJ JS-1	18809	2022-05-12	0
To Be a High Powered Executive	18810	2022-05-12	0
Chloé	18811	2022-05-12	0
Will Holland Pres. Holla	18812	2022-05-12	0
Herman Brood	18813	2022-05-12	0
Lucky Loop	18814	2022-05-12	0
The Payoff	18815	2022-05-12	0
Povia	18816	2022-05-12	0
Clockcleaner	18817	2022-05-12	0
Chisel	18818	2022-05-12	0
Ian Siegal	18819	2022-05-12	0
Phil Ochs	18820	2022-05-12	0
Kero One	18821	2022-05-12	0
Chick Corea & Hiromi	18822	2022-05-12	0
Josh Gabriel	18823	2022-05-12	0
Bronski Beat And Marc Almond	18824	2022-05-12	0
Soda Stereo	18825	2022-05-12	0
Pyeng Threadgill	18826	2022-05-12	0
Major Lazer / Turbulence	18827	2022-05-12	0
another day	18828	2022-05-12	0
Supuer	18829	2022-05-12	0
The Nextmen / Alice Russell	18830	2022-05-12	0
Mannick	18831	2022-05-12	0
Mutandina	18832	2022-05-12	0
BEFORE THE DAWN	18833	2022-05-12	0
Tony Mac Mahon_ Noel Hill & Iarla O Lionaird	18834	2022-05-12	0
Pink Skull	18835	2022-05-12	0
Leo Kottke;Michael Gordon	18836	2022-05-12	0
Federico Aubele	18837	2022-05-12	0
Filarmónica Gil	18838	2022-05-12	0
Barry & The Remains	18839	2022-05-12	0
The Love Unlimited Orchestra	18840	2022-05-12	0
Niño De Marchena	18841	2022-05-12	0
The Wolfgang Press	18842	2022-05-12	0
Causa Sui	18843	2022-05-12	0
Amy Grant	18844	2022-05-12	0
Karelian Warcry	18845	2022-05-12	0
Bill Withers	18846	2022-05-12	0
Chris Liebing & Andre Walter	18847	2022-05-12	0
We Should Be Dead	18848	2022-05-12	0
Neeme Jarvi	18849	2022-05-12	0
Piskie Sits	18850	2022-05-12	0
Rawley Taylor	18851	2022-05-12	0
Desert City Soundtrack	18852	2022-05-12	0
Bullets And Octane	18853	2022-05-12	0
Pan.thy.monium	18854	2022-05-12	0
Sonny James	18855	2022-05-12	0
Tam Tam Go	18856	2022-05-12	0
Alex Beaupain	18857	2022-05-12	0
David Cassidy & The Partridge Family	18858	2022-05-12	0
Bola	18859	2022-05-12	0
Tiger Lou	18860	2022-05-12	0
Till Brönner / Sergio Mendes	18861	2022-05-12	0
Melissa Ferrick	18862	2022-05-12	0
Eastman	18863	2022-05-12	0
Thee More Shallows	18864	2022-05-12	0
Toque De Prima	18865	2022-05-12	0
Tracie Spencer	18866	2022-05-12	0
Tosch	18867	2022-05-12	0
Isao Tomita	18868	2022-05-12	0
Bunny Wailer	18869	2022-05-12	0
London Funk Allstars	18870	2022-05-12	0
Goulasch Exotica	18871	2022-05-12	0
Alpinestars	18872	2022-05-12	0
Dave Specter	18873	2022-05-12	0
Laidback Luke	18874	2022-05-12	0
Black Light Discipline	18875	2022-05-12	0
Blood For Blood	18876	2022-05-12	0
Zachary Richard	18877	2022-05-12	0
Cheb Bilal	18878	2022-05-12	0
Gang Starr	18879	2022-05-12	0
Mankind DC	18880	2022-05-12	0
Mahya	18881	2022-05-12	0
Juçara Marçal e Kiko Dinucci	18882	2022-05-12	0
Pär Grindvik	18883	2022-05-12	0
Egotrippi	18884	2022-05-12	0
Trife Diesel	18885	2022-05-12	0
New Electronic Soundsystem	18886	2022-05-12	0
Carmen McRae	18887	2022-05-12	0
Márcio Faraco	18888	2022-05-12	0
Tingsek	18889	2022-05-12	0
The Steeles	18890	2022-05-12	0
Wildlife	18891	2022-05-12	0
Mr. T Experience	18892	2022-05-12	0
Gisele MacKenzie	18893	2022-05-12	0
Boys Like Girls	18894	2022-05-12	0
Zero Gravity	18895	2022-05-12	0
Warsaw Poland Bros.	18896	2022-05-12	0
Son of Light	18897	2022-05-12	0
Lola Flores	18898	2022-05-12	0
Williams Brothers	18899	2022-05-12	0
George Clinton	18900	2022-05-12	0
Domingo y los Citricos (F)	18901	2022-05-12	0
Journey & Mental Broadcast	18902	2022-05-12	0
Stomy Bugsy	18903	2022-05-12	0
Dotsero	18904	2022-05-12	0
Flor Silvestre	18905	2022-05-12	0
Meat Katie and Elite Force feat Roland Clark	18906	2022-05-12	0
Soneros de Verdad	18907	2022-05-12	0
Arcady	18908	2022-05-12	0
Duke Ellington And His Orchestra	18909	2022-05-12	0
The Mist Of Avalon	18910	2022-05-12	0
Intuit	18911	2022-05-12	0
Cargo Cult	18912	2022-05-12	0
Organism 12 / Promoe	18913	2022-05-12	0
Magnitude 9	18914	2022-05-12	0
Baba Zula & Mad Professor	18915	2022-05-12	0
The New Frontiers	18916	2022-05-12	0
Alceu Valença	18917	2022-05-12	0
Gianni Celeste	18918	2022-05-12	0
Kamikaze	18919	2022-05-12	0
Charlie Feathers	18920	2022-05-12	0
Micall Parknsun	18921	2022-05-12	0
Carnifex	18922	2022-05-12	0
The Spark	18923	2022-05-12	0
Hugo Montenegro & His Orchestra	18924	2022-05-12	0
Les Compagnons De La Chanson	18925	2022-05-12	0
Tommy McClennan	18926	2022-05-12	0
Twila Paris	18927	2022-05-12	0
If Lucy Fell	18928	2022-05-12	0
Billy Childish & the Singing Loins	18929	2022-05-12	0
Three 6 Mafia	18930	2022-05-12	0
Klaxons	18931	2022-05-12	0
Kayah	18932	2022-05-12	0
Jan Gustafsson	18933	2022-05-12	0
Kleinstadthelden	18934	2022-05-12	0
The Jazz June	18935	2022-05-12	0
Mick Clarke	18936	2022-05-12	0
Haywoode	18937	2022-05-12	0
Jamie Foxx featuring Marsha Ambrosius	18938	2022-05-12	0
Hjaltalin	18939	2022-05-12	0
Jimmy Johnson	18940	2022-05-12	0
Crystal Castles	18941	2022-05-12	0
Webstar / Teyana Taylor / Young B	18942	2022-05-12	0
Jody Reynolds	18943	2022-05-12	0
Boomkat	18944	2022-05-12	0
Awesome Color	18945	2022-05-12	0
Scary Kids Scaring Kids	18946	2022-05-12	0
Queen	18947	2022-05-12	0
IfIHadAHifi	18948	2022-05-12	0
Tiny Tim with Miss Vicki	18949	2022-05-12	0
Bobby Broom	18950	2022-05-12	0
Success Will Write Apocalypse Across The Sky	18951	2022-05-12	0
JP-Juice	18952	2022-05-12	0
Artemis / Efthimis	18953	2022-05-12	0
Warren Clarke feat. Shena	18954	2022-05-12	0
Royals	18955	2022-05-12	0
Carl Perkins	18956	2022-05-12	0
Stee Wee Bee	18957	2022-05-12	0
Chrome Dreams - CD Audio Series	18958	2022-05-12	0
Original Naabtal Duo	18959	2022-05-12	0
Jimmy Ross	18960	2022-05-12	0
Caparezza	18961	2022-05-12	0
Green River Ordinance	18962	2022-05-12	0
The Vapors	18963	2022-05-12	0
Carlos Gardel	18964	2022-05-12	0
Joe Liggins	18965	2022-05-12	0
Matisse	18966	2022-05-12	0
Daniel Balavoine	18967	2022-05-12	0
Top Billin	18968	2022-05-12	0
Neshama Carlebach	18969	2022-05-12	0
Aden	18970	2022-05-12	0
Engineers	18971	2022-05-12	0
Solomon Burke	18972	2022-05-12	0
DARKANE	18973	2022-05-12	0
Randy & The Rainbows	18974	2022-05-12	0
Faron Young & Anita Kerr Singers	18975	2022-05-12	0
Jil Caplan	18976	2022-05-12	0
Denise Lasalle	18977	2022-05-12	0
Freedom Call	18978	2022-05-12	0
Blue System	18979	2022-05-12	0
Loredana Berte	18980	2022-05-12	0
The Fire Still Burns	18981	2022-05-12	0
Tommy Newsom	18982	2022-05-12	0
New Identity	18983	2022-05-12	0
Frisco	18984	2022-05-12	0
Lee Ryan	18985	2022-05-12	0
Five Keys	18986	2022-05-12	0
Galerie Schallschutz	18987	2022-05-12	0
Recycler	18988	2022-05-12	0
M Trill	18989	2022-05-12	0
Glyder	18990	2022-05-12	0
PrinzPorno_ Fumanschu & Rufmord	18991	2022-05-12	0
Francisca Valenzuela	18992	2022-05-12	0
Dave Derby & The Norfolk Downs	18993	2022-05-12	0
The Robert Cray Band / The Memphis Horns	18994	2022-05-12	0
Nattefrost	18995	2022-05-12	0
Children 18:3	18996	2022-05-12	0
Polly Scattergood	18997	2022-05-12	0
Tone Float	18998	2022-05-12	0
Cristian Paduraru	18999	2022-05-12	0
Hypo	19000	2022-05-12	0
Pinback	19001	2022-05-12	0
The Lively Ones	19002	2022-05-12	0
Bruce Dickinson	19003	2022-05-12	0
Mad EP	19004	2022-05-12	0
Dinu Lipatti	19005	2022-05-12	0
PPFC	19006	2022-05-12	0
School Of Seven Bells	19007	2022-05-12	0
Dan Deacon	19008	2022-05-12	0
Amebix	19009	2022-05-12	0
Zion I feat. Devin The Dude	19010	2022-05-12	0
Soweto String Quartet;Reuben Khemese;Sandile Khemese;Thami Khemese;Makhosini Mnguni	19011	2022-05-12	0
Ray Brown Trio	19012	2022-05-12	0
Russel Garcia	19013	2022-05-12	0
Casino Royale	19014	2022-05-12	0
Ron Carter / Eric Dolphy / Mal Waldron	19015	2022-05-12	0
Andre Crom & Martin Dawson	19016	2022-05-12	0
SkinnyMan	19017	2022-05-12	0
Greatdayforup	19018	2022-05-12	0
Cirrus	19019	2022-05-12	0
Band Of The US Air Force Reserve	19020	2022-05-12	0
Texas	19021	2022-05-12	0
Christian Quast	19022	2022-05-12	0
Flint Glass	19023	2022-05-12	0
Pain of Salvation	19024	2022-05-12	0
Dan Moretti	19025	2022-05-12	0
Kenan Teke	19026	2022-05-12	0
Walter Horton	19027	2022-05-12	0
Pascal Parisot	19028	2022-05-12	0
Willie Nelson;Ray Price	19029	2022-05-12	0
Huffamoose	19030	2022-05-12	0
Frame	19031	2022-05-12	0
Kim Weston	19032	2022-05-12	0
The Highwaymen	19033	2022-05-12	0
Lisahall	19034	2022-05-12	0
Harry Simeone Chorale	19035	2022-05-12	0
Jean-Claude Darnal	19036	2022-05-12	0
Shawn Rudiman	19037	2022-05-12	0
Integrity	19038	2022-05-12	0
Justin Hayward / John Lodge	19039	2022-05-12	0
The Suicide Machines	19040	2022-05-12	0
Yttling Jazz	19041	2022-05-12	0
Jeri Southern	19042	2022-05-12	0
Roberto Jordan	19043	2022-05-12	0
Bruce BecVar	19044	2022-05-12	0
Revolver	19045	2022-05-12	0
Organ	19046	2022-05-12	0
Nate Mezmer	19047	2022-05-12	0
Danny Byrd	19048	2022-05-12	0
Mark Isham	19049	2022-05-12	0
Jennifer Brown	19050	2022-05-12	0
Northern Lite	19051	2022-05-12	0
Alex Kunnari	19052	2022-05-12	0
Aural Float	19053	2022-05-12	0
Lil Wayne	19054	2022-05-12	0
Jan Johnston	19055	2022-05-12	0
Dorsey Burnette	19056	2022-05-12	0
Yolanda Del Rio	19057	2022-05-12	0
Motel	19058	2022-05-12	0
Son Volt	19059	2022-05-12	0
The Boones	19060	2022-05-12	0
The Rambos	19061	2022-05-12	0
5th Element	19062	2022-05-12	0
Wealthy Beggar	19063	2022-05-12	0
Téléphone	19064	2022-05-12	0
The Bureau De Change	19065	2022-05-12	0
Scalplock	19066	2022-05-12	0
Logh	19067	2022-05-12	0
Dubnoodles	19068	2022-05-12	0
Jorge Negrete Y Su Mariachi	19069	2022-05-12	0
Delinquent Habits	19070	2022-05-12	0
Percy Mayfield	19071	2022-05-12	0
Lenny Fontana & Ridney pres. Larisa	19072	2022-05-12	0
Spektr	19073	2022-05-12	0
N.E.R.D.	19074	2022-05-12	0
FC apatride UTD	19075	2022-05-12	0
Conor Oberst	19076	2022-05-12	0
Ike Turner	19077	2022-05-12	0
The Man Behind C.	19078	2022-05-12	0
Gonga	19079	2022-05-12	0
Luciana Souza	19080	2022-05-12	0
Kristin Mainhart	19081	2022-05-12	0
The Misted Muppet	19082	2022-05-12	0
Gentleman	19083	2022-05-12	0
Candie Hank	19084	2022-05-12	0
Stellar Kart	19085	2022-05-12	0
The Chosen Gospel Singers	19086	2022-05-12	0
Harold Faltermeyer	19087	2022-05-12	0
Genesis Elijah	19088	2022-05-12	0
Heroine Sheiks	19089	2022-05-12	0
Ultraviolet	19090	2022-05-12	0
The End	19091	2022-05-12	0
Twisted Sister	19092	2022-05-12	0
Troublemakers	19093	2022-05-12	0
Starbreaker	19094	2022-05-12	0
DJ Paul	19095	2022-05-12	0
The Impalas	19096	2022-05-12	0
Roger Miret_The Disasters	19097	2022-05-12	0
Terry Muska	19098	2022-05-12	0
Klaus & Kinski	19099	2022-05-12	0
Nightswimmer	19100	2022-05-12	0
The Upsetters	19101	2022-05-12	0
Allan Sherman	19102	2022-05-12	0
The Lox featuring DMX and Lil' Kim	19103	2022-05-12	0
Eino Grön	19104	2022-05-12	0
Peter Green	19105	2022-05-12	0
sun electric	19106	2022-05-12	0
Harry Belafonte_ Harry Belafonte	19107	2022-05-12	0
Brenda Lee	19108	2022-05-12	0
Joe Williams (feat. Ben Webster)	19109	2022-05-12	0
Aghast View	19110	2022-05-12	0
Kapoor	19111	2022-05-12	0
Dag För Dag	19112	2022-05-12	0
D'angelo Featuring Method Man And Redman	19113	2022-05-12	0
A Golden Pony Boy	19114	2022-05-12	0
Penha Pinheiro	19115	2022-05-12	0
Ian Anderson	19116	2022-05-12	0
I Spy	19117	2022-05-12	0
Luther Allison	19118	2022-05-12	0
Sinne Eeg	19119	2022-05-12	0
Justice Yeldham	19120	2022-05-12	0
Fireflight	19121	2022-05-12	0
Foxy Brown	19122	2022-05-12	0
Intocable	19123	2022-05-12	0
Van Hunt	19124	2022-05-12	0
D'Angelo	19125	2022-05-12	0
RAGHAV	19126	2022-05-12	0
Westernhagen (WEA)	19127	2022-05-12	0
Amii Stewart	19128	2022-05-12	0
Vishal|A.R.Rehman|Anu Malik	19129	2022-05-12	0
Man is the Bastard	19130	2022-05-12	0
Babes In Toyland	19131	2022-05-12	0
Mutabor	19132	2022-05-12	0
Les Trois Accords	19133	2022-05-12	0
Johnny Darrell	19134	2022-05-12	0
El Coyote Y Su Banda Tierra Santa	19135	2022-05-12	0
Alexkid - Remix By Seep	19136	2022-05-12	0
The Strings Of Paris	19137	2022-05-12	0
Angel Witch	19138	2022-05-12	0
Familia Valera Miranda	19139	2022-05-12	0
James Blake	19140	2022-05-12	0
Steve Cradock	19141	2022-05-12	0
Larry McCray	19142	2022-05-12	0
Vince Guaraldi / St. Paul's Church Of San Rafael	19143	2022-05-12	0
Frans Bauer;Corry Konings	19144	2022-05-12	0
Delirium Tremens	19145	2022-05-12	0
Jelly Roll Kings	19146	2022-05-12	0
Otomo Yoshihide	19147	2022-05-12	0
Honeyboy Edwards	19148	2022-05-12	0
Neva Dinova	19149	2022-05-12	0
4 Promille	19150	2022-05-12	0
Domna Kountouri	19151	2022-05-12	0
John Arch	19152	2022-05-12	0
Belphegor	19153	2022-05-12	0
Elie Attieh	19154	2022-05-12	0
Early Day Miners	19155	2022-05-12	0
Alex Rize	19156	2022-05-12	0
Los Planetas	19157	2022-05-12	0
Manolo Garcia	19158	2022-05-12	0
One Bad Pig	19159	2022-05-12	0
Ella Fitzgerald & Louis Armstrong	19160	2022-05-12	0
Chezidek	19161	2022-05-12	0
Hitechjet	19162	2022-05-12	0
Carte De Sejour	19163	2022-05-12	0
The Hentchmen	19164	2022-05-12	0
Young Dro	19165	2022-05-12	0
Quad City DJ's	19166	2022-05-12	0
Céline Dion	19167	2022-05-12	0
Black Coffey	19168	2022-05-12	0
Naggo Morris	19169	2022-05-12	0
Tito Allen	19170	2022-05-12	0
Aline Barros	19171	2022-05-12	0
Lovex	19172	2022-05-12	0
The Karl Hendricks Rock Band	19173	2022-05-12	0
The Ducky Boys	19174	2022-05-12	0
Oranger	19175	2022-05-12	0
Long Beach Dub Allstars	19176	2022-05-12	0
Wolfmother	19177	2022-05-12	0
Baaba Maal	19178	2022-05-12	0
Thieves Like Us	19179	2022-05-12	0
Portugal The Man	19180	2022-05-12	0
King Terra	19181	2022-05-12	0
Syd Dale	19182	2022-05-12	0
Jhené	19183	2022-05-12	0
Today Is The Day	19184	2022-05-12	0
Duke Ellington Orchestra	19185	2022-05-12	0
Krishnanda	19186	2022-05-12	0
Elmer Bernstein	19187	2022-05-12	0
Health	19188	2022-05-12	0
Hangedup	19189	2022-05-12	0
The Jesus Lizard	19190	2022-05-12	0
Chemical Brothers Tribute Group	19191	2022-05-12	0
The Balancing Act	19192	2022-05-12	0
Laith Al-Deen;Zoe	19193	2022-05-12	0
Steve Hackett	19194	2022-05-12	0
Guy	19195	2022-05-12	0
Mandy Patinkin	19196	2022-05-12	0
Pandit Shiv Kumar Sharma	19197	2022-05-12	0
Ronnie Montrose	19198	2022-05-12	0
Mario Bauzá	19199	2022-05-12	0
Brian Setzer Orchestra	19200	2022-05-12	0
Cardopusher	19201	2022-05-12	0
Nu Brand Flexxx ft. James Collins_ Chanelle & Fat Narstie	19202	2022-05-12	0
Simon Grey	19203	2022-05-12	0
Leroy Sibbles	19204	2022-05-12	0
Sage Francis	19205	2022-05-12	0
Gladiators	19206	2022-05-12	0
Venom	19207	2022-05-12	0
SPM	19208	2022-05-12	0
Natasha Bedingfield	19209	2022-05-12	0
Lonnie Donegan	19210	2022-05-12	0
The Locos	19211	2022-05-12	0
Harrie Jekkers	19212	2022-05-12	0
Absurd Minds	19213	2022-05-12	0
Tad Morose	19214	2022-05-12	0
Girma Hadgu	19215	2022-05-12	0
Treizième Étage	19216	2022-05-12	0
Robert Donat/Philharmonia Orchestra/Alan Rawsthorne	19217	2022-05-12	0
Dannii Minogue	19218	2022-05-12	0
Dutch Master	19219	2022-05-12	0
Bug Mafia	19220	2022-05-12	0
Life Of Agony	19221	2022-05-12	0
Un pinguino en mi ascensor	19222	2022-05-12	0
Aeoliah	19223	2022-05-12	0
Graham Colton	19224	2022-05-12	0
Louis Chédid	19225	2022-05-12	0
Soweto Gospel Choir	19226	2022-05-12	0
tyDi	19227	2022-05-12	0
Honey Cone	19228	2022-05-12	0
Janette Slack	19229	2022-05-12	0
Ever Stays Red	19230	2022-05-12	0
Unknown Artist	19231	2022-05-12	0
Vincent Kwok	19232	2022-05-12	0
Buster Brown	19233	2022-05-12	0
Stix featuring Lova Boy	19234	2022-05-12	0
Leopoldo Federico	19235	2022-05-12	0
Cuba	19236	2022-05-12	0
Global Deejays Feat. Rozalla	19237	2022-05-12	0
Canzoniere Grecanico Salentino	19238	2022-05-12	0
The Insects	19239	2022-05-12	0
Au Pairs	19240	2022-05-12	0
Dominique A	19241	2022-05-12	0
The Dodos	19242	2022-05-12	0
Kadoc	19243	2022-05-12	0
Khan	19244	2022-05-12	0
Clare Teal	19245	2022-05-12	0
The Northern Pikes	19246	2022-05-12	0
Ladanybene 27	19247	2022-05-12	0
Blurt	19248	2022-05-12	0
Slapshot	19249	2022-05-12	0
Quiet Riot	19250	2022-05-12	0
BENEDICTION	19251	2022-05-12	0
The Dreamtree Project	19252	2022-05-12	0
They Came From The Stars I Saw Them	19253	2022-05-12	0
Richie Kelly	19254	2022-05-12	0
Carla Bozulich	19255	2022-05-12	0
Brooklyn Funk Essentials	19256	2022-05-12	0
Fudge Fingas & His Fidgety Friends	19257	2022-05-12	0
Ron Spielman	19258	2022-05-12	0
Tor Cesay	19259	2022-05-12	0
The Secret Life of Teenage Girls	19260	2022-05-12	0
Nanook Of The North	19261	2022-05-12	0
Hatchback	19262	2022-05-12	0
Cortney Tidwell	19263	2022-05-12	0
The Egyptian Lover	19264	2022-05-12	0
Maurice Williams & The Zodiacs	19265	2022-05-12	0
Metronomy	19266	2022-05-12	0
Mark Foggo	19267	2022-05-12	0
Ultimate Breaks & Beats	19268	2022-05-12	0
Velcro Stars	19269	2022-05-12	0
matchbox twenty	19270	2022-05-12	0
Shy FX & T-Power feat. Di & Skibadee	19271	2022-05-12	0
Upside Down Room	19272	2022-05-12	0
Cosmic Tramp	19273	2022-05-12	0
Noel Coward	19274	2022-05-12	0
Brian Tyler	19275	2022-05-12	0
Battles	19276	2022-05-12	0
The Style Council	19277	2022-05-12	0
Fereidoon Foroughi	19278	2022-05-12	0
Le Orme	19279	2022-05-12	0
Bo Diddley	19280	2022-05-12	0
Fred Thomas	19281	2022-05-12	0
Nasty Idols	19282	2022-05-12	0
Toad	19283	2022-05-12	0
Havok	19284	2022-05-12	0
Avicii	19285	2022-05-12	0
Fiona Boyes	19286	2022-05-12	0
Jason Mraz	19287	2022-05-12	0
4 Non Blondes	19288	2022-05-12	0
Sabor De Gracia	19289	2022-05-12	0
Rose Funeral	19290	2022-05-12	0
Shakti with John McLaughlin	19291	2022-05-12	0
Shiny Beast	19292	2022-05-12	0
God Module	19293	2022-05-12	0
DJ Gregory	19294	2022-05-12	0
The Power Station	19295	2022-05-12	0
Total Science Ft. Riya	19296	2022-05-12	0
Frog Eyes	19297	2022-05-12	0
Gino Vannelli	19298	2022-05-12	0
Drake Bell	19299	2022-05-12	0
June Christy	19300	2022-05-12	0
Jean F. Cochois	19301	2022-05-12	0
Stratus Sur Le Plateau	19302	2022-05-12	0
Superbutt	19303	2022-05-12	0
Silence	19304	2022-05-12	0
Pocket Full Of Rocks	19305	2022-05-12	0
Ellis Paul	19306	2022-05-12	0
Claire Lynch	19307	2022-05-12	0
Armani & Ghost	19308	2022-05-12	0
Arne Weise	19309	2022-05-12	0
Joyce Sims	19310	2022-05-12	0
Rogelio Martínez	19311	2022-05-12	0
Laura Nyro	19312	2022-05-12	0
ZPU	19313	2022-05-12	0
Batmobile	19314	2022-05-12	0
Jamelão	19315	2022-05-12	0
Free	19316	2022-05-12	0
El Indio Gitano	19317	2022-05-12	0
Plan B	19318	2022-05-12	0
Aborted	19319	2022-05-12	0
Fozzy	19320	2022-05-12	0
Swat-Squad featuring Naph	19321	2022-05-12	0
Moonbootica	19322	2022-05-12	0
Deepswing	19323	2022-05-12	0
Tricky	19324	2022-05-12	0
We Rock Like Girls Don't	19325	2022-05-12	0
The Ship	19326	2022-05-12	0
Cuba Club	19327	2022-05-12	0
Leama & Moor	19328	2022-05-12	0
Salt The Wound	19329	2022-05-12	0
Bassi Maestro	19330	2022-05-12	0
Tommy Körberg / Solar Plexus / Bagge & Sons / Tage Danielsson	19331	2022-05-12	0
Leci Brandao	19332	2022-05-12	0
Portmanteau	19333	2022-05-12	0
Tarkan	19334	2022-05-12	0
Driver Eight	19335	2022-05-12	0
Bad Manners	19336	2022-05-12	0
Michael Martin Murphey	19337	2022-05-12	0
Quinteto Violado	19338	2022-05-12	0
Serge Gainsbourg	19339	2022-05-12	0
Paul Winter	19340	2022-05-12	0
Mathew Jonson	19341	2022-05-12	0
Raul Midón	19342	2022-05-12	0
2raumwohnung	19343	2022-05-12	0
YOURCODENAMEIS:MILO	19344	2022-05-12	0
Shantel feat. Binder & Krieglstein	19345	2022-05-12	0
Fiordaliso	19346	2022-05-12	0
The Mob Figaz Meet Marvaless	19347	2022-05-12	0
Sons of Perdition	19348	2022-05-12	0
Eldkvarn	19349	2022-05-12	0
Equilibrio Vital	19350	2022-05-12	0
Hemisphere	19351	2022-05-12	0
The Albion Band	19352	2022-05-12	0
Doris Duke	19353	2022-05-12	0
Freddie Mcgregor Feat. Papa San	19354	2022-05-12	0
Vitamin X	19355	2022-05-12	0
Elan / Assassin	19356	2022-05-12	0
The Bears	19357	2022-05-12	0
D.C. Anderson	19358	2022-05-12	0
Fee	19359	2022-05-12	0
Madeleine Peyroux	19360	2022-05-12	0
M.A. Numminen	19361	2022-05-12	0
Everly Brothers	19362	2022-05-12	0
Dark by Design & Alex kidd	19363	2022-05-12	0
Bob Cheevers	19364	2022-05-12	0
Lonestar	19365	2022-05-12	0
Schizoid	19366	2022-05-12	0
Atomic 61	19367	2022-05-12	0
Ultima	19368	2022-05-12	0
Sub Swara featuring MC Coppa	19369	2022-05-12	0
Van Morrison	19370	2022-05-12	0
Rita Wright	19371	2022-05-12	0
Rocketship	19372	2022-05-12	0
Chingo Bling w/ Paul Wall	19373	2022-05-12	0
Jimmy Riley	19374	2022-05-12	0
Dave Aju	19375	2022-05-12	0
Lenny Williams	19376	2022-05-12	0
Inner City Unit	19377	2022-05-12	0
Tasavallan Presidentti	19378	2022-05-12	0
Siouxsie	19379	2022-05-12	0
Ram Jam	19380	2022-05-12	0
Terror	19381	2022-05-12	0
The Machine	19382	2022-05-12	0
Sandrine	19383	2022-05-12	0
Borknagar	19384	2022-05-12	0
Frank Sinatra & Nat King Cole	19385	2022-05-12	0
And Also the Trees	19386	2022-05-12	0
Reflex	19387	2022-05-12	0
Biréli Lagrène	19388	2022-05-12	0
Elliot Sharp	19389	2022-05-12	0
Vassar Clements	19390	2022-05-12	0
40 Glocc	19391	2022-05-12	0
TwoOfUs	19392	2022-05-12	0
Oumou Sangare	19393	2022-05-12	0
The Wes Montgomery Trio	19394	2022-05-12	0
Ding Dong	19395	2022-05-12	0
Tenores Di Bitti	19396	2022-05-12	0
Gurdas Maan	19397	2022-05-12	0
Fronda	19398	2022-05-12	0
Lawrence Welk	19399	2022-05-12	0
ItaloBrothers	19400	2022-05-12	0
Tigertailz	19401	2022-05-12	0
A.M.R.	19402	2022-05-12	0
Huey 'Piano' Smith	19403	2022-05-12	0
Attack Flamingo	19404	2022-05-12	0
Tena Stelin	19405	2022-05-12	0
Kanji Kinetic	19406	2022-05-12	0
Cortex Thrill	19407	2022-05-12	0
Squallor	19408	2022-05-12	0
Tito Rojas	19409	2022-05-12	0
India.Arie	19410	2022-05-12	0
Bent	19411	2022-05-12	0
Mousse T. Vs Hot 'n' Juicy	19412	2022-05-12	0
The Gay Blades	19413	2022-05-12	0
Big Star	19414	2022-05-12	0
Jon Finn Group	19415	2022-05-12	0
Marc Romboy vs. Booka Shade	19416	2022-05-12	0
Major Worries	19417	2022-05-12	0
Camille Saint-Saens	19418	2022-05-12	0
Björn Skifs/Lars Samuelsons Orkester	19419	2022-05-12	0
Steve Jablonsky	19420	2022-05-12	0
Andy Fairweather-Low	19421	2022-05-12	0
Aleks Syntek	19422	2022-05-12	0
Yuppie Pricks	19423	2022-05-12	0
Brian May	19424	2022-05-12	0
Creature With the Atom Brain	19425	2022-05-12	0
The Dishrags	19426	2022-05-12	0
Propellerheads	19427	2022-05-12	0
Blue States	19428	2022-05-12	0
Department S	19429	2022-05-12	0
Seiji	19430	2022-05-12	0
Tommy Tee	19431	2022-05-12	0
Def Wish Cast	19432	2022-05-12	0
NightBreed	19433	2022-05-12	0
Chuck Ragan	19434	2022-05-12	0
Amjad Ali Khan	19435	2022-05-12	0
Los Hermanos	19436	2022-05-12	0
Chihiro Onitsuka	19437	2022-05-12	0
Pete Philly & Perquisite	19438	2022-05-12	0
Grandpa Jones	19439	2022-05-12	0
Jan A.P. Kaczmarek	19440	2022-05-12	0
NQ Arbuckle	19441	2022-05-12	0
Fred Frith and Arte Quartett with Katharina Weber and Lucas Niggli	19442	2022-05-12	0
Namosh	19443	2022-05-12	0
Lili Boniche	19444	2022-05-12	0
Omni	19445	2022-05-12	0
El Charrito Negro	19446	2022-05-12	0
Despised Icon	19447	2022-05-12	0
J. B. Lenoir	19448	2022-05-12	0
Chambao	19449	2022-05-12	0
Huey	19450	2022-05-12	0
yoomiii	19451	2022-05-12	0
The Old Scratch Revival Singers	19452	2022-05-12	0
Gary Numan / Tubeway Army	19453	2022-05-12	0
H2K	19454	2022-05-12	0
The Herb Spectacles	19455	2022-05-12	0
Little Feat	19456	2022-05-12	0
Martina McBride	19457	2022-05-12	0
Gerry Mulligan Quartet / Chet Baker	19458	2022-05-12	0
George Ducas	19459	2022-05-12	0
Electricity In Our Homes	19460	2022-05-12	0
Billy Joe Shaver	19461	2022-05-12	0
Sadat X_ Diamond D.	19462	2022-05-12	0
Franek Kimono	19463	2022-05-12	0
Vicki Vomit	19464	2022-05-12	0
Basshunter	19465	2022-05-12	0
Chris Rock	19466	2022-05-12	0
Sly & Robbie	19467	2022-05-12	0
Shockabilly	19468	2022-05-12	0
The Mustangs	19469	2022-05-12	0
Karaoke Star Explosion	19470	2022-05-12	0
Camané	19471	2022-05-12	0
Lacuna Coil	19472	2022-05-12	0
Jon Lucien	19473	2022-05-12	0
Alejandro Santiago	19474	2022-05-12	0
Outcry Collective	19475	2022-05-12	0
Gatas Parlament	19476	2022-05-12	0
Hawaii Mud Bombers	19477	2022-05-12	0
Ercola Vs. Heikki L	19478	2022-05-12	0
Vanessa Carlton	19479	2022-05-12	0
Petra	19480	2022-05-12	0
Huma	19481	2022-05-12	0
Luke Bryan	19482	2022-05-12	0
Blonde Redhead	19483	2022-05-12	0
Lisa Shaw	19484	2022-05-12	0
Zwoagsang Trellinger-März	19485	2022-05-12	0
Café Tacvba	19486	2022-05-12	0
Lynette Schultz	19487	2022-05-12	0
Jimmy Rodgers	19488	2022-05-12	0
custard	19489	2022-05-12	0
Bill Monroe and His Bluegrass Boys	19490	2022-05-12	0
Floyd Tillman	19491	2022-05-12	0
Dave Aude & Tall Paul	19492	2022-05-12	0
David Hines	19493	2022-05-12	0
Petrol	19494	2022-05-12	0
Los Dos Oros	19495	2022-05-12	0
Amen Corner	19496	2022-05-12	0
Alex Lloyd	19497	2022-05-12	0
Bedrock	19498	2022-05-12	0
Phil Wickham	19499	2022-05-12	0
Hausmylly	19500	2022-05-12	0
Maria Friedman	19501	2022-05-12	0
Marc Almond	19502	2022-05-12	0
Maqs	19503	2022-05-12	0
1Giant Leap	19504	2022-05-12	0
Mayumi Kojima	19505	2022-05-12	0
The Creators feat. Mos Def|Talib Kweli	19506	2022-05-12	0
Dead Boys	19507	2022-05-12	0
JOHN DOE	19508	2022-05-12	0
Nico Fidenco	19509	2022-05-12	0
Raintime	19510	2022-05-12	0
Montgomery Gentry	19511	2022-05-12	0
Adversus	19512	2022-05-12	0
Yoko Ono And IMA	19513	2022-05-12	0
Twisted Charm	19514	2022-05-12	0
No Te Va Gustar	19515	2022-05-12	0
Simon Fisher Turner	19516	2022-05-12	0
Mobb Deep featuring Littles & Noyd	19517	2022-05-12	0
Build An Ark	19518	2022-05-12	0
Driller Killer	19519	2022-05-12	0
Con Dolore	19520	2022-05-12	0
Stephen Sondheim	19521	2022-05-12	0
Rubin Steiner	19522	2022-05-12	0
Tina Turner	19523	2022-05-12	0
Jossie Esteban y La Patrulla 15	19524	2022-05-12	0
Cleve Douglass	19525	2022-05-12	0
Celtus	19526	2022-05-12	0
Brigitte Bardot	19527	2022-05-12	0
Mickey Katz	19528	2022-05-12	0
Starshooter	19529	2022-05-12	0
Jorn	19530	2022-05-12	0
Herman Düne	19531	2022-05-12	0
Jimmy Shubert	19532	2022-05-12	0
Ed Calle	19533	2022-05-12	0
HollyThrosby	19534	2022-05-12	0
The Fray	19535	2022-05-12	0
Leonard Rosenman	19536	2022-05-12	0
Poisonblack	19537	2022-05-12	0
Phinius Gage	19538	2022-05-12	0
Mick Harvey	19539	2022-05-12	0
Orquesta Casino De La Playa	19540	2022-05-12	0
Zed Yago	19541	2022-05-12	0
Robert Miles	19542	2022-05-12	0
Sun Ra	19543	2022-05-12	0
Shades	19544	2022-05-12	0
Ali Campbell	19545	2022-05-12	0
Audio Club	19546	2022-05-12	0
Ramon Ayala	19547	2022-05-12	0
Cal Tjader / Mary Stallings	19548	2022-05-12	0
The Jacka And Berner featuring Alcatraz_ Matt Blaque	19549	2022-05-12	0
Charlotte Sometimes	19550	2022-05-12	0
Eric Virgal	19551	2022-05-12	0
Tony Tuff	19552	2022-05-12	0
Super Mal / Luciana	19553	2022-05-12	0
Dance Hall Crashers	19554	2022-05-12	0
EPROM	19555	2022-05-12	0
Tim	19556	2022-05-12	0
The Veils	19557	2022-05-12	0
Justin Nozuka	19558	2022-05-12	0
Feeding Like Butterflies	19559	2022-05-12	0
Blak Twang	19560	2022-05-12	0
Beto Caletti	19561	2022-05-12	0
Hunterz	19562	2022-05-12	0
Total Chaos	19563	2022-05-12	0
Grace Slick & The Great Society	19564	2022-05-12	0
Middle Of The Road	19565	2022-05-12	0
Japancakes	19566	2022-05-12	0
Groupa	19567	2022-05-12	0
Kandi	19568	2022-05-12	0
Joan Sutherland	19569	2022-05-12	0
The Robocop Kraus	19570	2022-05-12	0
Markus Güntner	19571	2022-05-12	0
Hablando en Plata	19572	2022-05-12	0
Guano Apes	19573	2022-05-12	0
Steve Tyrell	19574	2022-05-12	0
Leghau	19575	2022-05-12	0
Townes Van Zandt	19576	2022-05-12	0
The London Theatre Orchestra	19577	2022-05-12	0
DJ Magic	19578	2022-05-12	0
oioai	19579	2022-05-12	0
Kevin Braheny	19580	2022-05-12	0
Los Papines	19581	2022-05-12	0
Seven Foot Wave	19582	2022-05-12	0
Buddy Holly	19583	2022-05-12	0
Arthur Big Boy Crudup	19584	2022-05-12	0
Paul Kantner;Grace Slick	19585	2022-05-12	0
Ron White	19586	2022-05-12	0
Space Cat	19587	2022-05-12	0
Calvertron	19588	2022-05-12	0
Joe ManeriQuartet	19589	2022-05-12	0
Boil	19590	2022-05-12	0
Maracaibo 15	19591	2022-05-12	0
Adultnapper	19592	2022-05-12	0
Love	19593	2022-05-12	0
Filewile	19594	2022-05-12	0
JoAnna James	19595	2022-05-12	0
Virgil Shaw with the Killer Views Band	19596	2022-05-12	0
Payola	19597	2022-05-12	0
Missy Higgins	19598	2022-05-12	0
The Morning Of	19599	2022-05-12	0
Robin Holcomb	19600	2022-05-12	0
Felinos	19601	2022-05-12	0
Crispo	19602	2022-05-12	0
Asia	19603	2022-05-12	0
Banda Bassotti	19604	2022-05-12	0
Figure Four	19605	2022-05-12	0
Sistars	19606	2022-05-12	0
The Beatles	19607	2022-05-12	0
Finley Quaye	19608	2022-05-12	0
Seven	19609	2022-05-12	0
Clarisse Lavanant	19610	2022-05-12	0
The Jacka Feat. J Stylin & Dub 20	19611	2022-05-12	0
Kelly Price	19612	2022-05-12	0
Richard Vission	19613	2022-05-12	0
Emitt Rhodes	19614	2022-05-12	0
John Mayer Trio	19615	2022-05-12	0
I can put my arm back on You can't	19616	2022-05-12	0
Thorinshield	19617	2022-05-12	0
Planlos	19618	2022-05-12	0
Human Eye	19619	2022-05-12	0
Ken Navarro	19620	2022-05-12	0
Michael Klostermann	19621	2022-05-12	0
Shannon Noll	19622	2022-05-12	0
Renee Olstead	19623	2022-05-12	0
Melanie Brown	19624	2022-05-12	0
Raul Porchetto	19625	2022-05-12	0
The Knightsbridge Strings	19626	2022-05-12	0
The Super Friendz	19627	2022-05-12	0
I Hate Sally	19628	2022-05-12	0
Carey Bell	19629	2022-05-12	0
Steve Porter	19630	2022-05-12	0
Black Friday sthlm	19631	2022-05-12	0
Lost & Found	19632	2022-05-12	0
The Damage Manual	19633	2022-05-12	0
Los Secretos	19634	2022-05-12	0
Mike Younger	19635	2022-05-12	0
Crystal Gayle	19636	2022-05-12	0
Jalal El Hamdaoui	19637	2022-05-12	0
Miguel Poveda_ Miguel Poveda	19638	2022-05-12	0
Sebkha-Chott	19639	2022-05-12	0
Michelle Williams	19640	2022-05-12	0
Don't Mess With Texas	19641	2022-05-12	0
Steal Vybe & The Rhythm Slaves	19642	2022-05-12	0
2 Vibes	19643	2022-05-12	0
DJ KAYSLAY featuring Nas_ Baby_ Foxy Brown & Amerie	19644	2022-05-12	0
Karen Matheson	19645	2022-05-12	0
Caliban	19646	2022-05-12	0
Britny Fox	19647	2022-05-12	0
Lisa DeBenedictis	19648	2022-05-12	0
Tiësto feat. Nelly Furtado	19649	2022-05-12	0
Rick Nelson	19650	2022-05-12	0
Lee Ritenour / Dave Grusin	19651	2022-05-12	0
Raul Mezcolanza	19652	2022-05-12	0
16 Volt	19653	2022-05-12	0
Jeannie C Riley	19654	2022-05-12	0
The Sonics	19655	2022-05-12	0
Anam Cara	19656	2022-05-12	0
Jacki O	19657	2022-05-12	0
Malcolm Holcombe	19658	2022-05-12	0
Chico Hamilton / Mark Clive-Lowe	19659	2022-05-12	0
Marcela Morelo	19660	2022-05-12	0
Johannes Heil	19661	2022-05-12	0
Matthew Sweet	19662	2022-05-12	0
Mike Leon Grosch	19663	2022-05-12	0
Grafh	19664	2022-05-12	0
Emil Gilels	19665	2022-05-12	0
Bill Bruford	19666	2022-05-12	0
Manntis	19667	2022-05-12	0
Jay Brannan	19668	2022-05-12	0
Bow Wave	19669	2022-05-12	0
The Quartertones	19670	2022-05-12	0
Laura Mikkola	19671	2022-05-12	0
Speedometer	19672	2022-05-12	0
Matt Pond PA	19673	2022-05-12	0
Quicksand	19674	2022-05-12	0
Narada Michael Walden	19675	2022-05-12	0
Regulator G	19676	2022-05-12	0
Ludov	19677	2022-05-12	0
Richard Muller	19678	2022-05-12	0
Sandro	19679	2022-05-12	0
Albert Cummings	19680	2022-05-12	0
Cornelio Reyna	19681	2022-05-12	0
New Education	19682	2022-05-12	0
Krush	19683	2022-05-12	0
Gustavo Santaolalla's Score Musiciens	19684	2022-05-12	0
Fusebox	19685	2022-05-12	0
Alanis Morissette	19686	2022-05-12	0
Sunlounger	19687	2022-05-12	0
A Fine Frenzy	19688	2022-05-12	0
André Blot	19689	2022-05-12	0
X-Perience & Midge Ure	19690	2022-05-12	0
Chris Eaton	19691	2022-05-12	0
Masquerade	19692	2022-05-12	0
Javier	19693	2022-05-12	0
Something For Kate	19694	2022-05-12	0
Troy Cassar-Daley	19695	2022-05-12	0
Play-N-Skillz	19696	2022-05-12	0
DS-13	19697	2022-05-12	0
Lemonade	19698	2022-05-12	0
Frau Doktor	19699	2022-05-12	0
Mark Wonder	19700	2022-05-12	0
Outlandish	19701	2022-05-12	0
Jim Carroll	19702	2022-05-12	0
The Mermen	19703	2022-05-12	0
Ilija Rudman	19704	2022-05-12	0
Mira Calix	19705	2022-05-12	0
Fates Warning	19706	2022-05-12	0
Tomcraft	19707	2022-05-12	0
The Beat Poets	19708	2022-05-12	0
Slo Burn	19709	2022-05-12	0
Dave Harnetty	19710	2022-05-12	0
Patricia Petitbon	19711	2022-05-12	0
Caballo Dorado	19712	2022-05-12	0
Keely Smith	19713	2022-05-12	0
Mor W.A.	19714	2022-05-12	0
Handsome Furs	19715	2022-05-12	0
Unforscene	19716	2022-05-12	0
Agnetha Fältskog	19717	2022-05-12	0
Silhouette Brown	19718	2022-05-12	0
Cash Mccall	19719	2022-05-12	0
Les Witches	19720	2022-05-12	0
Kenny Neal_ Billy Branch	19721	2022-05-12	0
Dierks Bentley	19722	2022-05-12	0
Dallas Holm	19723	2022-05-12	0
Franky Rizardo	19724	2022-05-12	0
L7	19725	2022-05-12	0
Holiday With Maggie	19726	2022-05-12	0
Haïfa	19727	2022-05-12	0
Kleeer	19728	2022-05-12	0
Carlos Jean	19729	2022-05-12	0
Toy-Box	19730	2022-05-12	0
Righteous Jams	19731	2022-05-12	0
Rocko / Monica	19732	2022-05-12	0
Judge D	19733	2022-05-12	0
Duende	19734	2022-05-12	0
Rodriguez Jr.	19735	2022-05-12	0
More Fire Crew / Knowledge	19736	2022-05-12	0
Mad Heads	19737	2022-05-12	0
Bill Bulinski	19738	2022-05-12	0
The Ike Reilly Assassination	19739	2022-05-12	0
Jo Ann Kelly	19740	2022-05-12	0
Kubatko	19741	2022-05-12	0
Ryan Leslie	19742	2022-05-12	0
Simon & Garfunkel	19743	2022-05-12	0
Pilar Montenegro Feat. Big Mann	19744	2022-05-12	0
Babylon Circus	19745	2022-05-12	0
Kyuss	19746	2022-05-12	0
3-2 Get Funky	19747	2022-05-12	0
Bic Runga;Strawpeople	19748	2022-05-12	0
Eric Alexander / John Hicks / George Mraz / Idris Muhammad	19749	2022-05-12	0
Jana Kirschner	19750	2022-05-12	0
Spice 1 Featuring Yukmouth Of The Luniz & MC Breed	19751	2022-05-12	0
Indicator	19752	2022-05-12	0
Bushido	19753	2022-05-12	0
Index ID	19754	2022-05-12	0
Boat Club	19755	2022-05-12	0
Fever Ray	19756	2022-05-12	0
Orange Juice	19757	2022-05-12	0
Marumari	19758	2022-05-12	0
Tree	19759	2022-05-12	0
Bekay	19760	2022-05-12	0
Dieter Nuhr	19761	2022-05-12	0
David Jalbert	19762	2022-05-12	0
Sammy Kershaw	19763	2022-05-12	0
Ryan Cabrera	19764	2022-05-12	0
Oli Brown	19765	2022-05-12	0
The Spookshow	19766	2022-05-12	0
Charlie Gracie	19767	2022-05-12	0
Pita	19768	2022-05-12	0
6th Sense	19769	2022-05-12	0
Norma Winstone	19770	2022-05-12	0
Dreamdate	19771	2022-05-12	0
Chapterhouse	19772	2022-05-12	0
Ronee Blakley	19773	2022-05-12	0
Grupo Compay Segundo_ Grupo Compay Segundo	19774	2022-05-12	0
Kekele	19775	2022-05-12	0
Jeremy Jordan	19776	2022-05-12	0
Lovehammers	19777	2022-05-12	0
Love Grocer	19778	2022-05-12	0
Bandit	19779	2022-05-12	0
Marc Broussard	19780	2022-05-12	0
Har Mar Superstar	19781	2022-05-12	0
Dave Evans & Thunderstruck	19782	2022-05-12	0
Chocolate Puma	19783	2022-05-12	0
Bruno Pelletier	19784	2022-05-12	0
Alan Parsons	19785	2022-05-12	0
Something Corporate	19786	2022-05-12	0
Udora	19787	2022-05-12	0
Dmitri Shostakovich	19788	2022-05-12	0
Hazell Dean	19789	2022-05-12	0
Ty Tabor	19790	2022-05-12	0
The Buzzcocks	19791	2022-05-12	0
Jeremih	19792	2022-05-12	0
Derniere Volonte	19793	2022-05-12	0
Your Vegas	19794	2022-05-12	0
Tröckener Kecks	19795	2022-05-12	0
Open Door	19796	2022-05-12	0
Trick & Kubic feat. Valeska	19797	2022-05-12	0
Banner Of Thugs	19798	2022-05-12	0
Maurane / Daran	19799	2022-05-12	0
Pamela Williams	19800	2022-05-12	0
Scrunter	19801	2022-05-12	0
Martin Jones	19802	2022-05-12	0
Eivind Aarset	19803	2022-05-12	0
Two Man Advantage	19804	2022-05-12	0
The 1900s	19805	2022-05-12	0
The Tears	19806	2022-05-12	0
Dynarec	19807	2022-05-12	0
The Four Aces	19808	2022-05-12	0
CHRISTOFF	19809	2022-05-12	0
Storyhill	19810	2022-05-12	0
Hollywood_ Mon Amour	19811	2022-05-12	0
Foday Musa Suso	19812	2022-05-12	0
Sting / Edin Karamazov	19813	2022-05-12	0
Big Joe Turner	19814	2022-05-12	0
Kat DeLuna featuring Elephant Man	19815	2022-05-12	0
Accrophone	19816	2022-05-12	0
The Durutti Column	19817	2022-05-12	0
The Nels Cline Singers	19818	2022-05-12	0
B Rich	19819	2022-05-12	0
Ronny Jordan / Dana Bryant	19820	2022-05-12	0
John Barry_ John Debney - Royal Scottish National Orchestra	19821	2022-05-12	0
Heinali	19822	2022-05-12	0
Manuela Kemp	19823	2022-05-12	0
Stanislaw Soyka	19824	2022-05-12	0
VIP featuring Wize of Frontlynaz	19825	2022-05-12	0
L'Aura	19826	2022-05-12	0
The Hassles Feat. Billy Joel	19827	2022-05-12	0
Ewa Bem	19828	2022-05-12	0
Black Sabbath	19829	2022-05-12	0
Sexy sushi	19830	2022-05-12	0
The Prodigy	19831	2022-05-12	0
Jody Miller	19832	2022-05-12	0
The Strangeloves	19833	2022-05-12	0
Eydie Gorme	19834	2022-05-12	0
Sly And The Family Stone	19835	2022-05-12	0
Kenny Rankin	19836	2022-05-12	0
Melchior Productions	19837	2022-05-12	0
Chris Cornell	19838	2022-05-12	0
Marco Antonio Muñiz	19839	2022-05-12	0
Yuppie Flu	19840	2022-05-12	0
RUN-DMC	19841	2022-05-12	0
Grant Hart	19842	2022-05-12	0
Infected Mushroom	19843	2022-05-12	0
Barricada	19844	2022-05-12	0
Mia Doi Todd	19845	2022-05-12	0
Susan Gritton / Carolyn Sampson / Magdalena Kozená / Gabrieli Players / Paul McCreesh	19846	2022-05-12	0
Sol Invictus	19847	2022-05-12	0
Rising Sons	19848	2022-05-12	0
Human Response	19849	2022-05-12	0
Jonah Matranga	19850	2022-05-12	0
JJ Appleton	19851	2022-05-12	0
INXS	19852	2022-05-12	0
The Violet Burning	19853	2022-05-12	0
Damien Leith	19854	2022-05-12	0
Judy Collins	19855	2022-05-12	0
Langhorne Slim_ The War Eagles	19856	2022-05-12	0
The Mighty Mighty Bosstones	19857	2022-05-12	0
Sonny & Cher	19858	2022-05-12	0
Dead Can Dance	19859	2022-05-12	0
Vanessa Da Mata	19860	2022-05-12	0
Black Messiah	19861	2022-05-12	0
Rafael Amor	19862	2022-05-12	0
Alex Machacek	19863	2022-05-12	0
Guns n' Wankers	19864	2022-05-12	0
Chemlab	19865	2022-05-12	0
Olav Basoski Featuring Michie One	19866	2022-05-12	0
Funker Vogt	19867	2022-05-12	0
Claire Elzière	19868	2022-05-12	0
Bill Haley and his Comets	19869	2022-05-12	0
Alexandre Desplat	19870	2022-05-12	0
Counterstrike	19871	2022-05-12	0
Ice T	19872	2022-05-12	0
La venganza de la abuela	19873	2022-05-12	0
Woody Herman And His Orchestra	19874	2022-05-12	0
Ima Robot	19875	2022-05-12	0
Billy Curringham	19876	2022-05-12	0
Guce	19877	2022-05-12	0
Emotional Horizons feat. Stine Grove	19878	2022-05-12	0
Tony Murena	19879	2022-05-12	0
H "two" O Feat. Platnum	19880	2022-05-12	0
Ed Case;HOLLY	19881	2022-05-12	0
Alex Kidd (USA)	19882	2022-05-12	0
4 Toasters	19883	2022-05-12	0
John Lurie	19884	2022-05-12	0
Stratus	19885	2022-05-12	0
Bobby Taylor	19886	2022-05-12	0
Richard Dobson & State Of The Heart	19887	2022-05-12	0
Stars As Eyes	19888	2022-05-12	0
X-ecutioners featuring Rob Zombie_ Slug from Atmosphere and Josey Scott	19889	2022-05-12	0
The Herbaliser	19890	2022-05-12	0
The Jim Jones Revue	19891	2022-05-12	0
Tammy Pescatelli	19892	2022-05-12	0
Ness & cité_ daddy lord C	19893	2022-05-12	0
Nicole Willis	19894	2022-05-12	0
Cars & Trains	19895	2022-05-12	0
Thalia	19896	2022-05-12	0
Celebrate The Nun	19897	2022-05-12	0
Kid Frost	19898	2022-05-12	0
Rebeca Mauleón	19899	2022-05-12	0
Von Südenfed	19900	2022-05-12	0
Marshall Watson	19901	2022-05-12	0
Cheb i Sabbah	19902	2022-05-12	0
Rage Against The Machine	19903	2022-05-12	0
Lord Tanamo with Dr. Ring-Ding & The Senior Allstars	19904	2022-05-12	0
The Whitest Boy Alive	19905	2022-05-12	0
The Franciscan Hobbies	19906	2022-05-12	0
Saturdays And Sundays	19907	2022-05-12	0
Red Aunts	19908	2022-05-12	0
Isabelle Adjani	19909	2022-05-12	0
Pierre-Laurent Aimard	19910	2022-05-12	0
Boban Markovic Orkestar feat. Marko Markovic	19911	2022-05-12	0
Shane Yellowbird	19912	2022-05-12	0
Cazuza	19913	2022-05-12	0
Turbolenz	19914	2022-05-12	0
NOVI FOSILI	19915	2022-05-12	0
Electro deluxe	19916	2022-05-12	0
The 8th Day	19917	2022-05-12	0
Slow Pain	19918	2022-05-12	0
Juan Pardo	19919	2022-05-12	0
Lucky Dube	19920	2022-05-12	0
Gianni Drudi	19921	2022-05-12	0
Pedro Aznar	19922	2022-05-12	0
Robert Hein	19923	2022-05-12	0
Karnivool	19924	2022-05-12	0
Lee "Scratch" Perry	19925	2022-05-12	0
Les Georges Leningrad.	19926	2022-05-12	0
The New Pornographers	19927	2022-05-12	0
Embrace	19928	2022-05-12	0
Incredible Bongo Band	19929	2022-05-12	0
Mick Thomas And The Sure Thing	19930	2022-05-12	0
Augie Meyers	19931	2022-05-12	0
The Sheer	19932	2022-05-12	0
Midway Still	19933	2022-05-12	0
Excuse 17	19934	2022-05-12	0
Aerosmith	19935	2022-05-12	0
Piers Faccini	19936	2022-05-12	0
G Flame & Mr. G	19937	2022-05-12	0
Dessert Sessions	19938	2022-05-12	0
Lyfe Jennings feat. Three 6 Mafia and Project Pat	19939	2022-05-12	0
Agnes	19940	2022-05-12	0
Arid	19941	2022-05-12	0
Mischa Maisky / Daria Hovora	19942	2022-05-12	0
B-Boys	19943	2022-05-12	0
DJ Taucher	19944	2022-05-12	0
Allison Durham Speer	19945	2022-05-12	0
Stephen Duffy / The Lilac Time	19946	2022-05-12	0
Red Lights Flash	19947	2022-05-12	0
Gerry Mulligan Quartet	19948	2022-05-12	0
Formula 3	19949	2022-05-12	0
Rasheeda	19950	2022-05-12	0
Jane Birkin	19951	2022-05-12	0
Mario Venuti	19952	2022-05-12	0
Garnett Silk	19953	2022-05-12	0
Alberto Iglesias	19954	2022-05-12	0
Veda Hille	19955	2022-05-12	0
The Lothian Scottish Dance Band	19956	2022-05-12	0
Benjy Myaz	19957	2022-05-12	0
Dead City Sunday	19958	2022-05-12	0
N'Klabe	19959	2022-05-12	0
Architect	19960	2022-05-12	0
Sick	19961	2022-05-12	0
Ill Nino	19962	2022-05-12	0
Theatres Des Vampires	19963	2022-05-12	0
Gouryella	19964	2022-05-12	0
Rhett Miller	19965	2022-05-12	0
Marcia Ball	19966	2022-05-12	0
Stanley Clarke	19967	2022-05-12	0
King Kurt	19968	2022-05-12	0
Starfield	19969	2022-05-12	0
Strangulated Beatoffs	19970	2022-05-12	0
David S. Ware / Matthew Shipp / William Parker / Guillermo E. Brown	19971	2022-05-12	0
Malajube	19972	2022-05-12	0
Joe Thomas	19973	2022-05-12	0
The Knack	19974	2022-05-12	0
DJ Peril	19975	2022-05-12	0
Buddy Clark	19976	2022-05-12	0
London Symphony Orchestra and Harold Farberman	19977	2022-05-12	0
Winston Reedy	19978	2022-05-12	0
Michel Colombier	19979	2022-05-12	0
Fischer-Z	19980	2022-05-12	0
Mart'nália	19981	2022-05-12	0
Aquatones	19982	2022-05-12	0
Some Girls	19983	2022-05-12	0
Machinedrum	19984	2022-05-12	0
The Dickey Betts Band	19985	2022-05-12	0
Cubismo Grafico	19986	2022-05-12	0
Mil	19987	2022-05-12	0
Erika Jayne	19988	2022-05-12	0
Natalie Gauci	19989	2022-05-12	0
Terminus City	19990	2022-05-12	0
Taxiride	19991	2022-05-12	0
Bob Marley & The Wailers	19992	2022-05-12	0
The Chico Hamilton Quintet With Fred Katz_ Paul Horn_ John Pisano_ Carson Smith	19993	2022-05-12	0
The Kalin Twins	19994	2022-05-12	0
B*Witched	19995	2022-05-12	0
Paul Bley	19996	2022-05-12	0
A Skylit Drive	19997	2022-05-12	0
The Triffids	19998	2022-05-12	0
Toni Fisher	19999	2022-05-12	0
Johanna Zeul	20000	2022-05-12	0
Brett Dennen	20001	2022-05-12	0
Amp Fiddler Feat. Corinne Bailey Rae	20002	2022-05-12	0
Arnaud Le Texier	20003	2022-05-12	0
Nivea	20004	2022-05-12	0
Tina Ann	20005	2022-05-12	0
Lalo Mora	20006	2022-05-12	0
Brian Culbertson	20007	2022-05-12	0
Overkill	20008	2022-05-12	0
Skrew	20009	2022-05-12	0
Stalin vs. Band	20010	2022-05-12	0
Mike Oldfield	20011	2022-05-12	0
No Address	20012	2022-05-12	0
Frank Marino & Mahogany Rush	20013	2022-05-12	0
Libra	20014	2022-05-12	0
Paul Webster	20015	2022-05-12	0
Chris Mills	20016	2022-05-12	0
Psyched To Die	20017	2022-05-12	0
Divlje Jagode	20018	2022-05-12	0
Marcel Azzola	20019	2022-05-12	0
Fergie / Soulja Boy Tell`em	20020	2022-05-12	0
GB Leighton	20021	2022-05-12	0
Babasonicos	20022	2022-05-12	0
The Mutton Birds	20023	2022-05-12	0
Hiroshima	20024	2022-05-12	0
The Tear Garden	20025	2022-05-12	0
Seventh Key	20026	2022-05-12	0
Will.I.Am	20027	2022-05-12	0
Laid In Ashes	20028	2022-05-12	0
Melocos	20029	2022-05-12	0
Qualifide	20030	2022-05-12	0
Paco Osuna	20031	2022-05-12	0
Nick Drake	20032	2022-05-12	0
Horse The Band	20033	2022-05-12	0
Decoy	20034	2022-05-12	0
Lindsey Buckingham	20035	2022-05-12	0
Holly & The Italians	20036	2022-05-12	0
Pitchshifter	20037	2022-05-12	0
Chris Sligh	20038	2022-05-12	0
Nicholas Teo	20039	2022-05-12	0
Gaither Vocal Band	20040	2022-05-12	0
Habib Koité	20041	2022-05-12	0
Parmalee	20042	2022-05-12	0
Oliver Hacke	20043	2022-05-12	0
AN:TI	20044	2022-05-12	0
Adam Ant	20045	2022-05-12	0
Dare and Haste	20046	2022-05-12	0
Dim Mak	20047	2022-05-12	0
Gösta Ekman	20048	2022-05-12	0
Frittenbude	20049	2022-05-12	0
Fantastic Plastic Machine	20050	2022-05-12	0
The Yobs	20051	2022-05-12	0
Nosferatu	20052	2022-05-12	0
Eko Fresh feat. Billy	20053	2022-05-12	0
Lou Reid and Carolina	20054	2022-05-12	0
Lupino Lane	20055	2022-05-12	0
D.Lewis_ Emix	20056	2022-05-12	0
Delivery	20057	2022-05-12	0
I Witness	20058	2022-05-12	0
Umakart	20059	2022-05-12	0
Rufus Thomas	20060	2022-05-12	0
Sinden+Count Of Monte Cristal	20061	2022-05-12	0
Mystikal featuring Silkk The Shocker	20062	2022-05-12	0
Severin feat. Tafuro	20063	2022-05-12	0
The Reaction	20064	2022-05-12	0
Stormy Weather Connection	20065	2022-05-12	0
Mark Lowry	20066	2022-05-12	0
Meredith Monk	20067	2022-05-12	0
David Carroll	20068	2022-05-12	0
Sayag Jazz Machine	20069	2022-05-12	0
Grim Reaper	20070	2022-05-12	0
Sonu Nigam;Sowmya Raoh 	20071	2022-05-12	0
Berlin	20072	2022-05-12	0
Dubee (AKA Sugawolf)	20073	2022-05-12	0
Maggotron Crushing Crew	20074	2022-05-12	0
Soul Ballet	20075	2022-05-12	0
Bill Haley	20076	2022-05-12	0
Mike Lange	20077	2022-05-12	0
David Darling	20078	2022-05-12	0
Jimmy Nelson	20079	2022-05-12	0
Spectrasoul	20080	2022-05-12	0
Vasil Naidenov	20081	2022-05-12	0
Ricki-Lee	20082	2022-05-12	0
Khia	20083	2022-05-12	0
Christmas Island	20084	2022-05-12	0
Mouth Sewn Shut	20085	2022-05-12	0
Ry Cooder	20086	2022-05-12	0
Cultured Pearls	20087	2022-05-12	0
Richard Wagner	20088	2022-05-12	0
Nine Black Alps	20089	2022-05-12	0
Hinge	20090	2022-05-12	0
SOL feat. DJ Rico	20091	2022-05-12	0
Pure Adrenalin	20092	2022-05-12	0
Lauren Talley/Joy Gardner	20093	2022-05-12	0
Kékélé	20094	2022-05-12	0
David Benoit / Russ Freeman	20095	2022-05-12	0
The Mobb	20096	2022-05-12	0
Tea Time_ Big Syke	20097	2022-05-12	0
Mark Alexander Bromwich	20098	2022-05-12	0
Allen Hoist	20099	2022-05-12	0
Dracma	20100	2022-05-12	0
Autopilot	20101	2022-05-12	0
Helena Noguerra	20102	2022-05-12	0
The Tymes	20103	2022-05-12	0
Jimmy Page / Robert Plant	20104	2022-05-12	0
Gregg Karukas	20105	2022-05-12	0
Daniel In The Lion's Den / Carl Douglas	20106	2022-05-12	0
La Billo_ Los Melódicos	20107	2022-05-12	0
Amon Tobin	20108	2022-05-12	0
Edith Marquez	20109	2022-05-12	0
Outhere Brothers	20110	2022-05-12	0
The Grates	20111	2022-05-12	0
DJ Sakin	20112	2022-05-12	0
Classic	20113	2022-05-12	0
London Theatre Orchestra	20114	2022-05-12	0
True Lies	20115	2022-05-12	0
Rocket From The Crypt	20116	2022-05-12	0
Skillet	20117	2022-05-12	0
Stylus Robb	20118	2022-05-12	0
Lemongrass	20119	2022-05-12	0
Alex Party	20120	2022-05-12	0
Maria Isabel	20121	2022-05-12	0
SOL	20122	2022-05-12	0
Pine Leaf Boys	20123	2022-05-12	0
Cyan Velvet Project	20124	2022-05-12	0
Negative FX & Last Rights	20125	2022-05-12	0
The Dils	20126	2022-05-12	0
Spinners	20127	2022-05-12	0
Yumurí y sus Hermanos	20128	2022-05-12	0
Sticky Pistil	20129	2022-05-12	0
The Bill Gaither Trio	20130	2022-05-12	0
Thee Shams	20131	2022-05-12	0
Jon Cleary	20132	2022-05-12	0
Marianne Rosenberg	20133	2022-05-12	0
Phantom	20134	2022-05-12	0
David Phelps	20135	2022-05-12	0
Terminal Function	20136	2022-05-12	0
Paul Young	20137	2022-05-12	0
Celia Cruz & Tito Puente	20138	2022-05-12	0
Heatbeat	20139	2022-05-12	0
Julian Lennon	20140	2022-05-12	0
Little Angels	20141	2022-05-12	0
HYPOCRISY	20142	2022-05-12	0
The Story	20143	2022-05-12	0
B5	20144	2022-05-12	0
GRANDADDY	20145	2022-05-12	0
Cy Young	20146	2022-05-12	0
Fergi	20147	2022-05-12	0
Mulatu Astatqe	20148	2022-05-12	0
Mint	20149	2022-05-12	0
Binocular	20150	2022-05-12	0
Dixie Chicks	20151	2022-05-12	0
World Inferno/Friendship Society_ The	20152	2022-05-12	0
Hilary Stagg	20153	2022-05-12	0
Aladino	20154	2022-05-12	0
Verona	20155	2022-05-12	0
Paco De Lucia / Camaron De La Isla	20156	2022-05-12	0
Lee Wiley	20157	2022-05-12	0
Slot	20158	2022-05-12	0
Digitaline	20159	2022-05-12	0
The Laughing Colors	20160	2022-05-12	0
Thurston Moore	20161	2022-05-12	0
Waajeed	20162	2022-05-12	0
Joy Division	20163	2022-05-12	0
QPE	20164	2022-05-12	0
Jimmie Davis	20165	2022-05-12	0
Slavic Soul Party!	20166	2022-05-12	0
Main Concept	20167	2022-05-12	0
Lovvers	20168	2022-05-12	0
Pete Seeger	20169	2022-05-12	0
Popa Chubby	20170	2022-05-12	0
Loscil	20171	2022-05-12	0
Ronei Jorge e os ladrões de bicicleta	20172	2022-05-12	0
Mahmoud Ahmed	20173	2022-05-12	0
Jo Stafford_ Gordon MacRae	20174	2022-05-12	0
Yngwie Malmsteen's Rising Force	20175	2022-05-12	0
Roy Buchanan	20176	2022-05-12	0
etaoin shrdlu	20177	2022-05-12	0
Ismaël Lô	20178	2022-05-12	0
Michael Johnathon	20179	2022-05-12	0
Nurse With Wound	20180	2022-05-12	0
Günter Noris	20181	2022-05-12	0
Before Dark	20182	2022-05-12	0
DJ Babu	20183	2022-05-12	0
Joe Henderson	20184	2022-05-12	0
Century	20185	2022-05-12	0
Upper Hutt Posse	20186	2022-05-12	0
It's A Beautiful Day	20187	2022-05-12	0
Carrie Underwood	20188	2022-05-12	0
65daysofstatic	20189	2022-05-12	0
Ludivine Sagnier_Jean-marie Wilning_Alice Butaud_Chiara Mastroianni_Brigitte Rouan	20190	2022-05-12	0
Rocco	20191	2022-05-12	0
Phil Cunningham	20192	2022-05-12	0
Kurupt	20193	2022-05-12	0
Happy Clappers	20194	2022-05-12	0
Puff Daddy featuring Kelly Price	20195	2022-05-12	0
Robbie Williams	20196	2022-05-12	0
Flaming Ember	20197	2022-05-12	0
Faultline	20198	2022-05-12	0
Go Hiyama	20199	2022-05-12	0
C-Mon & Kypski feat. Benny Sings	20200	2022-05-12	0
Happy Mondays	20201	2022-05-12	0
Ma Rainey	20202	2022-05-12	0
mcenroe and Birdapres	20203	2022-05-12	0
Jens Lekman	20204	2022-05-12	0
Funky G (Featuring The Gibson Brothers)	20205	2022-05-12	0
Tal Farlow	20206	2022-05-12	0
React	20207	2022-05-12	0
Gallon Drunk	20208	2022-05-12	0
Eason Chan	20209	2022-05-12	0
The Ethiopians	20210	2022-05-12	0
Luke Slater	20211	2022-05-12	0
Jazz Crusaders	20212	2022-05-12	0
Crossroads	20213	2022-05-12	0
Pako and Frederik	20214	2022-05-12	0
Poem Rocket	20215	2022-05-12	0
Ilsa Gold	20216	2022-05-12	0
Anacani	20217	2022-05-12	0
Joey Tempest	20218	2022-05-12	0
Chenoa	20219	2022-05-12	0
Reba McEntire / Vince Gill	20220	2022-05-12	0
Poptart Monkeys	20221	2022-05-12	0
Dark Dark Dark	20222	2022-05-12	0
Glass Tiger	20223	2022-05-12	0
Better Luck Next Time	20224	2022-05-12	0
Mary Margaret O' Hara	20225	2022-05-12	0
Say Hi To Your Mom	20226	2022-05-12	0
Metabass N Breath	20227	2022-05-12	0
Millionaire	20228	2022-05-12	0
Benny Goodman and His Orchestra	20229	2022-05-12	0
Grand Analog	20230	2022-05-12	0
A Split Second	20231	2022-05-12	0
My Own Grave	20232	2022-05-12	0
Benassi Bros. Feat. Violeta	20233	2022-05-12	0
Mad Doctor X	20234	2022-05-12	0
Gerald Veasley	20235	2022-05-12	0
The Unknown Ghosts	20236	2022-05-12	0
The Flaming Stars	20237	2022-05-12	0
Simian	20238	2022-05-12	0
Dan Sartain	20239	2022-05-12	0
Deryl Dodd	20240	2022-05-12	0
Mardi Gras.BB	20241	2022-05-12	0
Cutting Crew	20242	2022-05-12	0
Oxia	20243	2022-05-12	0
The Bobby Fuller Four	20244	2022-05-12	0
Da Hool	20245	2022-05-12	0
Get Back Guinozzi	20246	2022-05-12	0
Andrés Cepeda	20247	2022-05-12	0
The Badlees	20248	2022-05-12	0
Bas Mooy	20249	2022-05-12	0
Gregory Isaacs	20250	2022-05-12	0
Silence 4	20251	2022-05-12	0
People	20252	2022-05-12	0
The Kingsbury Manx	20253	2022-05-12	0
Jaga Jazzist	20254	2022-05-12	0
Keyshia Cole	20255	2022-05-12	0
The Wild Colonial Boys	20256	2022-05-12	0
Bauchklang	20257	2022-05-12	0
Krizz Kaliko	20258	2022-05-12	0
Flax	20259	2022-05-12	0
Blank Dogs	20260	2022-05-12	0
Paik	20261	2022-05-12	0
Walt	20262	2022-05-12	0
Little Willie Anderson	20263	2022-05-12	0
Death Vessel	20264	2022-05-12	0
Anders Johansson	20265	2022-05-12	0
Twista	20266	2022-05-12	0
The Green Pajamas	20267	2022-05-12	0
Hishiryo & Audiopathik	20268	2022-05-12	0
Faruk Sabanci	20269	2022-05-12	0
Wilton Felder	20270	2022-05-12	0
Olodum	20271	2022-05-12	0
Doniki	20272	2022-05-12	0
Azabache	20273	2022-05-12	0
Roey Marquis II. feat. Schivv/ Pyranja/ Tatwaffe	20274	2022-05-12	0
Savas Pascalidis	20275	2022-05-12	0
Ghost Of Tom Joad	20276	2022-05-12	0
Di Grine Kuzine	20277	2022-05-12	0
XII Alfonso	20278	2022-05-12	0
Kenny Dorham	20279	2022-05-12	0
Red Cortez	20280	2022-05-12	0
The Sharks	20281	2022-05-12	0
Cactus World News	20282	2022-05-12	0
José Mercé	20283	2022-05-12	0
Heavy Pettin	20284	2022-05-12	0
The Louvin Brothers	20285	2022-05-12	0
Skapulario	20286	2022-05-12	0
Alan Pride	20287	2022-05-12	0
Sepultura	20288	2022-05-12	0
Clatterbox	20289	2022-05-12	0
Robert Burian	20290	2022-05-12	0
Siglo Xx	20291	2022-05-12	0
K-Rino	20292	2022-05-12	0
Siobhan McCarthy	20293	2022-05-12	0
Disko Punks	20294	2022-05-12	0
Luciana Souza / James Taylor	20295	2022-05-12	0
Stavesacre	20296	2022-05-12	0
BMovieHeroes	20297	2022-05-12	0
The Battle Royale	20298	2022-05-12	0
Jaya	20299	2022-05-12	0
Al Martino	20300	2022-05-12	0
Martyn Bates	20301	2022-05-12	0
Mic Newman	20302	2022-05-12	0
Wintersleep	20303	2022-05-12	0
Oxmo Puccino And The Jazzbastards	20304	2022-05-12	0
Translate	20305	2022-05-12	0
Sam & Dave	20306	2022-05-12	0
Samantha Mumba	20307	2022-05-12	0
Peekaboo	20308	2022-05-12	0
Prince Fatty	20309	2022-05-12	0
Hudba Praha	20310	2022-05-12	0
Amazing Transparent Man	20311	2022-05-12	0
Test Icicles	20312	2022-05-12	0
Pork Dukes	20313	2022-05-12	0
Mick Jagger and Dave Stewart	20314	2022-05-12	0
Johnny Adams	20315	2022-05-12	0
Aqualung	20316	2022-05-12	0
Mas Y Mas	20317	2022-05-12	0
Semisonic	20318	2022-05-12	0
Whole Wheat Bread	20319	2022-05-12	0
Giuni Russo	20320	2022-05-12	0
Culture	20321	2022-05-12	0
Cypress Hill_ King Tee_ Kurupt & Baby's_ Fredwreck	20322	2022-05-12	0
Dananananaykroyd	20323	2022-05-12	0
Tobias Lützenkirchen	20324	2022-05-12	0
Pablo La Rosa	20325	2022-05-12	0
Élodie	20326	2022-05-12	0
Jellyfish	20327	2022-05-12	0
Paula Koivuniemi;Katri Helena;Lea Laven;Marion;Leidit	20328	2022-05-12	0
See You Next Tuesday	20329	2022-05-12	0
Margareth Menezes	20330	2022-05-12	0
Christer Sjögren	20331	2022-05-12	0
Salon Victoria	20332	2022-05-12	0
Astarte	20333	2022-05-12	0
Atze Schröder	20334	2022-05-12	0
Chimène Badi	20335	2022-05-12	0
Hip Hop Pantsula	20336	2022-05-12	0
Camille Jones	20337	2022-05-12	0
Donovan	20338	2022-05-12	0
Terry Stafford	20339	2022-05-12	0
Harry Connick Jr.	20340	2022-05-12	0
De-Grees	20341	2022-05-12	0
Someone Else	20342	2022-05-12	0
Jackson C. Frank	20343	2022-05-12	0
Tha Dogg Pound featuring Busta Rhymes	20344	2022-05-12	0
Gaelic Storm	20345	2022-05-12	0
Seid van Riel	20346	2022-05-12	0
Catherine Feeny	20347	2022-05-12	0
Buck Brothers	20348	2022-05-12	0
Sophie Monk	20349	2022-05-12	0
Leon Lai	20350	2022-05-12	0
Stan Kenton Orchestra	20351	2022-05-12	0
Ferron	20352	2022-05-12	0
Doctors Of Madness	20353	2022-05-12	0
Emilio Tuero	20354	2022-05-12	0
Out Of The Grey	20355	2022-05-12	0
Lars Demian	20356	2022-05-12	0
Angèle Dubeau & La Pietà	20357	2022-05-12	0
Dirty Projectors	20358	2022-05-12	0
Terry Lee Brown Junior	20359	2022-05-12	0
Michael Stearns	20360	2022-05-12	0
Boy George	20361	2022-05-12	0
Miles Davis Sextet	20362	2022-05-12	0
Knut Værnes Band	20363	2022-05-12	0
Füxa	20364	2022-05-12	0
Nicolas Repac	20365	2022-05-12	0
Ark_ Dolibox	20366	2022-05-12	0
Dr Rubberfunk	20367	2022-05-12	0
Woe of Tyrants	20368	2022-05-12	0
Kin Ping Meh	20369	2022-05-12	0
Philadelphia Orchestra/Franz Welser-Möst/Barbara Hendricks	20370	2022-05-12	0
Kankick	20371	2022-05-12	0
Fred Astaire	20372	2022-05-12	0
Silicon Teens	20373	2022-05-12	0
Holly Beth Vincent	20374	2022-05-12	0
DR. ALBAN vs HADDAWAY	20375	2022-05-12	0
The Detroit Cobras	20376	2022-05-12	0
Elmer Gantry's Velvet Opera	20377	2022-05-12	0
La Sonora Del Caribe	20378	2022-05-12	0
Lisa Scott-Lee	20379	2022-05-12	0
EKA	20380	2022-05-12	0
Sy Smith	20381	2022-05-12	0
The 65D Mavericks	20382	2022-05-12	0
Howie B.	20383	2022-05-12	0
Sweet Coffee	20384	2022-05-12	0
Stéphane Picq	20385	2022-05-12	0
Pussycat	20386	2022-05-12	0
Kari Bremnes	20387	2022-05-12	0
The Box Tops	20388	2022-05-12	0
Nato Caliph	20389	2022-05-12	0
Vibesquad	20390	2022-05-12	0
Dinah Shore	20391	2022-05-12	0
3state	20392	2022-05-12	0
Vind Project	20393	2022-05-12	0
Lars Vaular	20394	2022-05-12	0
Lloyd Cole	20395	2022-05-12	0
The RH Factor / Renee Neufville / Karl Denson	20396	2022-05-12	0
Mint Royale	20397	2022-05-12	0
Africando	20398	2022-05-12	0
ILS	20399	2022-05-12	0
Jennifer Hanson	20400	2022-05-12	0
Blowoff	20401	2022-05-12	0
Ridgewalker	20402	2022-05-12	0
Jokke med Tourettes	20403	2022-05-12	0
Tyla Gang	20404	2022-05-12	0
Solomon	20405	2022-05-12	0
Lucero	20406	2022-05-12	0
Mikey General	20407	2022-05-12	0
Golden Triangle	20408	2022-05-12	0
Five Eight	20409	2022-05-12	0
Dissociactive	20410	2022-05-12	0
Sinner Dc	20411	2022-05-12	0
Bruce Kulick	20412	2022-05-12	0
Nocte Obducta	20413	2022-05-12	0
Kyza	20414	2022-05-12	0
Bluelagoon	20415	2022-05-12	0
The Freed Unit	20416	2022-05-12	0
Phyllis Dillon	20417	2022-05-12	0
Maelo Ruiz	20418	2022-05-12	0
Supersister	20419	2022-05-12	0
Flotsam and Jetsam	20420	2022-05-12	0
Enigma	20421	2022-05-12	0
Flunk	20422	2022-05-12	0
Silmarils	20423	2022-05-12	0
John Surman_ Chris Laurence_ Trans4mation	20424	2022-05-12	0
Peter Wright	20425	2022-05-12	0
The Timewriter	20426	2022-05-12	0
Nyarlathotep	20427	2022-05-12	0
Wagon Cookin	20428	2022-05-12	0
Spoon	20429	2022-05-12	0
Waking Ashland	20430	2022-05-12	0
Detroit Junior	20431	2022-05-12	0
Serge Devant feat. Emma Hewitt	20432	2022-05-12	0
The New London Orchestra	20433	2022-05-12	0
Galaxy	20434	2022-05-12	0
If Thousands	20435	2022-05-12	0
Jacka	20436	2022-05-12	0
Warren Zevon	20437	2022-05-12	0
Joey Negro	20438	2022-05-12	0
2K	20439	2022-05-12	0
Pop Levi	20440	2022-05-12	0
Jody Grind	20441	2022-05-12	0
Lorez Alexandria	20442	2022-05-12	0
Clarence "Frogman" Henry	20443	2022-05-12	0
Inon Zur	20444	2022-05-12	0
Kaze	20445	2022-05-12	0
The Soulful Strings	20446	2022-05-12	0
Aava	20447	2022-05-12	0
Republic	20448	2022-05-12	0
Peggy Lee	20449	2022-05-12	0
Lady & Bird	20450	2022-05-12	0
Chris Bell	20451	2022-05-12	0
EMF	20452	2022-05-12	0
Criteria	20453	2022-05-12	0
Wu-Tang Clan	20454	2022-05-12	0
Wallis Bird	20455	2022-05-12	0
Bracket	20456	2022-05-12	0
Thelma Houston	20457	2022-05-12	0
Dirty Sanchez	20458	2022-05-12	0
Solarstone Ft. Elizabeth Fields	20459	2022-05-12	0
Inti-Illimani	20460	2022-05-12	0
Laurent Wolf	20461	2022-05-12	0
Keletigui et ses Tambourinis	20462	2022-05-12	0
Juha Tapio	20463	2022-05-12	0
Broken Social Scene	20464	2022-05-12	0
Cake Or Death	20465	2022-05-12	0
White Noise	20466	2022-05-12	0
Joseph Fire Crow	20467	2022-05-12	0
Rick Derringer	20468	2022-05-12	0
Three Friends	20469	2022-05-12	0
Infantjoy	20470	2022-05-12	0
Twisted System	20471	2022-05-12	0
Love Is All	20472	2022-05-12	0
The Bloodthirsty Lovers	20473	2022-05-12	0
Smurf	20474	2022-05-12	0
John Askew	20475	2022-05-12	0
Rupa & the April Fishes	20476	2022-05-12	0
Andraé Crouch & Solid Gospel	20477	2022-05-12	0
Ratos de Porao	20478	2022-05-12	0
Kingston Falls	20479	2022-05-12	0
Philadelphia International All-Stars	20480	2022-05-12	0
Lenny Bruce	20481	2022-05-12	0
M. Walking On The Water with Nikki Sudden & The Jazz Butcher	20482	2022-05-12	0
Hot Hot Heat	20483	2022-05-12	0
Arthur Fiedler	20484	2022-05-12	0
Daryl Hall And John Oates	20485	2022-05-12	0
Ka-Sol	20486	2022-05-12	0
Paul Van Dyk	20487	2022-05-12	0
Left Side Brain	20488	2022-05-12	0
The Bevis Frond	20489	2022-05-12	0
Dear Reader	20490	2022-05-12	0
Stryder	20491	2022-05-12	0
Majesty	20492	2022-05-12	0
L'Orchestre Lullabye	20493	2022-05-12	0
Grand Agent	20494	2022-05-12	0
Ginger Baker Trio	20495	2022-05-12	0
Gis(m)	20496	2022-05-12	0
The Neville Brothers	20497	2022-05-12	0
Ice Cube Featuring Chuck D	20498	2022-05-12	0
Bob Wills & His Texas Playboys / Billy Jack Wills	20499	2022-05-12	0
Pe'z	20500	2022-05-12	0
Hadise	20501	2022-05-12	0
Bossa For Babies	20502	2022-05-12	0
Die Apokalyptischen Reiter	20503	2022-05-12	0
Boston Spaceships	20504	2022-05-12	0
Stephen Dale Petit	20505	2022-05-12	0
Rocca	20506	2022-05-12	0
Assembly of Dust	20507	2022-05-12	0
Mr Brown	20508	2022-05-12	0
Treva Whateva	20509	2022-05-12	0
Frank Leicher	20510	2022-05-12	0
DNA	20511	2022-05-12	0
Miriam Yeung_ Miriam Yeung	20512	2022-05-12	0
Liquid Spill	20513	2022-05-12	0
Khaled	20514	2022-05-12	0
Alex Gaudino_ Vs Nari & Milani Featuring Carl	20515	2022-05-12	0
The Derek Trucks Band	20516	2022-05-12	0
Foremost Poets	20517	2022-05-12	0
P Money ft. OG'z_ Drifter & Lady Leeshur	20518	2022-05-12	0
Cake On Cake	20519	2022-05-12	0
Trashcan Joe	20520	2022-05-12	0
Love Spit Love	20521	2022-05-12	0
Steve Green	20522	2022-05-12	0
101	20523	2022-05-12	0
Riff Raff	20524	2022-05-12	0
In Flames	20525	2022-05-12	0
After Dark	20526	2022-05-12	0
Hammer No More the Fingers	20527	2022-05-12	0
The Roots	20528	2022-05-12	0
Swans Of Avon	20529	2022-05-12	0
Daweh Congo	20530	2022-05-12	0
Celia Cruz	20531	2022-05-12	0
Emeralds	20532	2022-05-12	0
Samuel Spence	20533	2022-05-12	0
Léna	20534	2022-05-12	0
Lucie Silvas	20535	2022-05-12	0
Plushgun	20536	2022-05-12	0
Inland Knights	20537	2022-05-12	0
Joann Rosario	20538	2022-05-12	0
Christian Death	20539	2022-05-12	0
Jim Reeves	20540	2022-05-12	0
Everyday Sunday	20541	2022-05-12	0
Pretty Boy Crossover	20542	2022-05-12	0
Shadowy Men on a Shadowy Planet	20543	2022-05-12	0
Easy Star All-Stars Featuring Patrick Junior	20544	2022-05-12	0
Akon / Wyclef Jean	20545	2022-05-12	0
Jo Stafford	20546	2022-05-12	0
Lyricson	20547	2022-05-12	0
Saves The Day	20548	2022-05-12	0
Chaka Demus & Pliers	20549	2022-05-12	0
P.K.14	20550	2022-05-12	0
60 Watt Kid	20551	2022-05-12	0
Carmen Cavallaro	20552	2022-05-12	0
Rhinoceros	20553	2022-05-12	0
Vapnet	20554	2022-05-12	0
Geir Rønning	20555	2022-05-12	0
Joao Gilberto	20556	2022-05-12	0
La Decada Prodigiosa	20557	2022-05-12	0
Taino	20558	2022-05-12	0
Vital Elements	20559	2022-05-12	0
Poor Genetic Material	20560	2022-05-12	0
Frankie HI-NRG MC	20561	2022-05-12	0
Mekka	20562	2022-05-12	0
Thesubletter	20563	2022-05-12	0
Shaggy / Nicole Scherzinger	20564	2022-05-12	0
Uton	20565	2022-05-12	0
I.N.T	20566	2022-05-12	0
Spheric Universe Experience	20567	2022-05-12	0
Jesse James	20568	2022-05-12	0
Scott Glasgow	20569	2022-05-12	0
Clifford T Ward	20570	2022-05-12	0
No Name	20571	2022-05-12	0
Floyd Taylor	20572	2022-05-12	0
Mergel Kratzer	20573	2022-05-12	0
HUM	20574	2022-05-12	0
Misha Alperin	20575	2022-05-12	0
Jeff Scott Soto	20576	2022-05-12	0
La Bouche	20577	2022-05-12	0
Lara & Reyes	20578	2022-05-12	0
Sleepy John Estes	20579	2022-05-12	0
Royal Philharmonic Orchestra/Yehudi Menuhin	20580	2022-05-12	0
Red Fox Grey Fox	20581	2022-05-12	0
Cole Marquis	20582	2022-05-12	0
T-99	20583	2022-05-12	0
Shotgun Honeymoon	20584	2022-05-12	0
Marcel	20585	2022-05-12	0
Megan McCauley	20586	2022-05-12	0
The Rosie Taylor Project	20587	2022-05-12	0
D.A.P.	20588	2022-05-12	0
DC Talk Vs. Newsboys	20589	2022-05-12	0
Lee Osborne	20590	2022-05-12	0
Kissey Asplund	20591	2022-05-12	0
Angélique Kidjo - Peter Gabriel	20592	2022-05-12	0
Ice upon fire	20593	2022-05-12	0
City High	20594	2022-05-12	0
Pirats Sound Sistema	20595	2022-05-12	0
Stonebridge & Wawa	20596	2022-05-12	0
Geo Bilongo	20597	2022-05-12	0
Lutricia Mcneal	20598	2022-05-12	0
Carlos Nuñez	20599	2022-05-12	0
Derek Trucks;Solomon Burke	20600	2022-05-12	0
Low	20601	2022-05-12	0
Walt Solek	20602	2022-05-12	0
Gallows	20603	2022-05-12	0
Karaoke (Made famous by J-Kwon)	20604	2022-05-12	0
The Bee Gees	20605	2022-05-12	0
Robi Zonca	20606	2022-05-12	0
Displacer	20607	2022-05-12	0
Buckethead	20608	2022-05-12	0
King Midas Sound	20609	2022-05-12	0
Desmond Dekker / The Cherry Pies	20610	2022-05-12	0
Oi Va Voi	20611	2022-05-12	0
Gravity Kills	20612	2022-05-12	0
Brilliant Red Lights	20613	2022-05-12	0
Heaven Street Seven	20614	2022-05-12	0
Trash Talk	20615	2022-05-12	0
Link 80	20616	2022-05-12	0
Bill Whelan	20617	2022-05-12	0
Cool For August	20618	2022-05-12	0
Johnny Hickman	20619	2022-05-12	0
Choo choo	20620	2022-05-12	0
Value Pac	20621	2022-05-12	0
Retching Red	20622	2022-05-12	0
Betty Everett	20623	2022-05-12	0
Alphaville	20624	2022-05-12	0
Levert	20625	2022-05-12	0
Brian Keane	20626	2022-05-12	0
Guy Sebastian	20627	2022-05-12	0
Stephen Varcoe	20628	2022-05-12	0
Justin Timberlake	20629	2022-05-12	0
Bebe And Cece Winans Featuring MC Hammer	20630	2022-05-12	0
Dare	20631	2022-05-12	0
Less Than Jake	20632	2022-05-12	0
Bajja Jedd	20633	2022-05-12	0
Crash Kelly	20634	2022-05-12	0
Beans On Toast	20635	2022-05-12	0
Travoltas	20636	2022-05-12	0
Danny Williams	20637	2022-05-12	0
Les Misérables - 10th Anniversary Concert	20638	2022-05-12	0
Manes	20639	2022-05-12	0
Cruciform Injection	20640	2022-05-12	0
Manuel Imán	20641	2022-05-12	0
Chris Connelly and the Bells	20642	2022-05-12	0
Pia Fraus	20643	2022-05-12	0
Mary Roos	20644	2022-05-12	0
The Four Tops	20645	2022-05-12	0
Eddy Senay	20646	2022-05-12	0
Genki Rockets	20647	2022-05-12	0
Chairlift	20648	2022-05-12	0
John Kirkpatrick	20649	2022-05-12	0
Eddy Herrera	20650	2022-05-12	0
Villa Nah	20651	2022-05-12	0
Bloodpit	20652	2022-05-12	0
White Plains	20653	2022-05-12	0
The Living End	20654	2022-05-12	0
Crash Parallel	20655	2022-05-12	0
A.C.T	20656	2022-05-12	0
Sozonov	20657	2022-05-12	0
Jose Roberto Bertrami	20658	2022-05-12	0
Charlie Parker	20659	2022-05-12	0
Ray Campi	20660	2022-05-12	0
Annette Hanshaw	20661	2022-05-12	0
Southern Gentlemen	20662	2022-05-12	0
Goldrush	20663	2022-05-12	0
Burnt Friedman	20664	2022-05-12	0
La Cabra Mecanica	20665	2022-05-12	0
Rick Wakeman And Dave Cousins	20666	2022-05-12	0
Molotov	20667	2022-05-12	0
Coparck	20668	2022-05-12	0
Circus Devils	20669	2022-05-12	0
Yung Berg feat. Rockstar	20670	2022-05-12	0
Stilettos	20671	2022-05-12	0
The Flamingos	20672	2022-05-12	0
20 Minute Loop	20673	2022-05-12	0
The Chantays	20674	2022-05-12	0
Skeewiff	20675	2022-05-12	0
MFG	20676	2022-05-12	0
Adriana Calcanhotto	20677	2022-05-12	0
Sunspot Jonz	20678	2022-05-12	0
Larry Vuckovich	20679	2022-05-12	0
Kary Ng	20680	2022-05-12	0
CiM	20681	2022-05-12	0
Stuck Mojo	20682	2022-05-12	0
Cheryl Melody	20683	2022-05-12	0
LANDA DANIEL	20684	2022-05-12	0
Kenny Rogers & The First Edition	20685	2022-05-12	0
Oscar	20686	2022-05-12	0
Heavenly States	20687	2022-05-12	0
Juliet	20688	2022-05-12	0
Mojado	20689	2022-05-12	0
Thinking Plague	20690	2022-05-12	0
Richard Ashcroft	20691	2022-05-12	0
The Rhythm Masters	20692	2022-05-12	0
Mavis Staples	20693	2022-05-12	0
Congorock	20694	2022-05-12	0
Kim Fox	20695	2022-05-12	0
Mac McAnally	20696	2022-05-12	0
Shane	20697	2022-05-12	0
Jeannie C. Riley	20698	2022-05-12	0
Thrust	20699	2022-05-12	0
Elephant Beach	20700	2022-05-12	0
Kris Menace	20701	2022-05-12	0
Young Gunz / 112	20702	2022-05-12	0
Skaburbian Collective	20703	2022-05-12	0
Christina Lindberg	20704	2022-05-12	0
Ken Ishii and Anderson Noise	20705	2022-05-12	0
THE JIVE ACES	20706	2022-05-12	0
Tying Tiffany	20707	2022-05-12	0
Rie Tomosaka	20708	2022-05-12	0
Cause Co-Motion!	20709	2022-05-12	0
Dennis Jernigan	20710	2022-05-12	0
Glory & Shame	20711	2022-05-12	0
Natalino Otto	20712	2022-05-12	0
Traumpiloten	20713	2022-05-12	0
The Bubble Puppy	20714	2022-05-12	0
Paul Williams	20715	2022-05-12	0
Gigliola Cinquetti	20716	2022-05-12	0
M Sane	20717	2022-05-12	0
Fentura	20718	2022-05-12	0
Screeching Weasel	20719	2022-05-12	0
Commander Tom	20720	2022-05-12	0
Art of War & Sin	20721	2022-05-12	0
John Cage/ Margaret Leng Tan/ Joan La Barbara	20722	2022-05-12	0
Headstrong	20723	2022-05-12	0
Jerry Lee Lewis	20724	2022-05-12	0
Lilienthal	20725	2022-05-12	0
Chris Garneau	20726	2022-05-12	0
Berri Txarrak	20727	2022-05-12	0
Louisiana Red	20728	2022-05-12	0
Bill Nelson's Red Noise	20729	2022-05-12	0
Greater Vision	20730	2022-05-12	0
Cappella	20731	2022-05-12	0
Baker Brothers	20732	2022-05-12	0
Chaka Demus	20733	2022-05-12	0
Brian McKnight	20734	2022-05-12	0
Avenged Sevenfold	20735	2022-05-12	0
Lyle Lovett / Lyle Lovett	20736	2022-05-12	0
Barcode Brothers	20737	2022-05-12	0
Supafly Inc.	20738	2022-05-12	0
Otis Taylor	20739	2022-05-12	0
De Rosa	20740	2022-05-12	0
Felt	20741	2022-05-12	0
Multiphonic Ensemble	20742	2022-05-12	0
Syndicate Of Law	20743	2022-05-12	0
Sarah Brightman	20744	2022-05-12	0
Frank Frost	20745	2022-05-12	0
Poi Dog Pondering	20746	2022-05-12	0
Sandy Mouche	20747	2022-05-12	0
The Studio Sound Ensemble	20748	2022-05-12	0
Fair To Midland	20749	2022-05-12	0
Laith Al-Deen	20750	2022-05-12	0
Talib Kweli / Hi-Tek / Vinia Mojica	20751	2022-05-12	0
Mary Johnson	20752	2022-05-12	0
Chatham County Line	20753	2022-05-12	0
Spetsnaz	20754	2022-05-12	0
Carole King / James Taylor	20755	2022-05-12	0
Kroke	20756	2022-05-12	0
Arlo Guthrie	20757	2022-05-12	0
Billie Piper	20758	2022-05-12	0
Mötley Crüe	20759	2022-05-12	0
Suffocation	20760	2022-05-12	0
Kurt Nilsen	20761	2022-05-12	0
Gabriela Anders	20762	2022-05-12	0
Tangerine Dream	20763	2022-05-12	0
The Charlatans	20764	2022-05-12	0
Beseech	20765	2022-05-12	0
Natale Galletta	20766	2022-05-12	0
Bumble Bee Slim	20767	2022-05-12	0
Fun Boy Three	20768	2022-05-12	0
DJ SD	20769	2022-05-12	0
Royce Da 5'9	20770	2022-05-12	0
The Fireballs	20771	2022-05-12	0
Viki Mosholiou	20772	2022-05-12	0
Gazzara	20773	2022-05-12	0
Guce & Matt Blaque	20774	2022-05-12	0
Ian McCulloch	20775	2022-05-12	0
Tone Damli Aaberge	20776	2022-05-12	0
Dave Edmunds	20777	2022-05-12	0
Dottie West	20778	2022-05-12	0
Los Peyotes	20779	2022-05-12	0
Hallo Venray	20780	2022-05-12	0
The Coal Porters	20781	2022-05-12	0
Moving Targets	20782	2022-05-12	0
Otello Profazio	20783	2022-05-12	0
Malfunkshun	20784	2022-05-12	0
Descendents	20785	2022-05-12	0
Throw Rag	20786	2022-05-12	0
Jody Watley	20787	2022-05-12	0
Madrid De Los Austrias	20788	2022-05-12	0
I Cugini Di Campagna	20789	2022-05-12	0
AUDIO.3	20790	2022-05-12	0
Ulla Meinecke	20791	2022-05-12	0
She Satellites	20792	2022-05-12	0
30Y	20793	2022-05-12	0
Crimson Curse	20794	2022-05-12	0
Leigh Nash	20795	2022-05-12	0
Bissen feat. Victoria Jane	20796	2022-05-12	0
Hellbillies	20797	2022-05-12	0
Pinchers	20798	2022-05-12	0
Stanislaw Soyka/Janusz Iwanski "yanina	20799	2022-05-12	0
Zolar X	20800	2022-05-12	0
Porter Wagoner	20801	2022-05-12	0
Chukki Star	20802	2022-05-12	0
Audio	20803	2022-05-12	0
Sascha Barth	20804	2022-05-12	0
Way Out West	20805	2022-05-12	0
Steel Porn Rhino	20806	2022-05-12	0
Kill Switch...Klick	20807	2022-05-12	0
Nancy Sinatra	20808	2022-05-12	0
Tragic Black	20809	2022-05-12	0
Ours	20810	2022-05-12	0
Tavares	20811	2022-05-12	0
Darren Hayes	20812	2022-05-12	0
Daft Punk	20813	2022-05-12	0
Vick Allen	20814	2022-05-12	0
Sanford Clark	20815	2022-05-12	0
Crime Mob	20816	2022-05-12	0
Adelaide Hall (Spotlight On The Stars)	20817	2022-05-12	0
JET	20818	2022-05-12	0
Memphis Minnie	20819	2022-05-12	0
Essendon Airport	20820	2022-05-12	0
Jeanne Balibar	20821	2022-05-12	0
Alex	20822	2022-05-12	0
Gabin featuring China Moses	20823	2022-05-12	0
Fabrizio De Andrè	20824	2022-05-12	0
New Edition	20825	2022-05-12	0
Black Heat	20826	2022-05-12	0
Horkyze Slyze	20827	2022-05-12	0
Cornelius Brothers & Sister Rose	20828	2022-05-12	0
Miguel Reyes	20829	2022-05-12	0
Black Magic	20830	2022-05-12	0
Joey Beltram	20831	2022-05-12	0
Iz And Diz	20832	2022-05-12	0
The Temper Trap	20833	2022-05-12	0
The Smittens	20834	2022-05-12	0
Guadalupe Pineda	20835	2022-05-12	0
Tommy Steele and the Steelmen	20836	2022-05-12	0
Brad Fiedel	20837	2022-05-12	0
Anggun	20838	2022-05-12	0
Clelia Felix	20839	2022-05-12	0
Melissa Manchester	20840	2022-05-12	0
Don & The Goodtimes	20841	2022-05-12	0
Eddie Money	20842	2022-05-12	0
James Harcourt	20843	2022-05-12	0
Joan Manuel Serrat	20844	2022-05-12	0
Naked Raygun	20845	2022-05-12	0
KB	20846	2022-05-12	0
Idle Sons	20847	2022-05-12	0
Loudon Wainwright III	20848	2022-05-12	0
Jin	20849	2022-05-12	0
Living In A Box	20850	2022-05-12	0
Magenta	20851	2022-05-12	0
Onur Özer	20852	2022-05-12	0
Ashlee Simpson	20853	2022-05-12	0
Freddie Mcgregor & Snagga Puss	20854	2022-05-12	0
Lester Young	20855	2022-05-12	0
Kenny G with Babyface	20856	2022-05-12	0
András Schiff	20857	2022-05-12	0
Jeff London	20858	2022-05-12	0
Kool Savas & Azad	20859	2022-05-12	0
The Peärls Before Swïne Experience	20860	2022-05-12	0
Anatomy Of A Ghost	20861	2022-05-12	0
Discount	20862	2022-05-12	0
Goose Creek Symphony	20863	2022-05-12	0
Washboard Sam	20864	2022-05-12	0
Colwell-Winfield Blues Band	20865	2022-05-12	0
CLOCK	20866	2022-05-12	0
Chakachas	20867	2022-05-12	0
Frayser Boy	20868	2022-05-12	0
Trio Elétrico	20869	2022-05-12	0
Mistah F.A.B ft. Kato and Yukmouth	20870	2022-05-12	0
Rami Kleinstein	20871	2022-05-12	0
Tony Williams	20872	2022-05-12	0
Sarah McLachlan	20873	2022-05-12	0
Manuel Lombo	20874	2022-05-12	0
Johnny Ventura	20875	2022-05-12	0
Threads	20876	2022-05-12	0
Frank Black	20877	2022-05-12	0
Knut Anders Sørum	20878	2022-05-12	0
H16	20879	2022-05-12	0
Perspects	20880	2022-05-12	0
T-Pain	20881	2022-05-12	0
Monty Montgomery	20882	2022-05-12	0
K-1	20883	2022-05-12	0
Psychic Ills	20884	2022-05-12	0
Hävy RoxX	20885	2022-05-12	0
Marvin Sapp	20886	2022-05-12	0
Charly Lownoise & Mental Theo	20887	2022-05-12	0
Don Carlos & Gold	20888	2022-05-12	0
Kyle Eastwood	20889	2022-05-12	0
Kamaha	20890	2022-05-12	0
TIMO TOLKKI	20891	2022-05-12	0
Paquito D'Rivera	20892	2022-05-12	0
Paula Santoro & Hugh Burns	20893	2022-05-12	0
Al DiMeola	20894	2022-05-12	0
Rebekka Bakken	20895	2022-05-12	0
Sam Champion	20896	2022-05-12	0
Yanou feat. Mark Daviz	20897	2022-05-12	0
Vanusa	20898	2022-05-12	0
Helen Forrest	20899	2022-05-12	0
Primitive Radio Gods	20900	2022-05-12	0
Scud	20901	2022-05-12	0
Baby Bash featuring Keith Sweat	20902	2022-05-12	0
T. Texas Tyler	20903	2022-05-12	0
The Almanac Singers	20904	2022-05-12	0
Kamera 2	20905	2022-05-12	0
Dance Nation	20906	2022-05-12	0
Barry White and His Orchestra	20907	2022-05-12	0
F.S. Blumm	20908	2022-05-12	0
Langston Hughes	20909	2022-05-12	0
KRIS KRISTOFFERSON & RITA COOLIDGE	20910	2022-05-12	0
Teenage Head	20911	2022-05-12	0
Wiz Khalifa	20912	2022-05-12	0
Banda El Limon	20913	2022-05-12	0
John Huling	20914	2022-05-12	0
Un Kuartito	20915	2022-05-12	0
DJ Nasty	20916	2022-05-12	0
Atomship	20917	2022-05-12	0
Fennesz + Sakamoto	20918	2022-05-12	0
Diana King	20919	2022-05-12	0
Soulive / Cochema Gastelum	20920	2022-05-12	0
Few Left Standing	20921	2022-05-12	0
Loop Guru	20922	2022-05-12	0
Stonewall Jackson	20923	2022-05-12	0
David Frizzell	20924	2022-05-12	0
Kris Kross	20925	2022-05-12	0
Larry Stephenson	20926	2022-05-12	0
Darren Styles	20927	2022-05-12	0
Rachael Calladine	20928	2022-05-12	0
Korn	20929	2022-05-12	0
DJ Tatana featuring Jael	20930	2022-05-12	0
MC Leozinho	20931	2022-05-12	0
The Fathoms	20932	2022-05-12	0
Jan Burian	20933	2022-05-12	0
Claus Eisenmann	20934	2022-05-12	0
House Of Heroes	20935	2022-05-12	0
The Paco De Lucia Sextet	20936	2022-05-12	0
Appliance	20937	2022-05-12	0
SNFU	20938	2022-05-12	0
Hothouse Flowers	20939	2022-05-12	0
Black Debbath	20940	2022-05-12	0
System and Station	20941	2022-05-12	0
The Rippingtons / Eric Marienthal	20942	2022-05-12	0
MANDRAGORA SCREAM	20943	2022-05-12	0
Forty Winks	20944	2022-05-12	0
Béla Fleck	20945	2022-05-12	0
Zombie Nation	20946	2022-05-12	0
The Jack Stafford Foundation	20947	2022-05-12	0
Iain MacInnes	20948	2022-05-12	0
DJ Fait	20949	2022-05-12	0
Jeff Wayne	20950	2022-05-12	0
Clan Of Xymox	20951	2022-05-12	0
Söhne Mannheims	20952	2022-05-12	0
Dirty Pretty Things	20953	2022-05-12	0
The Mules	20954	2022-05-12	0
Aníbal Troilo	20955	2022-05-12	0
Dimentia 13	20956	2022-05-12	0
Kanye West / Mos Def	20957	2022-05-12	0
Cut Chemist	20958	2022-05-12	0
Lubeck Festival Choir And Orchestra	20959	2022-05-12	0
Bun B + M2	20960	2022-05-12	0
Moss	20961	2022-05-12	0
H.e.a.t	20962	2022-05-12	0
California Sunshine	20963	2022-05-12	0
Miley Cyrus	20964	2022-05-12	0
The Impressions	20965	2022-05-12	0
Radian	20966	2022-05-12	0
Juaninacka	20967	2022-05-12	0
Foxx	20968	2022-05-12	0
Ado & Montorsi	20969	2022-05-12	0
End Of You	20970	2022-05-12	0
Pawn and Sonic D	20971	2022-05-12	0
Nicòn	20972	2022-05-12	0
Proof	20973	2022-05-12	0
Nelson Ned	20974	2022-05-12	0
The Concretes	20975	2022-05-12	0
Borislav Mitic	20976	2022-05-12	0
Olympus Mons	20977	2022-05-12	0
Jackie Gleason	20978	2022-05-12	0
Uno Svenningsson	20979	2022-05-12	0
Sybreed	20980	2022-05-12	0
Janis Martin	20981	2022-05-12	0
April Wine	20982	2022-05-12	0
HAMMERFALL	20983	2022-05-12	0
MIKE KENEALLY & BEER 4 DOLPHINS	20984	2022-05-12	0
Charles Bernstein	20985	2022-05-12	0
Fito Paez	20986	2022-05-12	0
The Shamrock Singers	20987	2022-05-12	0
Gordon Chambers	20988	2022-05-12	0
Oren Ambarchi	20989	2022-05-12	0
El Dorados	20990	2022-05-12	0
Ten Falls Forth	20991	2022-05-12	0
Wykked Wytch	20992	2022-05-12	0
Recover	20993	2022-05-12	0
Trevor Loveys & Affie Yusuf feat. Spoek	20994	2022-05-12	0
Pugslee Atomz	20995	2022-05-12	0
Steady Mobb'n	20996	2022-05-12	0
Hind	20997	2022-05-12	0
Daniel Denis	20998	2022-05-12	0
Neal Casal	20999	2022-05-12	0
Blacklisted	21000	2022-05-12	0
Ohgr	21001	2022-05-12	0
Roger Fritz and Bob Hume	21002	2022-05-12	0
ATFC featuring Yasmeen	21003	2022-05-12	0
The Bastard Sons Of Dioniso	21004	2022-05-12	0
Klymaxx	21005	2022-05-12	0
West_ Bruce & Laing	21006	2022-05-12	0
Sad Lovers & Giants	21007	2022-05-12	0
Wigwam	21008	2022-05-12	0
The Generationals	21009	2022-05-12	0
Mass Hysteria	21010	2022-05-12	0
Judit Pixner Quartett	21011	2022-05-12	0
Concrete Dj'z	21012	2022-05-12	0
Speedball Baby	21013	2022-05-12	0
Fitta Warri	21014	2022-05-12	0
Raging Speedhorn	21015	2022-05-12	0
Damien Dempsey	21016	2022-05-12	0
Jon B.	21017	2022-05-12	0
Bowser	21018	2022-05-12	0
Marian McPartland / Mary Lou Williams	21019	2022-05-12	0
Random Noise Generation	21020	2022-05-12	0
Stoa	21021	2022-05-12	0
Warrior Soul	21022	2022-05-12	0
Popnebo & dadaBLEEP	21023	2022-05-12	0
Thomas Bangalter	21024	2022-05-12	0
J.D. NATASHA	21025	2022-05-12	0
Freedy Johnston	21026	2022-05-12	0
Mr Scruff	21027	2022-05-12	0
Ray Scott	21028	2022-05-12	0
The Pilgrim Travelers	21029	2022-05-12	0
Blues Brother Castro	21030	2022-05-12	0
Dear Whoever	21031	2022-05-12	0
Dino	21032	2022-05-12	0
Chip Taylor	21033	2022-05-12	0
Mary Karlzen	21034	2022-05-12	0
Dylan In The Movies	21035	2022-05-12	0
M-Phazes	21036	2022-05-12	0
For The Worse	21037	2022-05-12	0
Erlend Øye	21038	2022-05-12	0
Mrs. Sarah Makem	21039	2022-05-12	0
Hil St Soul	21040	2022-05-12	0
La Mosca Tse-Tse	21041	2022-05-12	0
Eskju Divine	21042	2022-05-12	0
The Del McCoury Band	21043	2022-05-12	0
Busta Rhymes feat. Spliff Star	21044	2022-05-12	0
Tony Joe White	21045	2022-05-12	0
Wagon Christ	21046	2022-05-12	0
Freekbass	21047	2022-05-12	0
Stefan Tretau	21048	2022-05-12	0
Terry Winchell	21049	2022-05-12	0
The Butterfly Effect	21050	2022-05-12	0
Lord Melody	21051	2022-05-12	0
Senore Matze Rossi	21052	2022-05-12	0
Poverty's no Crime	21053	2022-05-12	0
Too Strong	21054	2022-05-12	0
Archie Roach	21055	2022-05-12	0
Circle Jerks	21056	2022-05-12	0
Boots Randolph	21057	2022-05-12	0
Down To The Bone	21058	2022-05-12	0
Marco Ferradini	21059	2022-05-12	0
Ke$ha	21060	2022-05-12	0
Ambrosia	21061	2022-05-12	0
Edith Márquez	21062	2022-05-12	0
The Standells	21063	2022-05-12	0
Bad Boyz Dj Team	21064	2022-05-12	0
Guts	21065	2022-05-12	0
Del McCoury Band	21066	2022-05-12	0
Bebe Winans	21067	2022-05-12	0
Ramy Ayach	21068	2022-05-12	0
Fat Pat	21069	2022-05-12	0
Zapp	21070	2022-05-12	0
Halvdan Sivertsen	21071	2022-05-12	0
DJ Atmospherik	21072	2022-05-12	0
Bay City Rollers	21073	2022-05-12	0
Beat Hackers	21074	2022-05-12	0
Orquesta Sonara La Habana	21075	2022-05-12	0
Carl Davis	21076	2022-05-12	0
Klone	21077	2022-05-12	0
Billy Williams	21078	2022-05-12	0
All Or Nothing	21079	2022-05-12	0
Rufio	21080	2022-05-12	0
Amnesia	21081	2022-05-12	0
Syndaesia	21082	2022-05-12	0
Die Prinzen	21083	2022-05-12	0
Surfer Blood	21084	2022-05-12	0
Miss Unique	21085	2022-05-12	0
Philipe de Boyar	21086	2022-05-12	0
Blow Up	21087	2022-05-12	0
Sammy Hagar	21088	2022-05-12	0
Jacques Offenbach	21089	2022-05-12	0
Coalesce	21090	2022-05-12	0
Lesley Garrett / BBC Concert / Bateman	21091	2022-05-12	0
Caitlin Cary	21092	2022-05-12	0
Binké Traoré	21093	2022-05-12	0
General Johnson & The Chairmen of the Board	21094	2022-05-12	0
Stephen Trask	21095	2022-05-12	0
Prodigal	21096	2022-05-12	0
Jerry's Kids	21097	2022-05-12	0
Sleeping States	21098	2022-05-12	0
The Jayhawks	21099	2022-05-12	0
Tracy Nelson	21100	2022-05-12	0
Motion City Soundtrack	21101	2022-05-12	0
Vandall	21102	2022-05-12	0
Carlos Chaouen (F)	21103	2022-05-12	0
Don Omar	21104	2022-05-12	0
PeterLicht	21105	2022-05-12	0
INDIETRO	21106	2022-05-12	0
Cocteau Twins	21107	2022-05-12	0
The Whispers	21108	2022-05-12	0
Triple Beam	21109	2022-05-12	0
Four Tops / The Supremes	21110	2022-05-12	0
C+C Music Factory (Presenting Freedom Williams)	21111	2022-05-12	0
All Time High	21112	2022-05-12	0
Loner	21113	2022-05-12	0
Timo Räisänen	21114	2022-05-12	0
Moses McClean	21115	2022-05-12	0
Caravelli	21116	2022-05-12	0
Eat	21117	2022-05-12	0
Liege Lord	21118	2022-05-12	0
Divine Brown	21119	2022-05-12	0
Wild Frontier	21120	2022-05-12	0
Yukmouth & Killa Klump	21121	2022-05-12	0
George Harrison	21122	2022-05-12	0
Eva Trout	21123	2022-05-12	0
Derrin Nauendorf	21124	2022-05-12	0
Captain Mercier	21125	2022-05-12	0
Fotos	21126	2022-05-12	0
Boyd Tinsley	21127	2022-05-12	0
Funny Van Dannen	21128	2022-05-12	0
Hans Paetsch	21129	2022-05-12	0
Lana Klingor	21130	2022-05-12	0
Comfort Fit	21131	2022-05-12	0
Samiam	21132	2022-05-12	0
Clara Moto	21133	2022-05-12	0
Roscoe Mitchell	21134	2022-05-12	0
Tito Puente_ Jr.	21135	2022-05-12	0
Galt MacDermot	21136	2022-05-12	0
Black Pearl	21137	2022-05-12	0
Alfredo Gutiérrez	21138	2022-05-12	0
Amduscia	21139	2022-05-12	0
Hudson Falcons	21140	2022-05-12	0
Adam F Featuring Guru And Carl Thomas	21141	2022-05-12	0
The Dillards	21142	2022-05-12	0
Doleful Lions	21143	2022-05-12	0
Shep & The Limelites	21144	2022-05-12	0
El Bordo	21145	2022-05-12	0
Cowboy Troy	21146	2022-05-12	0
Rose Royce	21147	2022-05-12	0
LORCA	21148	2022-05-12	0
Sahnas	21149	2022-05-12	0
Jill Tracy	21150	2022-05-12	0
David T. Chastain	21151	2022-05-12	0
Domingo Patricio	21152	2022-05-12	0
Ian Carey	21153	2022-05-12	0
Rue De La Muette	21154	2022-05-12	0
Mud	21155	2022-05-12	0
Evita	21156	2022-05-12	0
DJ Rupture	21157	2022-05-12	0
Christine McVie	21158	2022-05-12	0
Michael Feinstein	21159	2022-05-12	0
The Mess Hall	21160	2022-05-12	0
Rebellion the Recaller	21161	2022-05-12	0
Sargasso Trio	21162	2022-05-12	0
Marilyn Mazur	21163	2022-05-12	0
Brandy	21164	2022-05-12	0
The Minimum	21165	2022-05-12	0
Pavement	21166	2022-05-12	0
John Lee Hooker	21167	2022-05-12	0
Truly Yours	21168	2022-05-12	0
Chrissie Hynde	21169	2022-05-12	0
MIMS	21170	2022-05-12	0
Angelic Upstarts	21171	2022-05-12	0
Busdriver featuring Abstract Rude	21172	2022-05-12	0
Monster Magnet	21173	2022-05-12	0
Fabolous	21174	2022-05-12	0
Facundo Cabral	21175	2022-05-12	0
Chorus Line	21176	2022-05-12	0
Elodie Frégé	21177	2022-05-12	0
45 Grave	21178	2022-05-12	0
The Watson Twins	21179	2022-05-12	0
Kurtis Blow	21180	2022-05-12	0
Trashmen	21181	2022-05-12	0
THE NOK	21182	2022-05-12	0
GODGORY	21183	2022-05-12	0
Jorge Muñiz	21184	2022-05-12	0
Marcy Playground	21185	2022-05-12	0
Santa Esmeralda	21186	2022-05-12	0
Draft	21187	2022-05-12	0
The Riptides	21188	2022-05-12	0
Karl Martindahl	21189	2022-05-12	0
Asleep At The Wheel	21190	2022-05-12	0
The Alarm Clocks	21191	2022-05-12	0
Fiestas	21192	2022-05-12	0
Mellomaniacs	21193	2022-05-12	0
Hash Jar Tempo	21194	2022-05-12	0
Chaotic Dischord	21195	2022-05-12	0
Bob Dylan & The Band	21196	2022-05-12	0
Christopher Lawrence	21197	2022-05-12	0
Katie Webster	21198	2022-05-12	0
Yabby You / King Tubby	21199	2022-05-12	0
Angelspit	21200	2022-05-12	0
Pet Shop Boys	21201	2022-05-12	0
Vinylshakerz	21202	2022-05-12	0
Psilodump	21203	2022-05-12	0
Larry Groce/Disneyland Children's Sing-Along Chorus	21204	2022-05-12	0
A Girl A Gun A Ghost	21205	2022-05-12	0
The Marx Brothers	21206	2022-05-12	0
Kollektiver Brechreiz	21207	2022-05-12	0
Peggy Scott-Adams	21208	2022-05-12	0
Mickey 3D	21209	2022-05-12	0
Clarence Gatemouth Brown	21210	2022-05-12	0
Junip	21211	2022-05-12	0
Queen & David Bowie	21212	2022-05-12	0
Lilac Storm	21213	2022-05-12	0
Emery	21214	2022-05-12	0
Molly Bee	21215	2022-05-12	0
Oscar Pettiford	21216	2022-05-12	0
Mint Condition	21217	2022-05-12	0
Kill The Noise	21218	2022-05-12	0
Meryl Streep / Julie Walters / Christine Baranski	21219	2022-05-12	0
Jesus Christ Superstar: Highlights - 20th Anniversary London Cast	21220	2022-05-12	0
Comedian Harmonists	21221	2022-05-12	0
J-Skillz	21222	2022-05-12	0
Steadman	21223	2022-05-12	0
Ramón Orlando	21224	2022-05-12	0
Bush Chemists	21225	2022-05-12	0
Caramell	21226	2022-05-12	0
Max Him	21227	2022-05-12	0
Autistici	21228	2022-05-12	0
Langhorne Slim	21229	2022-05-12	0
Reverend Beat-Man	21230	2022-05-12	0
Ciro Visone	21231	2022-05-12	0
Gangsta Pat	21232	2022-05-12	0
Vampire Hands	21233	2022-05-12	0
Power Pill Fist	21234	2022-05-12	0
Fergie	21235	2022-05-12	0
Kyle Andrews	21236	2022-05-12	0
Séamus Ennis	21237	2022-05-12	0
Grub-Lee	21238	2022-05-12	0
Yung Berg	21239	2022-05-12	0
Peace Love & Pitbulls	21240	2022-05-12	0
Cómplices	21241	2022-05-12	0
Alberta Cross	21242	2022-05-12	0
Jeckyll & Hyde	21243	2022-05-12	0
Bennie Moten	21244	2022-05-12	0
Good Clean Fun	21245	2022-05-12	0
Hank Williams	21246	2022-05-12	0
Clara Hill	21247	2022-05-12	0
Soklak	21248	2022-05-12	0
Lounge Lizards	21249	2022-05-12	0
Blinded Black	21250	2022-05-12	0
Pete Krebs	21251	2022-05-12	0
Orlando	21252	2022-05-12	0
Dog Eat Dog	21253	2022-05-12	0
Sisters Euclid	21254	2022-05-12	0
Almamegretta	21255	2022-05-12	0
Russell Watson / Hayley Westenra	21256	2022-05-12	0
Radio Macandé	21257	2022-05-12	0
Jay-Jay Johanson	21258	2022-05-12	0
Phillip Boa & The VoodooClub	21259	2022-05-12	0
Elmo Red	21260	2022-05-12	0
The Inmates	21261	2022-05-12	0
Tommy Makem	21262	2022-05-12	0
Jimmy McGriff_ Lucky Thompson_ George Freeman_ O'Donel Levy	21263	2022-05-12	0
OFFTHESKY	21264	2022-05-12	0
Chemistry	21265	2022-05-12	0
Cevin Fisher	21266	2022-05-12	0
Eugene Mirman	21267	2022-05-12	0
The Chieftains;Ricky Skaggs	21268	2022-05-12	0
Biquini Cavadão	21269	2022-05-12	0
Liveola	21270	2022-05-12	0
Ridgewalkers Feat. El	21271	2022-05-12	0
MANUEL DE LA MARE_ MATTEO MATTEINI	21272	2022-05-12	0
Berlin Symphony Orchestra	21273	2022-05-12	0
Florent Marchet	21274	2022-05-12	0
Ot Azoj Klezmerband	21275	2022-05-12	0
Paul Jackson_ Jr.	21276	2022-05-12	0
Sleep	21277	2022-05-12	0
Stan	21278	2022-05-12	0
White Denim	21279	2022-05-12	0
Leo Marini	21280	2022-05-12	0
Alejandro Fernandez	21281	2022-05-12	0
Bobby Pulido	21282	2022-05-12	0
Dick Haymes	21283	2022-05-12	0
Odds	21284	2022-05-12	0
Downchild	21285	2022-05-12	0
Vanilla Pod	21286	2022-05-12	0
Celluloide	21287	2022-05-12	0
Zveri	21288	2022-05-12	0
The Haunted	21289	2022-05-12	0
Felix Da Housecat	21290	2022-05-12	0
James Dean Bradfield	21291	2022-05-12	0
Silver Daggers	21292	2022-05-12	0
Fat Joe featuring Opera Steve	21293	2022-05-12	0
Peetie Wheatstraw	21294	2022-05-12	0
Rick Astley Feat. Malik Yoba	21295	2022-05-12	0
The Mossie	21296	2022-05-12	0
Ketil Bjørnstad_ David Darling	21297	2022-05-12	0
Japanische Kampfhörspiele	21298	2022-05-12	0
Savage Garden	21299	2022-05-12	0
Poonanny	21300	2022-05-12	0
The High Level Ranters	21301	2022-05-12	0
Carina Round	21302	2022-05-12	0
Chewy Chocolate Cookies	21303	2022-05-12	0
Antonio Orozco / Tote King	21304	2022-05-12	0
Dressy Bessy	21305	2022-05-12	0
Asterisk*	21306	2022-05-12	0
Spymob	21307	2022-05-12	0
Looptroop	21308	2022-05-12	0
Bon Jovi	21309	2022-05-12	0
Blind Joe Taggart	21310	2022-05-12	0
Los Acosta	21311	2022-05-12	0
Swamp Children	21312	2022-05-12	0
Palace	21313	2022-05-12	0
Etherine	21314	2022-05-12	0
Billy J. Kramer	21315	2022-05-12	0
Los Betos	21316	2022-05-12	0
Alice Stuart	21317	2022-05-12	0
Kabat	21318	2022-05-12	0
310	21319	2022-05-12	0
Bijelo Dugme	21320	2022-05-12	0
Nathan Moore	21321	2022-05-12	0
Gas Huffer	21322	2022-05-12	0
Paula Koivuniemi	21323	2022-05-12	0
Eric Andersen	21324	2022-05-12	0
Sex Slaves	21325	2022-05-12	0
Age Pee	21326	2022-05-12	0
Meli'sa Morgan	21327	2022-05-12	0
The Tiger Lillies	21328	2022-05-12	0
Babyface;Mariah Carey;Kenny G;Shelia E.	21329	2022-05-12	0
Zapp & Roger	21330	2022-05-12	0
The Paul Butterfield Blues Band	21331	2022-05-12	0
John Otway	21332	2022-05-12	0
Dino Merlin	21333	2022-05-12	0
Gus Gus	21334	2022-05-12	0
Umphrey's McGee	21335	2022-05-12	0
DSGB	21336	2022-05-12	0
Jean-Jacques Goldman	21337	2022-05-12	0
Mocedades	21338	2022-05-12	0
Space Raiders	21339	2022-05-12	0
Scapegoat	21340	2022-05-12	0
Dumptruck	21341	2022-05-12	0
Toyah	21342	2022-05-12	0
Guster	21343	2022-05-12	0
Allan Holdsworth	21344	2022-05-12	0
Betty Harris	21345	2022-05-12	0
Ubar Tmar	21346	2022-05-12	0
Mendoza Line_ The	21347	2022-05-12	0
Wilks featuring pee wee ellis	21348	2022-05-12	0
Wideboys Feat. JLC	21349	2022-05-12	0
Electronic	21350	2022-05-12	0
Art Of Noise	21351	2022-05-12	0
From Autumn To Ashes	21352	2022-05-12	0
Paul Horn	21353	2022-05-12	0
Bedouin Ascent	21354	2022-05-12	0
Chaser	21355	2022-05-12	0
Leda Battisti	21356	2022-05-12	0
Susanne Sundfør	21357	2022-05-12	0
Sincabeza	21358	2022-05-12	0
Lions Share	21359	2022-05-12	0
Bucktown Kickback	21360	2022-05-12	0
Brujeria	21361	2022-05-12	0
Ulises Quintero featuring Beatriz Adriana Solis	21362	2022-05-12	0
Aventura	21363	2022-05-12	0
Róisín Murphy	21364	2022-05-12	0
Isabelle Aubret	21365	2022-05-12	0
Do Or Die	21366	2022-05-12	0
Country Joe McDonald	21367	2022-05-12	0
Wee Hairy Beasties	21368	2022-05-12	0
Diamond District	21369	2022-05-12	0
Prhizzm	21370	2022-05-12	0
Jale	21371	2022-05-12	0
Jamie Lewis_ Nick Morris	21372	2022-05-12	0
Mute	21373	2022-05-12	0
The Rumble Strips	21374	2022-05-12	0
Fafá de Belém	21375	2022-05-12	0
Gotan Project	21376	2022-05-12	0
Frequency featuring Harissa May	21377	2022-05-12	0
Juliano Cezar	21378	2022-05-12	0
Mikel Erentxun	21379	2022-05-12	0
Only Crime	21380	2022-05-12	0
Duke Ellington & His Orchestra	21381	2022-05-12	0
Metro Station	21382	2022-05-12	0
Yeasayer	21383	2022-05-12	0
Mary Flower	21384	2022-05-12	0
Ahmad Jamal Trio	21385	2022-05-12	0
Ezgirl	21386	2022-05-12	0
Midival Punditz	21387	2022-05-12	0
µ-ziq	21388	2022-05-12	0
Book Of Love	21389	2022-05-12	0
Nothingface	21390	2022-05-12	0
MilkMoneyMaffia	21391	2022-05-12	0
3xKrazy	21392	2022-05-12	0
Luan Parle	21393	2022-05-12	0
La Billo	21394	2022-05-12	0
Sunk Loto	21395	2022-05-12	0
Holy Moses	21396	2022-05-12	0
Total Eclipse	21397	2022-05-12	0
Afro Celt Sound System	21398	2022-05-12	0
La Bergère	21399	2022-05-12	0
Make Believe	21400	2022-05-12	0
Hazami	21401	2022-05-12	0
David Torn	21402	2022-05-12	0
Passi	21403	2022-05-12	0
Sutton Foster / Roger Bart / Christopher Fitzgerald	21404	2022-05-12	0
Scorpions	21405	2022-05-12	0
Bohren & Der Club Of Gore	21406	2022-05-12	0
Dirty Harry	21407	2022-05-12	0
Paul Revere & The Raiders (featuring Mark Lindsay)	21408	2022-05-12	0
Slick	21409	2022-05-12	0
Poema Arcanus	21410	2022-05-12	0
Zig Zag	21411	2022-05-12	0
Doug Kershaw	21412	2022-05-12	0
Planxty	21413	2022-05-12	0
The Van Pelt	21414	2022-05-12	0
David Murray	21415	2022-05-12	0
Climax Blues Band	21416	2022-05-12	0
Gamma Ray	21417	2022-05-12	0
Talla 2XLC vs. Robert Burian	21418	2022-05-12	0
Temper	21419	2022-05-12	0
Michael Kiske	21420	2022-05-12	0
Fleetwood Mac	21421	2022-05-12	0
Flight Of The Conchords	21422	2022-05-12	0
Al B. Sure!	21423	2022-05-12	0
Audioscape & Kelly C.	21424	2022-05-12	0
Vin Gordon	21425	2022-05-12	0
James Blunt	21426	2022-05-12	0
Breez Evahflowin	21427	2022-05-12	0
Fairport Convention	21428	2022-05-12	0
The War On Drugs	21429	2022-05-12	0
Louisa Mark	21430	2022-05-12	0
The B-52s	21431	2022-05-12	0
Jane Child	21432	2022-05-12	0
Darkthrone	21433	2022-05-12	0
Tre-8	21434	2022-05-12	0
The Mooney Suzuki	21435	2022-05-12	0
Area²	21436	2022-05-12	0
Voltio	21437	2022-05-12	0
Ultrabeat	21438	2022-05-12	0
Eisley	21439	2022-05-12	0
Greeley Estates	21440	2022-05-12	0
LONDON SYMPHONY ORCHESTRA + VA	21441	2022-05-12	0
Joseph Arthur	21442	2022-05-12	0
Hard 'n Phirm	21443	2022-05-12	0
Junction 18	21444	2022-05-12	0
Monolith	21445	2022-05-12	0
Worm	21446	2022-05-12	0
Get Well Soon	21447	2022-05-12	0
Chupa Chupa	21448	2022-05-12	0
The Knife	21449	2022-05-12	0
Lacuna	21450	2022-05-12	0
The Chantels	21451	2022-05-12	0
Atomic Hooligan	21452	2022-05-12	0
Cock Sparrer	21453	2022-05-12	0
The Candy Snatchers	21454	2022-05-12	0
Extol	21455	2022-05-12	0
Mikey Spice	21456	2022-05-12	0
Gerty Farish	21457	2022-05-12	0
Clearlake	21458	2022-05-12	0
Terror Squad	21459	2022-05-12	0
Salah Edin feat. Probz	21460	2022-05-12	0
Gail Davies	21461	2022-05-12	0
Robert Michaels	21462	2022-05-12	0
Aly & AJ	21463	2022-05-12	0
Starsplash	21464	2022-05-12	0
Zinc	21465	2022-05-12	0
Time Passing	21466	2022-05-12	0
Mark Chesnutt	21467	2022-05-12	0
Benny Neyman	21468	2022-05-12	0
Art Blakey_ Jazz Messengers	21469	2022-05-12	0
Suburban Knight	21470	2022-05-12	0
Mest	21471	2022-05-12	0
Fireball Ministry	21472	2022-05-12	0
Jackson And His Computer Band	21473	2022-05-12	0
Andrea Smith	21474	2022-05-12	0
Amandine	21475	2022-05-12	0
General Pecos	21476	2022-05-12	0
Love Jones	21477	2022-05-12	0
Groove Generator	21478	2022-05-12	0
Thirsty Moon	21479	2022-05-12	0
Paris Hilton	21480	2022-05-12	0
Seductive Souls	21481	2022-05-12	0
Corderoy & U4IC DJ'S	21482	2022-05-12	0
Russell Watson / Royal Philharmonic Orchestra / Nicholas Dodd	21483	2022-05-12	0
Pluto	21484	2022-05-12	0
Philip Bailey	21485	2022-05-12	0
Thee Silver Mt. Zion Memorial Orchestra	21486	2022-05-12	0
Agnes Carlsson	21487	2022-05-12	0
The Go Set	21488	2022-05-12	0
Majik Most	21489	2022-05-12	0
Doro	21490	2022-05-12	0
Gloria De Haven	21491	2022-05-12	0
The Jazz Messengers	21492	2022-05-12	0
Junior Mance/ Keter Betts/ Jackie Williams	21493	2022-05-12	0
Suzanne Vega	21494	2022-05-12	0
Brand New Unit	21495	2022-05-12	0
Don Gardner	21496	2022-05-12	0
Khold	21497	2022-05-12	0
Marion Raven	21498	2022-05-12	0
Bob Luman	21499	2022-05-12	0
Client	21500	2022-05-12	0
Selena	21501	2022-05-12	0
Victor Borge	21502	2022-05-12	0
Sérgio Mendes Trio	21503	2022-05-12	0
Gerhard Gundermann	21504	2022-05-12	0
Mauro Pagani	21505	2022-05-12	0
Krumbsnatcha	21506	2022-05-12	0
Francisco Lopez	21507	2022-05-12	0
Timbaland / Nelly Furtado / Soshy	21508	2022-05-12	0
Pauline Ester	21509	2022-05-12	0
Mock & Toof	21510	2022-05-12	0
Starecase	21511	2022-05-12	0
God Damn	21512	2022-05-12	0
JayMay	21513	2022-05-12	0
Seven Places	21514	2022-05-12	0
Axwell & Sebastian Ingrosso vs Salem Al Fakir	21515	2022-05-12	0
Sparkles in the Milk	21516	2022-05-12	0
Clay Aiken	21517	2022-05-12	0
Hangnail	21518	2022-05-12	0
Metermaids	21519	2022-05-12	0
1990s	21520	2022-05-12	0
Technicolour	21521	2022-05-12	0
Tex Ritter	21522	2022-05-12	0
B.B. King	21523	2022-05-12	0
MY EARLY MUSTANG	21524	2022-05-12	0
G.I.N.	21525	2022-05-12	0
Passive Progressive	21526	2022-05-12	0
The Church	21527	2022-05-12	0
Madee	21528	2022-05-12	0
Johnny & the Hurricanes	21529	2022-05-12	0
Giorgos Gatzigristos	21530	2022-05-12	0
McLean	21531	2022-05-12	0
Andre Previn / London Symphony Orchestra	21532	2022-05-12	0
Steinski	21533	2022-05-12	0
Ace Deuce	21534	2022-05-12	0
Sinead O' Connor	21535	2022-05-12	0
Louis Armstrong Hot Five	21536	2022-05-12	0
The Microscopic Septet	21537	2022-05-12	0
The Loafers	21538	2022-05-12	0
Etoile De Dakar	21539	2022-05-12	0
Elephant Man	21540	2022-05-12	0
Tony Rice	21541	2022-05-12	0
Don Tetto	21542	2022-05-12	0
Natiruts	21543	2022-05-12	0
The Datsuns	21544	2022-05-12	0
2562	21545	2022-05-12	0
Shajan	21546	2022-05-12	0
Allen Toussaint	21547	2022-05-12	0
Fred Buscaglione	21548	2022-05-12	0
Beats Antique	21549	2022-05-12	0
Haroun	21550	2022-05-12	0
Sir Elwoodin Hiljaiset Varit	21551	2022-05-12	0
Dave Hamilton	21552	2022-05-12	0
Fire Engines	21553	2022-05-12	0
Bob Mould	21554	2022-05-12	0
Chali 2na	21555	2022-05-12	0
Abi Wallenstein	21556	2022-05-12	0
Atom & His Package	21557	2022-05-12	0
Karmatronic	21558	2022-05-12	0
Rahat Fateh Ali Khan	21559	2022-05-12	0
Staple Singers	21560	2022-05-12	0
Claud 9	21561	2022-05-12	0
The Occasional Keepers	21562	2022-05-12	0
Seals and Crofts	21563	2022-05-12	0
McGuinn_ Clark & Hillman	21564	2022-05-12	0
Benny Martin	21565	2022-05-12	0
Pedro Javier Hermosilla	21566	2022-05-12	0
Gorilla	21567	2022-05-12	0
Sean Cronin & Steve Morley	21568	2022-05-12	0
Laurel Aitken_ The Cookoomackastick	21569	2022-05-12	0
Ziggy X	21570	2022-05-12	0
Jon Anderson	21571	2022-05-12	0
Raine Maida	21572	2022-05-12	0
Dynamix Feat. Jason Walker	21573	2022-05-12	0
Mommy Hurt My Head	21574	2022-05-12	0
Jodi Benson	21575	2022-05-12	0
Myracle Brah	21576	2022-05-12	0
B.Roy et sa Bande	21577	2022-05-12	0
Bill Perkins	21578	2022-05-12	0
Steve Diggle	21579	2022-05-12	0
The Routers	21580	2022-05-12	0
US Air Force Band of Flight	21581	2022-05-12	0
The Sonics_ Charlie & The Tunas	21582	2022-05-12	0
Damiano	21583	2022-05-12	0
Sarah Connor / Naturally 7	21584	2022-05-12	0
Ultima Bleep	21585	2022-05-12	0
Andrea Bocelli / Orchestra del Maggio Musicale Fiorentino / Gianandrea Noseda	21586	2022-05-12	0
Wiener Konzerthausorchester_ Wiener Sängerknaben	21587	2022-05-12	0
Anima Eterna	21588	2022-05-12	0
Shamen	21589	2022-05-12	0
After The Fall	21590	2022-05-12	0
Danielle Brisebois	21591	2022-05-12	0
Company Flow	21592	2022-05-12	0
Cabeças No Ar	21593	2022-05-12	0
Arnaud Le Texier & Emmanuel Ternois	21594	2022-05-12	0
...arrived at ten	21595	2022-05-12	0
Bill Brovold and Larval	21596	2022-05-12	0
No Te Va Gustar and Martin Moron	21597	2022-05-12	0
Da Lench Mob	21598	2022-05-12	0
Mad Skillz	21599	2022-05-12	0
George Michael	21600	2022-05-12	0
Lonesome Pine Fiddlers	21601	2022-05-12	0
Rocket City Riot	21602	2022-05-12	0
Anssi Kela	21603	2022-05-12	0
Terence Trent D'Arby	21604	2022-05-12	0
Diomay	21605	2022-05-12	0
Pylon	21606	2022-05-12	0
Liam Clancy	21607	2022-05-12	0
The Real Thing	21608	2022-05-12	0
Mountain	21609	2022-05-12	0
Alpha 5.20	21610	2022-05-12	0
Partisans	21611	2022-05-12	0
India.Arie / Musiq Soulchild	21612	2022-05-12	0
Belcea Quartet	21613	2022-05-12	0
Bombay Rockers	21614	2022-05-12	0
Zeke	21615	2022-05-12	0
Willie Nelson	21616	2022-05-12	0
CHARLIE HUNTER WITH LEON PARKER	21617	2022-05-12	0
Jordan Knight	21618	2022-05-12	0
The Legends	21619	2022-05-12	0
Vincent De Moor	21620	2022-05-12	0
KRS-One_ Buckshot	21621	2022-05-12	0
War Of Ages	21622	2022-05-12	0
Darwin Hobbs	21623	2022-05-12	0
Junkyard	21624	2022-05-12	0
Comin´ Correct	21625	2022-05-12	0
Nemesis & Arrogance	21626	2022-05-12	0
Oysterhead	21627	2022-05-12	0
Magtens Korridorer	21628	2022-05-12	0
Nate Dogg	21629	2022-05-12	0
Angelique Kidjo	21630	2022-05-12	0
Moist	21631	2022-05-12	0
Peja	21632	2022-05-12	0
Juan Atkins	21633	2022-05-12	0
Jairzinho Oliveira	21634	2022-05-12	0
Après La Classe	21635	2022-05-12	0
Gravediggaz	21636	2022-05-12	0
Ari Koivunen	21637	2022-05-12	0
D:FOLT feat. Marcie	21638	2022-05-12	0
Sowmya Raoh ;Sukhwinder Singh;Jolly Mukherjee;Parthiv	21639	2022-05-12	0
Gene Clark	21640	2022-05-12	0
High Dependency Unit	21641	2022-05-12	0
Yolandita Monge	21642	2022-05-12	0
Mutlu	21643	2022-05-12	0
Destroy The Runner	21644	2022-05-12	0
Tungtvann	21645	2022-05-12	0
Zaïko Langa Langa	21646	2022-05-12	0
Jackopierce	21647	2022-05-12	0
Milanese Vs Virus Syndicate	21648	2022-05-12	0
Sam Isaac	21649	2022-05-12	0
Pascal Comelade	21650	2022-05-12	0
Eliseo Parra	21651	2022-05-12	0
Jim Hall / Ron Carter	21652	2022-05-12	0
Melanie C	21653	2022-05-12	0
The Perishers	21654	2022-05-12	0
DJ Rashad	21655	2022-05-12	0
Kid Congo Powers	21656	2022-05-12	0
Rômulo Fróes	21657	2022-05-12	0
Black Uhuru	21658	2022-05-12	0
Nordvargr/Drakh	21659	2022-05-12	0
Homesick James	21660	2022-05-12	0
Gerald Jay Markoe	21661	2022-05-12	0
F.I.R.	21662	2022-05-12	0
Stefano Prada	21663	2022-05-12	0
McEnroe	21664	2022-05-12	0
Tom Verlaine	21665	2022-05-12	0
Glasseater	21666	2022-05-12	0
Beowülf	21667	2022-05-12	0
Amanda Perez	21668	2022-05-12	0
Glen Washington	21669	2022-05-12	0
MPB-4 / Quarteto Em Cy	21670	2022-05-12	0
Drexciya	21671	2022-05-12	0
Sneaky Feelings	21672	2022-05-12	0
Joe Henry	21673	2022-05-12	0
Banda Cheiro De Amor	21674	2022-05-12	0
Nuova Compagnia Di Canto Popolare	21675	2022-05-12	0
Delirious	21676	2022-05-12	0
Noel Harrison	21677	2022-05-12	0
Moltheni	21678	2022-05-12	0
Paul Miller	21679	2022-05-12	0
Sunshaker	21680	2022-05-12	0
Ulrich Schnauss	21681	2022-05-12	0
Abdelaziz Stati	21682	2022-05-12	0
Eimear Quinn	21683	2022-05-12	0
Union Of Knives	21684	2022-05-12	0
Karaoke (Made famous by Dr. Dre)	21685	2022-05-12	0
Bigfoot	21686	2022-05-12	0
S Club	21687	2022-05-12	0
Carl Davis;Martin Savage	21688	2022-05-12	0
Valentino Kanzyani	21689	2022-05-12	0
Fin	21690	2022-05-12	0
The Shaky Hands	21691	2022-05-12	0
Alice Russell	21692	2022-05-12	0
B.A.D.	21693	2022-05-12	0
Bebo Valdés	21694	2022-05-12	0
Mason Williams	21695	2022-05-12	0
Mitch Ryder & The Detroit Wheels	21696	2022-05-12	0
The Muffs	21697	2022-05-12	0
Urban Soul	21698	2022-05-12	0
Andrea Klas	21699	2022-05-12	0
Enslaved	21700	2022-05-12	0
Roadrunner United	21701	2022-05-12	0
Lenny LeBlanc	21702	2022-05-12	0
American Music Club	21703	2022-05-12	0
Skruk	21704	2022-05-12	0
Reload	21705	2022-05-12	0
Space Buddha featuring Toast3d	21706	2022-05-12	0
H2O	21707	2022-05-12	0
Insect Warfare	21708	2022-05-12	0
Krayzie Bone	21709	2022-05-12	0
Marty Stuart	21710	2022-05-12	0
Lady Bug Transistor	21711	2022-05-12	0
Herrenmagazin	21712	2022-05-12	0
Codec & Flexor	21713	2022-05-12	0
Jerry Yan	21714	2022-05-12	0
Wire	21715	2022-05-12	0
Memphis Bleek / Jay-Z	21716	2022-05-12	0
The Nashville Bluegrass Band	21717	2022-05-12	0
Natalia	21718	2022-05-12	0
Los Galvan	21719	2022-05-12	0
Brave Old World	21720	2022-05-12	0
Clement Irie	21721	2022-05-12	0
Arnaud Fleurent-Didier	21722	2022-05-12	0
B3	21723	2022-05-12	0
November	21724	2022-05-12	0
Abdel Aziz El Mubarak	21725	2022-05-12	0
Patsy Cline	21726	2022-05-12	0
NOFX	21727	2022-05-12	0
Estradasphere	21728	2022-05-12	0
Eric Darius	21729	2022-05-12	0
The Brecker Brothers	21730	2022-05-12	0
The Timetravellers	21731	2022-05-12	0
LoveLikeFire	21732	2022-05-12	0
Marco Remus	21733	2022-05-12	0
Dreamcatcher	21734	2022-05-12	0
Abrasive Wheels	21735	2022-05-12	0
John Williamson	21736	2022-05-12	0
The Lord High Fixers	21737	2022-05-12	0
Reverend Bizarre	21738	2022-05-12	0
Gogol Bordello	21739	2022-05-12	0
Weird Al Yankovic;Kanye West;Snoop Dogg;50 Cent;Franz Ferdinand;The Black Eyed Peas;The Killers	21740	2022-05-12	0
James Ingram	21741	2022-05-12	0
Million Dollar Mouth	21742	2022-05-12	0
Name The Pet	21743	2022-05-12	0
Blezqi Zatsaz	21744	2022-05-12	0
Ella Fitzgerald / Joe Pass	21745	2022-05-12	0
Armchair Martian	21746	2022-05-12	0
The Doors	21747	2022-05-12	0
Stephen Stills	21748	2022-05-12	0
Carl Verheyen	21749	2022-05-12	0
Elliott	21750	2022-05-12	0
Ruben de Ronde	21751	2022-05-12	0
Julien Clerc	21752	2022-05-12	0
Amari	21753	2022-05-12	0
Run Chico Run	21754	2022-05-12	0
Thomas Krome	21755	2022-05-12	0
Pino Daniele	21756	2022-05-12	0
Zion Train	21757	2022-05-12	0
Radio Birdman	21758	2022-05-12	0
Martin Carthy with Dave Swarbrick	21759	2022-05-12	0
Maryon Rags	21760	2022-05-12	0
Kristin Hersh	21761	2022-05-12	0
La Lupita	21762	2022-05-12	0
Isildurs Bane	21763	2022-05-12	0
The Cosmosamatics	21764	2022-05-12	0
MARTIJN TEN VELDEN	21765	2022-05-12	0
Juni Järvi	21766	2022-05-12	0
Bon Jovi / Jennifer Nettles	21767	2022-05-12	0
Johnny Rivers	21768	2022-05-12	0
Staind	21769	2022-05-12	0
Winans Phase 2	21770	2022-05-12	0
Jocelyn Pook	21771	2022-05-12	0
Kid Carpet	21772	2022-05-12	0
Brand New Disaster	21773	2022-05-12	0
Dracul	21774	2022-05-12	0
Thelonious Monk	21775	2022-05-12	0
Madskillz	21776	2022-05-12	0
Cameo	21777	2022-05-12	0
Azalia Snail	21778	2022-05-12	0
Leevi and the leavings	21779	2022-05-12	0
Sir Neville Marriner/Academy of St Martin-in-the-Fields	21780	2022-05-12	0
Basement 5	21781	2022-05-12	0
Archers Of Loaf	21782	2022-05-12	0
Jarvis Humby	21783	2022-05-12	0
Kode9	21784	2022-05-12	0
Joke	21785	2022-05-12	0
Wideboys ft. Shaznay Lewis	21786	2022-05-12	0
Damien Thorne	21787	2022-05-12	0
Taproot	21788	2022-05-12	0
Lonesome Standard Time	21789	2022-05-12	0
Eg	21790	2022-05-12	0
Johnny Depp_ Helena Bonham Carter	21791	2022-05-12	0
Kevin Devine	21792	2022-05-12	0
Deitrick Haddon featuring WWIC M.V.P. Youth Choir	21793	2022-05-12	0
Gary Lucas & Gods & Monsters	21794	2022-05-12	0
Floetry	21795	2022-05-12	0
Ozzy Osbourne	21796	2022-05-12	0
Dora The Explorer	21797	2022-05-12	0
Lita Ford	21798	2022-05-12	0
The Baltimore Consort	21799	2022-05-12	0
Laura Izibor	21800	2022-05-12	0
Andre Nickatina aka Dre Dog	21801	2022-05-12	0
Edward Sharpe & The Magnetic Zeros	21802	2022-05-12	0
Apurimac	21803	2022-05-12	0
The Daisy Riots	21804	2022-05-12	0
Willie Clayton	21805	2022-05-12	0
Nadine Wrietz	21806	2022-05-12	0
Comtron	21807	2022-05-12	0
4hero feat. Lady Alma	21808	2022-05-12	0
Necro Facility	21809	2022-05-12	0
Casa Loma Orchestra	21810	2022-05-12	0
Quickspace	21811	2022-05-12	0
Ivory Joe Hunter	21812	2022-05-12	0
Josh Turner	21813	2022-05-12	0
The Padded Cell	21814	2022-05-12	0
Fabulous Disaster	21815	2022-05-12	0
Big Tuck / Dre	21816	2022-05-12	0
Bloodstone	21817	2022-05-12	0
John Foxx & Harold Budd	21818	2022-05-12	0
Blind Pilot	21819	2022-05-12	0
Pinetop Seven	21820	2022-05-12	0
Michael James	21821	2022-05-12	0
Amanda Ghost	21822	2022-05-12	0
Street Brawl	21823	2022-05-12	0
Shakta	21824	2022-05-12	0
The Crüxshadows	21825	2022-05-12	0
Jordy Lishious	21826	2022-05-12	0
Richard Zimmerman	21827	2022-05-12	0
Mothergong	21828	2022-05-12	0
Masters Apprentices	21829	2022-05-12	0
One More Time	21830	2022-05-12	0
Kathy Troccoli	21831	2022-05-12	0
Susheela Raman	21832	2022-05-12	0
Blu Cantrell Featuring Ian Lewis of Inner Circle	21833	2022-05-12	0
Speedy J.	21834	2022-05-12	0
Little" Jimmy Dickens	21835	2022-05-12	0
Gowan	21836	2022-05-12	0
Crucial Conflict	21837	2022-05-12	0
Paul Lingle	21838	2022-05-12	0
Keith Caputo	21839	2022-05-12	0
Eddie Izzard	21840	2022-05-12	0
Flat Earth Society	21841	2022-05-12	0
Logical Nonsense	21842	2022-05-12	0
Ramin Djawadi	21843	2022-05-12	0
Broken Hope	21844	2022-05-12	0
Fort Minor (Featuring John Legend)	21845	2022-05-12	0
Technoir	21846	2022-05-12	0
Eri2	21847	2022-05-12	0
Grant Green	21848	2022-05-12	0
Uncle Eye & The Strange Change Machine	21849	2022-05-12	0
Tracy Byrd	21850	2022-05-12	0
The Harptones	21851	2022-05-12	0
Tony & The Beat Brothers	21852	2022-05-12	0
Vuokko Hovatta	21853	2022-05-12	0
Dezmond Dez	21854	2022-05-12	0
Screams For Tina	21855	2022-05-12	0
Suff Daddy	21856	2022-05-12	0
Milena Vucic	21857	2022-05-12	0
Bosse	21858	2022-05-12	0
Frank Stokes	21859	2022-05-12	0
Cérebro Eletrônico	21860	2022-05-12	0
Four Year Strong	21861	2022-05-12	0
Jokeren	21862	2022-05-12	0
Commissioned	21863	2022-05-12	0
Make Do And Mend	21864	2022-05-12	0
J. Pachelbel	21865	2022-05-12	0
Zen Cafe	21866	2022-05-12	0
Blaze feat. Barbara Tucker	21867	2022-05-12	0
Tex Perkins / Don Walker / Charlie Owen	21868	2022-05-12	0
King Tubby and The Upsetters	21869	2022-05-12	0
Pad Anthony	21870	2022-05-12	0
100 Folk Celsius	21871	2022-05-12	0
Destiny's Child	21872	2022-05-12	0
Mossa	21873	2022-05-12	0
The Cars	21874	2022-05-12	0
Niki Haris	21875	2022-05-12	0
Dusty	21876	2022-05-12	0
Colony 5	21877	2022-05-12	0
Federico Villa	21878	2022-05-12	0
Dr John And The Lower 911_ Terence Blanchard	21879	2022-05-12	0
Jennifer Lopez	21880	2022-05-12	0
Bluetones	21881	2022-05-12	0
Taï Phong	21882	2022-05-12	0
Patrick Wolf	21883	2022-05-12	0
Barrington Levy	21884	2022-05-12	0
Amaral	21885	2022-05-12	0
Olivia Newton-John with Melinda Schneider	21886	2022-05-12	0
Morocco	21887	2022-05-12	0
Essential Logic	21888	2022-05-12	0
Ritual carnage	21889	2022-05-12	0
moe.	21890	2022-05-12	0
Beyond The Sixth Seal	21891	2022-05-12	0
DJ Ayres feat. GLC	21892	2022-05-12	0
No More Babylon	21893	2022-05-12	0
Pompeii	21894	2022-05-12	0
Predators	21895	2022-05-12	0
Barbarito Diez	21896	2022-05-12	0
The Presidents of the United States of America	21897	2022-05-12	0
Big Fat Snake	21898	2022-05-12	0
Liv Kristine	21899	2022-05-12	0
Tom Baxter	21900	2022-05-12	0
Dwele	21901	2022-05-12	0
Ronnie Drew	21902	2022-05-12	0
Nelly / Justin Timberlake	21903	2022-05-12	0
New York Dolls	21904	2022-05-12	0
Dendemann	21905	2022-05-12	0
D'azoo at night	21906	2022-05-12	0
Lightning Bolt	21907	2022-05-12	0
Jacques Douai	21908	2022-05-12	0
Rodney O & Joe Cooley	21909	2022-05-12	0
Endellion String Quartet	21910	2022-05-12	0
Clarence "Gatemouth" Brown	21911	2022-05-12	0
Eric Laville	21912	2022-05-12	0
Renato Carosone	21913	2022-05-12	0
S Club Juniors	21914	2022-05-12	0
Hammerhead	21915	2022-05-12	0
Motsi Ski	21916	2022-05-12	0
TOKYO JIHEN	21917	2022-05-12	0
Groove Collective	21918	2022-05-12	0
Kutless	21919	2022-05-12	0
Haters	21920	2022-05-12	0
C.S.I.	21921	2022-05-12	0
Freibeuter AG	21922	2022-05-12	0
Joe Hisaishi	21923	2022-05-12	0
Panteon Rococo	21924	2022-05-12	0
Riccardo Tesi	21925	2022-05-12	0
Alan Menken	21926	2022-05-12	0
Patrice Pike & Wayne Sutton	21927	2022-05-12	0
Youthful Praise	21928	2022-05-12	0
Lisa Lashes	21929	2022-05-12	0
Jimmy Needham	21930	2022-05-12	0
Rusted Shut	21931	2022-05-12	0
Roderick Williams	21932	2022-05-12	0
Dan Zanes_Friends	21933	2022-05-12	0
Micron	21934	2022-05-12	0
Gerard MC	21935	2022-05-12	0
Explainer	21936	2022-05-12	0
JoJo	21937	2022-05-12	0
98 Mute	21938	2022-05-12	0
Minotaur Shock	21939	2022-05-12	0
Morris Day	21940	2022-05-12	0
Little Freddie King	21941	2022-05-12	0
Stacy Sullivan	21942	2022-05-12	0
Breaking Pangaea	21943	2022-05-12	0
Javier Navarrete	21944	2022-05-12	0
The Golden Gate Quartet	21945	2022-05-12	0
Jason Lytle	21946	2022-05-12	0
The Kilimanjaro Darkjazz Ensemble	21947	2022-05-12	0
Complot Bronswick	21948	2022-05-12	0
Kreidler	21949	2022-05-12	0
Soldier Dolls	21950	2022-05-12	0
DJ Nikita Capricorn	21951	2022-05-12	0
The Volta Sound	21952	2022-05-12	0
Tabu	21953	2022-05-12	0
The Doobie Brothers	21954	2022-05-12	0
Pallas	21955	2022-05-12	0
Minny Pops	21956	2022-05-12	0
Nevermore	21957	2022-05-12	0
The Hit Factory	21958	2022-05-12	0
Carl Story	21959	2022-05-12	0
Mathey	21960	2022-05-12	0
Ikarus	21961	2022-05-12	0
Po' Girl	21962	2022-05-12	0
Indras	21963	2022-05-12	0
Napalm Death Vs Delta 9	21964	2022-05-12	0
Stigmata	21965	2022-05-12	0
Pink Floyd	21966	2022-05-12	0
Watersons	21967	2022-05-12	0
Vittorio De Scalzi	21968	2022-05-12	0
King's X	21969	2022-05-12	0
Death By Stereo	21970	2022-05-12	0
Mac Wiseman (With Special Guests Lester Flatt & Chubby Wise)	21971	2022-05-12	0
ANDY TIMMONS	21972	2022-05-12	0
Second Coming	21973	2022-05-12	0
Hank Dogs	21974	2022-05-12	0
Crooked Stilo (Feat. Kinto Sol)	21975	2022-05-12	0
Wilson Simonal	21976	2022-05-12	0
Kabeedies	21977	2022-05-12	0
Funky Green Dogs	21978	2022-05-12	0
Nicholson_ Shane	21979	2022-05-12	0
Husker Du	21980	2022-05-12	0
Holly Palmer	21981	2022-05-12	0
Drome	21982	2022-05-12	0
Tim Christensen	21983	2022-05-12	0
Ray Conniff	21984	2022-05-12	0
Gyllene Tider	21985	2022-05-12	0
David Lyndon Huff	21986	2022-05-12	0
Dada	21987	2022-05-12	0
Animals on Wheels	21988	2022-05-12	0
Ten Foot Pole	21989	2022-05-12	0
Bobby Fuller Four	21990	2022-05-12	0
Nando Lauria	21991	2022-05-12	0
Voices On The Verge	21992	2022-05-12	0
Willowz_ The	21993	2022-05-12	0
Guardianes Del Amor	21994	2022-05-12	0
Joe Williams_ The Thad Jones_ Mel Lewis Orchestra	21995	2022-05-12	0
SECRET SPHERE	21996	2022-05-12	0
Rose Cousins	21997	2022-05-12	0
Santo & Johnny - Vol 3	21998	2022-05-12	0
Roadside Monument	21999	2022-05-12	0
The Freedom	22000	2022-05-12	0
Alix Perez	22001	2022-05-12	0
Colby O'Donis	22002	2022-05-12	0
Hafdis Huld	22003	2022-05-12	0
Gene Ammons	22004	2022-05-12	0
The Verbrilli Sound	22005	2022-05-12	0
The Fallacy	22006	2022-05-12	0
Alejandro Sanz	22007	2022-05-12	0
Kid Down	22008	2022-05-12	0
Rick Trevino	22009	2022-05-12	0
Duncan Browne Sebastian Graham Jones	22010	2022-05-12	0
The Spectres	22011	2022-05-12	0
Babyshambles	22012	2022-05-12	0
Stephan Remmler	22013	2022-05-12	0
Classified	22014	2022-05-12	0
Sick On The Bus	22015	2022-05-12	0
Blekbala Mujik	22016	2022-05-12	0
Boston Pops Orchestra	22017	2022-05-12	0
Jim Johnston with Adam Morenoff	22018	2022-05-12	0
Afromental	22019	2022-05-12	0
Triosk	22020	2022-05-12	0
Eliza Doolittle	22021	2022-05-12	0
Chris Camozzi	22022	2022-05-12	0
Redemption	22023	2022-05-12	0
Dub Resistance	22024	2022-05-12	0
Jennifer Love Hewitt	22025	2022-05-12	0
Death From Above 1979	22026	2022-05-12	0
Spiritualized	22027	2022-05-12	0
Wyclef Jean featuring Refugee Allstars	22028	2022-05-12	0
Moussa Diallo	22029	2022-05-12	0
Long John Baldry	22030	2022-05-12	0
Mauro Ottolini 8Funk Project	22031	2022-05-12	0
Schweisser	22032	2022-05-12	0
I-f Feat. Nancy Fortune	22033	2022-05-12	0
Leon Ware	22034	2022-05-12	0
Paul Revere & The Raiders featuring Mark Lindsay	22035	2022-05-12	0
Dropkick Murphys & The Business	22036	2022-05-12	0
GBH	22037	2022-05-12	0
Ketil Bjørnstad	22038	2022-05-12	0
Liquid_ Liquid	22039	2022-05-12	0
Sieges Even	22040	2022-05-12	0
Ferd (Jelly Roll) Morton	22041	2022-05-12	0
Frightened Rabbit	22042	2022-05-12	0
Jahcoozi	22043	2022-05-12	0
Dave Mason	22044	2022-05-12	0
Gold Panda	22045	2022-05-12	0
Cocorosie	22046	2022-05-12	0
Controlling the Famous	22047	2022-05-12	0
SUPREME BEINGS OF LEISURE	22048	2022-05-12	0
Luna Halo	22049	2022-05-12	0
Dabruck & Klein feat. Michael Feiner	22050	2022-05-12	0
Passion Pit	22051	2022-05-12	0
Ian Gomm	22052	2022-05-12	0
Skalpel	22053	2022-05-12	0
Howard Hewett	22054	2022-05-12	0
Boys Night Out	22055	2022-05-12	0
Sleepytime Gorilla Museum	22056	2022-05-12	0
G4 featuring Stephen Gately	22057	2022-05-12	0
Blues Saraceno	22058	2022-05-12	0
Cancerslug	22059	2022-05-12	0
Epidemic	22060	2022-05-12	0
Pete Townshend	22061	2022-05-12	0
Creeper Lagoon	22062	2022-05-12	0
Bo Carter	22063	2022-05-12	0
Number One Gun	22064	2022-05-12	0
Sir Mix-A-Lot	22065	2022-05-12	0
Cool Breeze	22066	2022-05-12	0
Sandy Posey	22067	2022-05-12	0
The Harvey Averne Dozen	22068	2022-05-12	0
Slut	22069	2022-05-12	0
Young Deenay	22070	2022-05-12	0
Chiodos	22071	2022-05-12	0
PSK-13	22072	2022-05-12	0
Amplified Heat	22073	2022-05-12	0
Lawnmower Deth	22074	2022-05-12	0
Dean Fichna	22075	2022-05-12	0
Medicine	22076	2022-05-12	0
Anjulie	22077	2022-05-12	0
D.A.F.	22078	2022-05-12	0
Stacy Lattisaw & Johnny Gill	22079	2022-05-12	0
Fred Merpol	22080	2022-05-12	0
Cristian Castro	22081	2022-05-12	0
Chuckii Booker	22082	2022-05-12	0
Elizabeth Cotten	22083	2022-05-12	0
Mr Cooper	22084	2022-05-12	0
Jaco Pastorius	22085	2022-05-12	0
Jakob Magnusson	22086	2022-05-12	0
Envoy	22087	2022-05-12	0
Dan Melchior's Broke Revue	22088	2022-05-12	0
Sunglasses After Dark	22089	2022-05-12	0
DIVOKEJ BILL	22090	2022-05-12	0
Killer Mike	22091	2022-05-12	0
Marc Depulse	22092	2022-05-12	0
Lichtensteiner	22093	2022-05-12	0
See No Evil	22094	2022-05-12	0
Erskine Hawkins and His Orchestra	22095	2022-05-12	0
The English Band	22096	2022-05-12	0
El Tiempo	22097	2022-05-12	0
Flora Purim	22098	2022-05-12	0
Backfire!	22099	2022-05-12	0
Constantines	22100	2022-05-12	0
Gotye	22101	2022-05-12	0
Celia Cruz & Johnny Pacheco	22102	2022-05-12	0
Kenny Lattimore	22103	2022-05-12	0
Hank Crawford	22104	2022-05-12	0
Johnny	22105	2022-05-12	0
Meiju Suvas	22106	2022-05-12	0
Hexstatic	22107	2022-05-12	0
Kiln	22108	2022-05-12	0
Agents of Good Roots	22109	2022-05-12	0
Lisandro Meza	22110	2022-05-12	0
Takana Zion	22111	2022-05-12	0
Cusco	22112	2022-05-12	0
Eddie Palmieri	22113	2022-05-12	0
Sensation	22114	2022-05-12	0
Erik Tronic	22115	2022-05-12	0
Cycle Sphere	22116	2022-05-12	0
Bush Babees	22117	2022-05-12	0
Lord Kitchener	22118	2022-05-12	0
Meet Me In St. Louis	22119	2022-05-12	0
3 Doors Down	22120	2022-05-12	0
The Partisans	22121	2022-05-12	0
Jess Klein	22122	2022-05-12	0
Monkeywrench	22123	2022-05-12	0
Bassboosa	22124	2022-05-12	0
David Calzado y La Charanga Habanera	22125	2022-05-12	0
Baby Elephant	22126	2022-05-12	0
Gwen McCrae	22127	2022-05-12	0
Alfredo Gutierrez	22128	2022-05-12	0
Casino Mansion	22129	2022-05-12	0
The Session	22130	2022-05-12	0
BR549	22131	2022-05-12	0
Alaska Y Los Pegamoides	22132	2022-05-12	0
Sexteto Juventud	22133	2022-05-12	0
Sparks	22134	2022-05-12	0
Dumdum Boys	22135	2022-05-12	0
Melissa Auf der Maur	22136	2022-05-12	0
Ezkimo	22137	2022-05-12	0
The Wailin' Jennys	22138	2022-05-12	0
Human Resource vs. Pitch	22139	2022-05-12	0
The Nolan Sisters	22140	2022-05-12	0
Caroline Dahl	22141	2022-05-12	0
DJ Garon	22142	2022-05-12	0
Weepers Circus	22143	2022-05-12	0
Vivian Stanshall	22144	2022-05-12	0
Adelyn	22145	2022-05-12	0
Speedy J	22146	2022-05-12	0
Eric Hughes Band	22147	2022-05-12	0
João Pedro Pais	22148	2022-05-12	0
The John Buzon Trio	22149	2022-05-12	0
Green Carnation	22150	2022-05-12	0
Muchy	22151	2022-05-12	0
Edwyn Collins	22152	2022-05-12	0
Summer At Shatter Creek	22153	2022-05-12	0
Charles Wilson	22154	2022-05-12	0
Les Ogres De Barback	22155	2022-05-12	0
Plavi orkestar	22156	2022-05-12	0
Mahlathini and the Mahotella Queens	22157	2022-05-12	0
Downsiid	22158	2022-05-12	0
Sakura	22159	2022-05-12	0
Jean Claude Ades vs. Lenny Fontana ft. Tyra	22160	2022-05-12	0
Vamp	22161	2022-05-12	0
DJ Adlib	22162	2022-05-12	0
Mike Foyle pres. Bolt	22163	2022-05-12	0
Yo Yo Mundi	22164	2022-05-12	0
Mike Mikhjian & John Caza	22165	2022-05-12	0
Led Zeppelin	22166	2022-05-12	0
Josh Pyke	22167	2022-05-12	0
Leo Sayer	22168	2022-05-12	0
The Pinker Tones	22169	2022-05-12	0
Eluveitie	22170	2022-05-12	0
Bryn Christopher	22171	2022-05-12	0
Ilya Soloviev & Poshout	22172	2022-05-12	0
Heads We Dance	22173	2022-05-12	0
Fadl Shaker	22174	2022-05-12	0
Eleven	22175	2022-05-12	0
John P. Kee	22176	2022-05-12	0
Ofra Haza	22177	2022-05-12	0
Skyscraeper	22178	2022-05-12	0
Mazarin	22179	2022-05-12	0
Skip James	22180	2022-05-12	0
Los Violadores	22181	2022-05-12	0
Hydra	22182	2022-05-12	0
9 Lazy 9	22183	2022-05-12	0
MOTH	22184	2022-05-12	0
New Barbarians	22185	2022-05-12	0
Westside Connection	22186	2022-05-12	0
MA	22187	2022-05-12	0
Wizex	22188	2022-05-12	0
Taio Cruz	22189	2022-05-12	0
Ernie K Doe	22190	2022-05-12	0
Red Giant	22191	2022-05-12	0
Stunt Rock	22192	2022-05-12	0
Nadanuf	22193	2022-05-12	0
All Natural Lemon & Lime Flavors	22194	2022-05-12	0
Myk Bee	22195	2022-05-12	0
Miguel Y Miguel	22196	2022-05-12	0
Trick Pony	22197	2022-05-12	0
Nico vs. Trance Groove	22198	2022-05-12	0
Quadran	22199	2022-05-12	0
Forgotten Alibi	22200	2022-05-12	0
Fred Van Hove	22201	2022-05-12	0
George Lewis & His New Orleans Stompers	22202	2022-05-12	0
The Berzerker	22203	2022-05-12	0
Morgan	22204	2022-05-12	0
Marcelo Castelli	22205	2022-05-12	0
Mocean Worker	22206	2022-05-12	0
North Mississippi Allstars	22207	2022-05-12	0
Joan As Police Woman	22208	2022-05-12	0
The Solar System	22209	2022-05-12	0
Leroy Anderson	22210	2022-05-12	0
Augustus Pablo	22211	2022-05-12	0
Overdrive Division	22212	2022-05-12	0
Tommy Overstreet	22213	2022-05-12	0
Top Notch	22214	2022-05-12	0
Pandora	22215	2022-05-12	0
Lynden David Hall	22216	2022-05-12	0
I-20	22217	2022-05-12	0
Country Joe & The Fish	22218	2022-05-12	0
Main	22219	2022-05-12	0
Threshold	22220	2022-05-12	0
Mariem Hassan	22221	2022-05-12	0
Nei Lopes	22222	2022-05-12	0
Bag Raiders	22223	2022-05-12	0
Sean Kingston	22224	2022-05-12	0
The Last Goodnight	22225	2022-05-12	0
Lloyd Price	22226	2022-05-12	0
Valerio Scanu	22227	2022-05-12	0
Sun Ra Arkestra	22228	2022-05-12	0
The Black Velvet Band	22229	2022-05-12	0
Cristina	22230	2022-05-12	0
Wavorly	22231	2022-05-12	0
Freddy Fader meets Locana	22232	2022-05-12	0
Dust of Basement	22233	2022-05-12	0
C-Systems	22234	2022-05-12	0
Slaï	22235	2022-05-12	0
Ischen Impossible	22236	2022-05-12	0
Commander Cody & His Lost Planet Airmen	22237	2022-05-12	0
Kissy Sell Out	22238	2022-05-12	0
Pedro Pietri	22239	2022-05-12	0
Matthias Tanzmann	22240	2022-05-12	0
The Castaway Stones	22241	2022-05-12	0
Rockettothesky	22242	2022-05-12	0
Potluck	22243	2022-05-12	0
Strange Tenants	22244	2022-05-12	0
Kim Stockwood	22245	2022-05-12	0
After The Burial	22246	2022-05-12	0
Rodrigo y Gabriela	22247	2022-05-12	0
Charlemagne Palestine	22248	2022-05-12	0
Billy Paul William	22249	2022-05-12	0
Lost Children Of Babylon	22250	2022-05-12	0
Timi Yuro	22251	2022-05-12	0
Justice Vs Simian	22252	2022-05-12	0
Mr. Shadow_ Señor Sombra	22253	2022-05-12	0
Lars Bygdén	22254	2022-05-12	0
Black Label Society	22255	2022-05-12	0
Chumbawamba	22256	2022-05-12	0
Hexlove	22257	2022-05-12	0
Leci Brandão	22258	2022-05-12	0
Issac Delgado	22259	2022-05-12	0
Miguel Morales "La Voz" & Gabriel "El Chiche" Maestre	22260	2022-05-12	0
Bakir and Dubsworth	22261	2022-05-12	0
ROBERT MIRABAL	22262	2022-05-12	0
Jenifer	22263	2022-05-12	0
Los Lunes Que Quedan	22264	2022-05-12	0
Major Matt Mason Usa	22265	2022-05-12	0
Jon Auer	22266	2022-05-12	0
Stendeck	22267	2022-05-12	0
Chico Hamilton Quintet	22268	2022-05-12	0
Patrick Saint-Eloi	22269	2022-05-12	0
Gentle Giant	22270	2022-05-12	0
Pips Chips & Videoclips	22271	2022-05-12	0
Mousse T. feat. Calvin Lynch	22272	2022-05-12	0
The Drama Strip	22273	2022-05-12	0
Reyli	22274	2022-05-12	0
Gwen Stacy	22275	2022-05-12	0
Soulja Slim_ Fiend_ Full Blooded	22276	2022-05-12	0
Drive-By Argument	22277	2022-05-12	0
Our Corpse Destroyed	22278	2022-05-12	0
Oldelaf_ Monsieur D	22279	2022-05-12	0
Autonomy_ C-Los B_ Baby CJ	22280	2022-05-12	0
Honor Society	22281	2022-05-12	0
From Dying Skies	22282	2022-05-12	0
Trilok Gurtu	22283	2022-05-12	0
El Simbolo	22284	2022-05-12	0
Ladyscraper	22285	2022-05-12	0
The Boxmasters	22286	2022-05-12	0
MTW	22287	2022-05-12	0
Eli Young Band	22288	2022-05-12	0
Fun Factory	22289	2022-05-12	0
Rasco	22290	2022-05-12	0
Arne Heger	22291	2022-05-12	0
Ernie K-Doe	22292	2022-05-12	0
Tex Williams & His Western Caravan	22293	2022-05-12	0
Mischa Daniels feat. Aisata	22294	2022-05-12	0
Fugees (Tranzlator Crew)	22295	2022-05-12	0
Messer Chups	22296	2022-05-12	0
Blind Alfred Reed	22297	2022-05-12	0
Wanessa	22298	2022-05-12	0
Three 6 Mafia feat. Boogiemane	22299	2022-05-12	0
Sanna Kurki-Suonio	22300	2022-05-12	0
Fashawn	22301	2022-05-12	0
Creedence Clearwater Revisited	22302	2022-05-12	0
Novy Svet	22303	2022-05-12	0
Flying Pop's	22304	2022-05-12	0
School Food Punishment	22305	2022-05-12	0
Juan Gotti	22306	2022-05-12	0
Murderdolls	22307	2022-05-12	0
Miss Li	22308	2022-05-12	0
Shifty	22309	2022-05-12	0
The Spongetones	22310	2022-05-12	0
Velvet Chain	22311	2022-05-12	0
Ammoncontact	22312	2022-05-12	0
Decal	22313	2022-05-12	0
Jeff Timmons	22314	2022-05-12	0
P. Hux	22315	2022-05-12	0
Svadbas	22316	2022-05-12	0
Los Compadres	22317	2022-05-12	0
Carphax Files	22318	2022-05-12	0
Detroit Social Club	22319	2022-05-12	0
Mr. V	22320	2022-05-12	0
Knapsack	22321	2022-05-12	0
Robyn Hitchcock & The Venus 3	22322	2022-05-12	0
The Mint Chicks	22323	2022-05-12	0
Raduza	22324	2022-05-12	0
Mago de Oz	22325	2022-05-12	0
Chevelle	22326	2022-05-12	0
Svinkels	22327	2022-05-12	0
Ryan Paris	22328	2022-05-12	0
Tayo meets Precision Cuts downtown	22329	2022-05-12	0
Se.Ra.Phic	22330	2022-05-12	0
LaVern Baker	22331	2022-05-12	0
Roger Hodgson	22332	2022-05-12	0
Los Tres Diamantes	22333	2022-05-12	0
Copeland	22334	2022-05-12	0
Fröbelin Palikat	22335	2022-05-12	0
Light Of The World	22336	2022-05-12	0
Steve Baltes	22337	2022-05-12	0
Ocean Colour Scene	22338	2022-05-12	0
The Awakening	22339	2022-05-12	0
Wilson Phillips	22340	2022-05-12	0
Ritchie Valens	22341	2022-05-12	0
Petula Clark	22342	2022-05-12	0
Lovsang Fra Oks	22343	2022-05-12	0
Pedro Luis e a Parede	22344	2022-05-12	0
Soul Of Man	22345	2022-05-12	0
The God Awfuls	22346	2022-05-12	0
The Templars	22347	2022-05-12	0
Molly Johnson	22348	2022-05-12	0
Manolito Simonet y su Trabuco	22349	2022-05-12	0
Scissorfight	22350	2022-05-12	0
Mac Dre	22351	2022-05-12	0
Latte E Miele	22352	2022-05-12	0
Rusko	22353	2022-05-12	0
Sacramentum	22354	2022-05-12	0
Stargarden	22355	2022-05-12	0
Blood Raw	22356	2022-05-12	0
Ten Wheel Drive	22357	2022-05-12	0
E.S.G.	22358	2022-05-12	0
Ratatat	22359	2022-05-12	0
El Farouki	22360	2022-05-12	0
G.C. Cameron	22361	2022-05-12	0
Ink & Dagger	22362	2022-05-12	0
The Mullets	22363	2022-05-12	0
Gigi	22364	2022-05-12	0
Charlie Peacock	22365	2022-05-12	0
KT Tunstall	22366	2022-05-12	0
Tuomari Nurmio	22367	2022-05-12	0
Willie Bobo & The Bo Gents	22368	2022-05-12	0
Jore Marjaranta	22369	2022-05-12	0
Fluke	22370	2022-05-12	0
Jennifer White	22371	2022-05-12	0
Sarah Borges and the Broken Singles	22372	2022-05-12	0
Caracoles_ Los	22373	2022-05-12	0
System 7	22374	2022-05-12	0
Bonded By Blood	22375	2022-05-12	0
Waterspark	22376	2022-05-12	0
Hanns Dieter Hüsch	22377	2022-05-12	0
Kirile Loo	22378	2022-05-12	0
Bumblebee Unlimited	22379	2022-05-12	0
Lumen	22380	2022-05-12	0
David Montgomery	22381	2022-05-12	0
Angélla Christie	22382	2022-05-12	0
Jon Lord With The Hoochie Coochie Men	22383	2022-05-12	0
Los Cardenales De Nuevo Leon	22384	2022-05-12	0
The Oh Sees	22385	2022-05-12	0
Secret Lives Of The Freemasons	22386	2022-05-12	0
Q-Burns Abstract Message	22387	2022-05-12	0
Lake Of Tears	22388	2022-05-12	0
Scare Dem Crew	22389	2022-05-12	0
The Chinkees	22390	2022-05-12	0
Ronan Keating	22391	2022-05-12	0
Carter Family	22392	2022-05-12	0
Count Basie Orchestra	22393	2022-05-12	0
King Creosote	22394	2022-05-12	0
Frankie Valli & The Four Seasons	22395	2022-05-12	0
Black Eyed Snakes	22396	2022-05-12	0
Keith Jarrett	22397	2022-05-12	0
Carolyn Crawford	22398	2022-05-12	0
James Ruskin	22399	2022-05-12	0
GummiHz	22400	2022-05-12	0
Bruce Robison	22401	2022-05-12	0
Non Fiktion	22402	2022-05-12	0
Junior Delgado	22403	2022-05-12	0
Geiom	22404	2022-05-12	0
Kelly Key	22405	2022-05-12	0
JDS	22406	2022-05-12	0
Clutch	22407	2022-05-12	0
Faces	22408	2022-05-12	0
Break Machine	22409	2022-05-12	0
Whoopee Makers	22410	2022-05-12	0
D1	22411	2022-05-12	0
Randy Edelman	22412	2022-05-12	0
Amber	22413	2022-05-12	0
Chris Letcher	22414	2022-05-12	0
The Panic Division	22415	2022-05-12	0
Zum	22416	2022-05-12	0
John Leyton	22417	2022-05-12	0
Rick Wilhite	22418	2022-05-12	0
Theory In Practice	22419	2022-05-12	0
Soundgarden	22420	2022-05-12	0
Robi Draco Rosa	22421	2022-05-12	0
Megadeth	22422	2022-05-12	0
Luis Eduardo Aute	22423	2022-05-12	0
Alessandro Safina	22424	2022-05-12	0
Claudio Baglioni	22425	2022-05-12	0
Foreigner	22426	2022-05-12	0
Mikael Stavöstrand	22427	2022-05-12	0
The Walker Brothers	22428	2022-05-12	0
Mop	22429	2022-05-12	0
Daniel Lindeberg	22430	2022-05-12	0
Machel Montano & Xtatik	22431	2022-05-12	0
Flaminio Maphia	22432	2022-05-12	0
Men and Women of Lambussie	22433	2022-05-12	0
Impuls	22434	2022-05-12	0
Spectacular	22435	2022-05-12	0
Daniele Silvestri	22436	2022-05-12	0
As I Lay Dying	22437	2022-05-12	0
Ben E. King	22438	2022-05-12	0
Paul McCartney / Wings	22439	2022-05-12	0
Mad Bliss	22440	2022-05-12	0
Ewan McGregor / Alessandro Safina	22441	2022-05-12	0
Vanilla Ice	22442	2022-05-12	0
Tarnation	22443	2022-05-12	0
The Weather Underground	22444	2022-05-12	0
Phantom Project	22445	2022-05-12	0
Soulution	22446	2022-05-12	0
Amel Bent	22447	2022-05-12	0
To Separate The Flesh From The Bones	22448	2022-05-12	0
Liah	22449	2022-05-12	0
Operator Please	22450	2022-05-12	0
Officer Negative	22451	2022-05-12	0
Exhorder	22452	2022-05-12	0
Papa AP	22453	2022-05-12	0
Tiësto ft. Suzanne Palmer	22454	2022-05-12	0
Lets Get Out Of This Terrible Sandwich Shop	22455	2022-05-12	0
Marina Chello	22456	2022-05-12	0
Mulgrew Miller	22457	2022-05-12	0
Tygers Of Pan Tang	22458	2022-05-12	0
The Cinematics	22459	2022-05-12	0
Fred Numf	22460	2022-05-12	0
Genya Ravan	22461	2022-05-12	0
The Warlocks	22462	2022-05-12	0
Nikko Patrelakis	22463	2022-05-12	0
Ruben Studdard	22464	2022-05-12	0
Lisa Lisa & Cult Jam	22465	2022-05-12	0
Leigh Jones	22466	2022-05-12	0
The Morning Light	22467	2022-05-12	0
Legion of Parasites	22468	2022-05-12	0
The Saints	22469	2022-05-12	0
Don Griffin	22470	2022-05-12	0
Elis Regina	22471	2022-05-12	0
XLNC	22472	2022-05-12	0
The Be Bops	22473	2022-05-12	0
Blech & Brass Banda	22474	2022-05-12	0
The Monitors	22475	2022-05-12	0
ARRESTED DEVELOPMENT	22476	2022-05-12	0
Against Me	22477	2022-05-12	0
The Acacia Strain	22478	2022-05-12	0
Ping Pung	22479	2022-05-12	0
Voice of The Seven Thunders	22480	2022-05-12	0
Wayne Jarrett	22481	2022-05-12	0
Darc Mind	22482	2022-05-12	0
Chuckie	22483	2022-05-12	0
Tchiki Boum	22484	2022-05-12	0
Herbst9_ Z'ev	22485	2022-05-12	0
Billy Idol	22486	2022-05-12	0
Aram Quartet	22487	2022-05-12	0
Vito & Dewald	22488	2022-05-12	0
Morella's Forest	22489	2022-05-12	0
Mercyful Fate	22490	2022-05-12	0
Full Scale	22491	2022-05-12	0
Mungo Jerry	22492	2022-05-12	0
Sun Kil Moon	22493	2022-05-12	0
Vargo	22494	2022-05-12	0
Cliff Adams	22495	2022-05-12	0
Art Brut	22496	2022-05-12	0
Archie Shepp Quartet_ Annette Lowman	22497	2022-05-12	0
Redman / Gov Mattic / Double O. / Tame / Diezzel Don / Roz / Young Z.	22498	2022-05-12	0
Scrubb	22499	2022-05-12	0
Diego Amador	22500	2022-05-12	0
Sir Thomas Beecham/Royal Philharmonic Orchestra	22501	2022-05-12	0
Hombres G	22502	2022-05-12	0
Mario	22503	2022-05-12	0
Tom Waits	22504	2022-05-12	0
Sleeping Giant	22505	2022-05-12	0
SFDK	22506	2022-05-12	0
Fonky Family	22507	2022-05-12	0
Wiley ft. Frisco & Cookie	22508	2022-05-12	0
Desorden Público	22509	2022-05-12	0
Turnstiles	22510	2022-05-12	0
Color Me Badd	22511	2022-05-12	0
Harold B	22512	2022-05-12	0
Luther Barnes_ The Red Budd Gospel Choir	22513	2022-05-12	0
Just a Band	22514	2022-05-12	0
Eagles	22515	2022-05-12	0
Tune Brothers	22516	2022-05-12	0
Timesbold	22517	2022-05-12	0
CJ Peeton	22518	2022-05-12	0
Angelo Debarre & Moreno	22519	2022-05-12	0
Wonderwall	22520	2022-05-12	0
Roc Monee	22521	2022-05-12	0
Blank & Jones	22522	2022-05-12	0
The Hacker	22523	2022-05-12	0
Plaid	22524	2022-05-12	0
Lionel Richie / Akon	22525	2022-05-12	0
Never Again	22526	2022-05-12	0
Dzyan	22527	2022-05-12	0
Martin Gore	22528	2022-05-12	0
Pur	22529	2022-05-12	0
Miles Davis	22530	2022-05-12	0
Condemned	22531	2022-05-12	0
Michael Learns To Rock	22532	2022-05-12	0
The Dirty Projectors	22533	2022-05-12	0
Frenéticas	22534	2022-05-12	0
City Sleeps	22535	2022-05-12	0
Impious	22536	2022-05-12	0
The Mar-Keys	22537	2022-05-12	0
Iron & Wine	22538	2022-05-12	0
Londonbeat	22539	2022-05-12	0
Airwave featuring Ludovic Meyer	22540	2022-05-12	0
Karl Hendricks Trio	22541	2022-05-12	0
Jessi Malay	22542	2022-05-12	0
Arcadi Volodos	22543	2022-05-12	0
Dee Clark	22544	2022-05-12	0
Marian McPartland	22545	2022-05-12	0
The Leslie West Band	22546	2022-05-12	0
Lee Canning	22547	2022-05-12	0
Warner Williams and Jay Summerour	22548	2022-05-12	0
The Robert Cray Band	22549	2022-05-12	0
MxPx	22550	2022-05-12	0
Donna Gardier	22551	2022-05-12	0
Hot Chocolate	22552	2022-05-12	0
Brazilian Girls	22553	2022-05-12	0
Christopher O'Riley	22554	2022-05-12	0
Donna Maria	22555	2022-05-12	0
The Juan MacLean	22556	2022-05-12	0
Phil The Agony	22557	2022-05-12	0
Lisa Miskovsky	22558	2022-05-12	0
Ruth	22559	2022-05-12	0
John Cage	22560	2022-05-12	0
Bhimsen Joshi	22561	2022-05-12	0
Take 6	22562	2022-05-12	0
The Manish Boys	22563	2022-05-12	0
Urgency	22564	2022-05-12	0
Mental	22565	2022-05-12	0
Val Doonican	22566	2022-05-12	0
Nazan Öncel	22567	2022-05-12	0
Leana	22568	2022-05-12	0
Three Days Grace	22569	2022-05-12	0
Royal Treatment Plant	22570	2022-05-12	0
Ketama	22571	2022-05-12	0
rinôçérôse	22572	2022-05-12	0
Mel & Tim	22573	2022-05-12	0
The Brooklyn Tabernacle Choir	22574	2022-05-12	0
Elvenking	22575	2022-05-12	0
Vincent Gallo	22576	2022-05-12	0
Ted Nugent And The Amboy Dukes	22577	2022-05-12	0
Vern Pullens	22578	2022-05-12	0
S.T.A.G.	22579	2022-05-12	0
Jake Slazenger	22580	2022-05-12	0
Elliott Murphy	22581	2022-05-12	0
Mystery Islands	22582	2022-05-12	0
Tuff	22583	2022-05-12	0
Dick Dale and his Del-Tones	22584	2022-05-12	0
Norrisman	22585	2022-05-12	0
The Uniques	22586	2022-05-12	0
Aerolineas Federales	22587	2022-05-12	0
Convulse	22588	2022-05-12	0
Chayito Valdez	22589	2022-05-12	0
Kasabian	22590	2022-05-12	0
Hatebreed	22591	2022-05-12	0
Lone Ranger	22592	2022-05-12	0
The Chap & Hot Chip	22593	2022-05-12	0
J. Karjalainen & Mustat Lasit	22594	2022-05-12	0
Meredith Monk and Vocal Ensemble	22595	2022-05-12	0
Hot	22596	2022-05-12	0
Obliterate	22597	2022-05-12	0
Gerard Van Maasakkers	22598	2022-05-12	0
Huey 'Piano' Smith And The Clowns	22599	2022-05-12	0
Los Jaivas	22600	2022-05-12	0
Bunbury	22601	2022-05-12	0
Franco	22602	2022-05-12	0
Tracy Gang Pussy	22603	2022-05-12	0
New Radiant Storm King	22604	2022-05-12	0
Calliope	22605	2022-05-12	0
Zoegirl	22606	2022-05-12	0
Meat Loaf / JB	22607	2022-05-12	0
Rita Coolidge	22608	2022-05-12	0
Test Dept	22609	2022-05-12	0
Michael Cretu	22610	2022-05-12	0
Lank	22611	2022-05-12	0
Philly's Most Wanted	22612	2022-05-12	0
Merle Kilgore	22613	2022-05-12	0
Valija Diplomática	22614	2022-05-12	0
Eric Bibb	22615	2022-05-12	0
Tune-Yards	22616	2022-05-12	0
Summer Cats	22617	2022-05-12	0
Dashboard Confessional	22618	2022-05-12	0
Gene	22619	2022-05-12	0
Blanks77	22620	2022-05-12	0
Natalia y La Forquetina	22621	2022-05-12	0
Duke Ellington and His Famous Orchestra	22622	2022-05-12	0
Tina Arena	22623	2022-05-12	0
Butthole Surfers	22624	2022-05-12	0
Klasse Kriminale	22625	2022-05-12	0
Harald Pons	22626	2022-05-12	0
Sound Players	22627	2022-05-12	0
[re:jazz]	22628	2022-05-12	0
Ohmna	22629	2022-05-12	0
God Fires Man	22630	2022-05-12	0
Tieum	22631	2022-05-12	0
Mannequin	22632	2022-05-12	0
Buccaneer	22633	2022-05-12	0
Endanger	22634	2022-05-12	0
Third Ear Band	22635	2022-05-12	0
Urban Dance Squad	22636	2022-05-12	0
Kofi	22637	2022-05-12	0
Los Hooligans	22638	2022-05-12	0
Cristina Ortiz	22639	2022-05-12	0
Procession	22640	2022-05-12	0
A.R.E. Weapons	22641	2022-05-12	0
Björns vänner	22642	2022-05-12	0
Hari and Aino	22643	2022-05-12	0
Laura Cantrell	22644	2022-05-12	0
Dis-	22645	2022-05-12	0
United Peace Voices	22646	2022-05-12	0
Kevin Rudolf	22647	2022-05-12	0
Dakota Moon	22648	2022-05-12	0
Secondhand Jive	22649	2022-05-12	0
Kokayi	22650	2022-05-12	0
Septembre	22651	2022-05-12	0
Gila	22652	2022-05-12	0
Maga	22653	2022-05-12	0
Edú Lobo	22654	2022-05-12	0
Stephen Varcoe/Choir of King's College_ Cambridge/Sir David Willcocks	22655	2022-05-12	0
Fall Out Boy	22656	2022-05-12	0
Loft	22657	2022-05-12	0
Chief Stephen Osita Osadebe	22658	2022-05-12	0
Tania Libertad	22659	2022-05-12	0
Gordon MacRae	22660	2022-05-12	0
Soft Hearted Scientists	22661	2022-05-12	0
Urban Myth Club	22662	2022-05-12	0
Marie Fredriksson	22663	2022-05-12	0
Tarika Blue	22664	2022-05-12	0
Eternalist	22665	2022-05-12	0
Yann Perreau	22666	2022-05-12	0
Kardinal Offishall / Lindo P	22667	2022-05-12	0
Jasmine Minks	22668	2022-05-12	0
Omar And The Howlers	22669	2022-05-12	0
Extrechinato y Tu	22670	2022-05-12	0
Zahounia	22671	2022-05-12	0
Remember	22672	2022-05-12	0
Estuera	22673	2022-05-12	0
Marina Solonos	22674	2022-05-12	0
Tammy Wynette	22675	2022-05-12	0
Hasmik Harutyunyan with the Shoghaken Ensemble	22676	2022-05-12	0
Carefree (Turner)	22677	2022-05-12	0
Arcade	22678	2022-05-12	0
Painkiller Hotel	22679	2022-05-12	0
Mississippi Fred McDowell	22680	2022-05-12	0
The Bug	22681	2022-05-12	0
Juliette Gréco	22682	2022-05-12	0
Ana Caram	22683	2022-05-12	0
Pickin' On Series	22684	2022-05-12	0
Urban Knights	22685	2022-05-12	0
Franz Bauer	22686	2022-05-12	0
Vanessa-Mae	22687	2022-05-12	0
The Surf Rats	22688	2022-05-12	0
Govi	22689	2022-05-12	0
Jessie Lee Miller	22690	2022-05-12	0
Roosevelt Sykes	22691	2022-05-12	0
Gabriel Yared_Hiam Abbass	22692	2022-05-12	0
Jeanne Robertson	22693	2022-05-12	0
Uncle Dave Macon	22694	2022-05-12	0
Forteba	22695	2022-05-12	0
Mutt	22696	2022-05-12	0
Lloyd Banks	22697	2022-05-12	0
Distance & Benga	22698	2022-05-12	0
Dot Rotten	22699	2022-05-12	0
Hackneyed	22700	2022-05-12	0
Fontella Bass	22701	2022-05-12	0
Kristet Utseende	22702	2022-05-12	0
Ceephax	22703	2022-05-12	0
Gene Simmons	22704	2022-05-12	0
Delia Gonzalez & Gavin Russom	22705	2022-05-12	0
John Williams	22706	2022-05-12	0
Ice Cube feat. WC	22707	2022-05-12	0
Nathan Williams	22708	2022-05-12	0
Karramba	22709	2022-05-12	0
Emmanuelle Parrenin	22710	2022-05-12	0
Johnny Moore's Three Blazers	22711	2022-05-12	0
Nebula	22712	2022-05-12	0
Kluster	22713	2022-05-12	0
Diemonsterdie	22714	2022-05-12	0
Shake Da Mayor	22715	2022-05-12	0
Nacho Cano	22716	2022-05-12	0
Music Makers	22717	2022-05-12	0
Fenriz Red Planet	22718	2022-05-12	0
The Planets	22719	2022-05-12	0
Celeda	22720	2022-05-12	0
Bernard Fanning	22721	2022-05-12	0
Coca Carola	22722	2022-05-12	0
Futur Proche	22723	2022-05-12	0
Nic Jones	22724	2022-05-12	0
Tom & Susan Wasinger	22725	2022-05-12	0
Ensemble PAN	22726	2022-05-12	0
Yeah Yeah Yeahs	22727	2022-05-12	0
Beastie Boys	22728	2022-05-12	0
Pauline en la playa	22729	2022-05-12	0
Technikal featuring Paul Maddox	22730	2022-05-12	0
The Nat King Cole Trio	22731	2022-05-12	0
James Payne	22732	2022-05-12	0
dBridge	22733	2022-05-12	0
Hi-Fi	22734	2022-05-12	0
Leone Di Lernia	22735	2022-05-12	0
Los Pericos	22736	2022-05-12	0
Os Paralamas Do Sucesso	22737	2022-05-12	0
Coco Steel & Lovebomb	22738	2022-05-12	0
Hairy Butter	22739	2022-05-12	0
El Barrio	22740	2022-05-12	0
DKMA presents Andrastea	22741	2022-05-12	0
Bobby Watson_ Jim Hartog_ Rich Rothemberg_ Ed Jackson	22742	2022-05-12	0
Niza	22743	2022-05-12	0
Echo And The Bunnymen	22744	2022-05-12	0
Mousse T. vs. Hot'N'Juicy	22745	2022-05-12	0
Mount Kimbie	22746	2022-05-12	0
Think About Mutation	22747	2022-05-12	0
Agent Steel	22748	2022-05-12	0
Eyeless In Gaza	22749	2022-05-12	0
Madlib	22750	2022-05-12	0
Asher D & Daddy Freddy	22751	2022-05-12	0
Crookers	22752	2022-05-12	0
Kéry James	22753	2022-05-12	0
Bluebear Project	22754	2022-05-12	0
Woods	22755	2022-05-12	0
Electro Hippies	22756	2022-05-12	0
Michelle Lewis	22757	2022-05-12	0
The Honeycombs	22758	2022-05-12	0
Miss Kittin	22759	2022-05-12	0
Toña La Negra	22760	2022-05-12	0
Patrick Moraz / Syrinx	22761	2022-05-12	0
Domased	22762	2022-05-12	0
The Spectacular Fantastic	22763	2022-05-12	0
Rancid	22764	2022-05-12	0
Evanescence	22765	2022-05-12	0
Cold	22766	2022-05-12	0
Music Service	22767	2022-05-12	0
Jet Lag Gemini	22768	2022-05-12	0
Bob Gibson	22769	2022-05-12	0
Look Mexico	22770	2022-05-12	0
Ann Peebles	22771	2022-05-12	0
Mary Mary	22772	2022-05-12	0
Stalingrad Cowgirls	22773	2022-05-12	0
Jerry Lewis	22774	2022-05-12	0
James Darren	22775	2022-05-12	0
Lil Troy	22776	2022-05-12	0
Big Jack Johnson	22777	2022-05-12	0
Iso H	22778	2022-05-12	0
Gigi Leung	22779	2022-05-12	0
Abelardo Barroso	22780	2022-05-12	0
Selena Y Los Dinos	22781	2022-05-12	0
Guadalupe Pineda;Los Dandys	22782	2022-05-12	0
Jascha Heifetz	22783	2022-05-12	0
Banda Blanca	22784	2022-05-12	0
Ornette Coleman	22785	2022-05-12	0
Kate Campbell	22786	2022-05-12	0
Felix Kröcher	22787	2022-05-12	0
The Stills	22788	2022-05-12	0
Dana Gillespie	22789	2022-05-12	0
Lyle Mays	22790	2022-05-12	0
Barbara Mason	22791	2022-05-12	0
Jai Amore	22792	2022-05-12	0
Deluxe	22793	2022-05-12	0
Don Caballero	22794	2022-05-12	0
Betty Hutton	22795	2022-05-12	0
Blues Traveler	22796	2022-05-12	0
Code 64	22797	2022-05-12	0
King Missile	22798	2022-05-12	0
Shebang	22799	2022-05-12	0
Jethro Tull	22800	2022-05-12	0
Union Square	22801	2022-05-12	0
Speech Debelle	22802	2022-05-12	0
Apostle Of Hustle	22803	2022-05-12	0
Fort Knox Five featuring Mustafa Akbar	22804	2022-05-12	0
Jorge Ben Jor	22805	2022-05-12	0
Atlantic Brass Quintet	22806	2022-05-12	0
Ernestine Anderson	22807	2022-05-12	0
Avarus	22808	2022-05-12	0
Evelyne Dubourg	22809	2022-05-12	0
Canis Dirus	22810	2022-05-12	0
Age Of Love	22811	2022-05-12	0
Voyage	22812	2022-05-12	0
Black Rain	22813	2022-05-12	0
Gwen Stefani / Andre 3000	22814	2022-05-12	0
D Power	22815	2022-05-12	0
Hype	22816	2022-05-12	0
Cazals	22817	2022-05-12	0
Corde Oblique	22818	2022-05-12	0
Lifehouse	22819	2022-05-12	0
Eternal	22820	2022-05-12	0
The Family Stand	22821	2022-05-12	0
The Terrible Twos	22822	2022-05-12	0
Iam	22823	2022-05-12	0
Jovenes Clasicos Del Son	22824	2022-05-12	0
Toufic Farroukh	22825	2022-05-12	0
La Polla Records	22826	2022-05-12	0
Astrovamps	22827	2022-05-12	0
Volcano	22828	2022-05-12	0
The Phenomenal Handclap Band	22829	2022-05-12	0
Blumentopf	22830	2022-05-12	0
Longing For Dawn	22831	2022-05-12	0
F/i	22832	2022-05-12	0
Big Drill Car	22833	2022-05-12	0
House Mouse	22834	2022-05-12	0
Sean Deason	22835	2022-05-12	0
Whitey	22836	2022-05-12	0
Christel Alsos	22837	2022-05-12	0
Hectic	22838	2022-05-12	0
Brotha Lynch Hung & C.O.S.	22839	2022-05-12	0
Miriam Makeba	22840	2022-05-12	0
Monsieur Dubois	22841	2022-05-12	0
Sutekh	22842	2022-05-12	0
Kraantje Pappie feat. Abbeye en Kas-M	22843	2022-05-12	0
Otis Rush	22844	2022-05-12	0
JIMMY C. NEWMAN	22845	2022-05-12	0
Grant-Lee Phillips	22846	2022-05-12	0
Tandem	22847	2022-05-12	0
Turbostaat	22848	2022-05-12	0
Elaine Stritch_ Don Ameche_ Gene Varrone_ Rufus Smith	22849	2022-05-12	0
Modest Mouse	22850	2022-05-12	0
The Baby Einstein Music Box Orchestra	22851	2022-05-12	0
Kitty Kallen	22852	2022-05-12	0
Martin Carthy & Dave Swarbrick	22853	2022-05-12	0
Reindeer Section	22854	2022-05-12	0
Ozma	22855	2022-05-12	0
Lapsus Dei	22856	2022-05-12	0
Carsick	22857	2022-05-12	0
Zazie	22858	2022-05-12	0
Hurricane	22859	2022-05-12	0
Francesca Battistelli	22860	2022-05-12	0
Afghan Whigs	22861	2022-05-12	0
Die Laughing	22862	2022-05-12	0
Gordon / Drew	22863	2022-05-12	0
Quad Throw Salchow	22864	2022-05-12	0
Stressball	22865	2022-05-12	0
Adam Wade	22866	2022-05-12	0
On Thorns I Lay	22867	2022-05-12	0
Sopor Aeternus & The Ensemble Of Shadows	22868	2022-05-12	0
José Alfredo Jimenez Con Acompañamiento Del Mariachi Vargas De Tecalitlan	22869	2022-05-12	0
Venice Underground	22870	2022-05-12	0
Crosby_ Stills_ Nash and Young	22871	2022-05-12	0
Dark Soho	22872	2022-05-12	0
Piana	22873	2022-05-12	0
Edge Of Dawn	22874	2022-05-12	0
U&ME	22875	2022-05-12	0
Black Time	22876	2022-05-12	0
Alan Dale	22877	2022-05-12	0
Los Payos	22878	2022-05-12	0
Gülcihan Koç	22879	2022-05-12	0
Eric B. & Rakim	22880	2022-05-12	0
Pulse Legion	22881	2022-05-12	0
Tresenlesen	22882	2022-05-12	0
Evelyn Vysher	22883	2022-05-12	0
The Last Shadow Puppets	22884	2022-05-12	0
Akoya Afrobeat Ensemble	22885	2022-05-12	0
Niraj Chag Featuring Japjit Kaur	22886	2022-05-12	0
Judy Holliday;Peter Gennaro;Ensemble	22887	2022-05-12	0
Mercromina	22888	2022-05-12	0
69	22889	2022-05-12	0
Statuesque	22890	2022-05-12	0
Robbie Rivera	22891	2022-05-12	0
Randy Stonehill	22892	2022-05-12	0
Joni Mitchell	22893	2022-05-12	0
Spanky & Our Gang	22894	2022-05-12	0
Windsor For The Derby	22895	2022-05-12	0
Jeanne & The Darlings	22896	2022-05-12	0
Dolores O'Riordan	22897	2022-05-12	0
Tommy Alverson	22898	2022-05-12	0
16 Horsepower	22899	2022-05-12	0
Grazia Di Michele	22900	2022-05-12	0
Fady Ferraye	22901	2022-05-12	0
Faith No More	22902	2022-05-12	0
Bonjour Brumaire	22903	2022-05-12	0
Manuel De Paula	22904	2022-05-12	0
Indian Summer	22905	2022-05-12	0
Rio Addicts	22906	2022-05-12	0
Cham	22907	2022-05-12	0
Will Kimbrough	22908	2022-05-12	0
Will Smith Featuring Dru Hill & Kool Mo Dee	22909	2022-05-12	0
Willie Bobo	22910	2022-05-12	0
Various Artists: Karaoke - Ameritz	22911	2022-05-12	0
Kurt Carr	22912	2022-05-12	0
Small Towns Burn A Little Slower	22913	2022-05-12	0
Anthrax	22914	2022-05-12	0
Eddy Arnold	22915	2022-05-12	0
Melanie And The Secret Army	22916	2022-05-12	0
Probspot	22917	2022-05-12	0
Antibalas	22918	2022-05-12	0
Kenny Rogers & Kim Carnes	22919	2022-05-12	0
Ashford & Simpson	22920	2022-05-12	0
Charly García	22921	2022-05-12	0
Housse De Racket	22922	2022-05-12	0
WhiteSpirit	22923	2022-05-12	0
Rhonda Vincent	22924	2022-05-12	0
Worthless	22925	2022-05-12	0
Eamon	22926	2022-05-12	0
Jackalopes	22927	2022-05-12	0
Rockwell feat. Lil' Renegade	22928	2022-05-12	0
Shuttle358	22929	2022-05-12	0
Fisk Industries	22930	2022-05-12	0
Tarwater	22931	2022-05-12	0
Dirty Beatniks	22932	2022-05-12	0
Toshack Highway	22933	2022-05-12	0
Donny Osmond	22934	2022-05-12	0
The Undisputed Truth	22935	2022-05-12	0
The Rapture	22936	2022-05-12	0
Sam Brown	22937	2022-05-12	0
Manticora	22938	2022-05-12	0
The Foundry Field Recordings	22939	2022-05-12	0
Radiohead Tribute	22940	2022-05-12	0
Ill Repute	22941	2022-05-12	0
Code Blue	22942	2022-05-12	0
Keith Mansfield	22943	2022-05-12	0
Amaoh	22944	2022-05-12	0
Tuuli	22945	2022-05-12	0
AJP	22946	2022-05-12	0
Warren G (featuring Kurupt And Crucial Conflict)	22947	2022-05-12	0
The West Coast Pop Art Experimental Band	22948	2022-05-12	0
Moqui Marbles feat. Dendemann	22949	2022-05-12	0
Alex Stealthy	22950	2022-05-12	0
Kevin Ayers	22951	2022-05-12	0
Coconut Records	22952	2022-05-12	0
Tommy Castro	22953	2022-05-12	0
Pink Turns Blue	22954	2022-05-12	0
The Musicmaker	22955	2022-05-12	0
D:Ream	22956	2022-05-12	0
The Headhunters	22957	2022-05-12	0
The Cleftones	22958	2022-05-12	0
James Reipas	22959	2022-05-12	0
Nortec Collective	22960	2022-05-12	0
Bishob	22961	2022-05-12	0
Laws	22962	2022-05-12	0
Pheek	22963	2022-05-12	0
Michael Alperin	22964	2022-05-12	0
Parts & Labor	22965	2022-05-12	0
Plemo And Rampue	22966	2022-05-12	0
Barbara Fairchild	22967	2022-05-12	0
George Clinton And The P Funk Allstars	22968	2022-05-12	0
Sandy Nelson	22969	2022-05-12	0
Eleventh Dream Day	22970	2022-05-12	0
Sarah Connor	22971	2022-05-12	0
Sierra	22972	2022-05-12	0
DJ Visage	22973	2022-05-12	0
Richard Manuel	22974	2022-05-12	0
Delorean	22975	2022-05-12	0
Enos McLeod	22976	2022-05-12	0
James Kochalka Superstar	22977	2022-05-12	0
Fenix TX	22978	2022-05-12	0
Ignite	22979	2022-05-12	0
Tomas Bodin	22980	2022-05-12	0
Sclavonia	22981	2022-05-12	0
Eric Roberson	22982	2022-05-12	0
Josef Locke	22983	2022-05-12	0
Steve Miller / Lol Coxhill	22984	2022-05-12	0
Language of Flowers	22985	2022-05-12	0
The Avett Brothers	22986	2022-05-12	0
Air Formation	22987	2022-05-12	0
Atrium Carceri	22988	2022-05-12	0
Planetshakers	22989	2022-05-12	0
Nessbeal	22990	2022-05-12	0
Randy Newman	22991	2022-05-12	0
Rhythm Masters	22992	2022-05-12	0
Edge Of Sanity	22993	2022-05-12	0
The Imagined Village	22994	2022-05-12	0
Joe Diorio	22995	2022-05-12	0
Annuals	22996	2022-05-12	0
Luther Wright & The Wrongs	22997	2022-05-12	0
Fanny Grace	22998	2022-05-12	0
Midnite	22999	2022-05-12	0
Rummage	23000	2022-05-12	0
Favretto feat. Naan	23001	2022-05-12	0
Working Vibes	23002	2022-05-12	0
Boards of Canada	23003	2022-05-12	0
Cantoma	23004	2022-05-12	0
Pipedown	23005	2022-05-12	0
Boredoms	23006	2022-05-12	0
Dirty Disco Youth	23007	2022-05-12	0
Michel Polnareff	23008	2022-05-12	0
Esplendor Geométrico	23009	2022-05-12	0
Brenda K. Starr	23010	2022-05-12	0
Zyon Base	23011	2022-05-12	0
Dorothy Love Coates	23012	2022-05-12	0
Agustín Lara	23013	2022-05-12	0
Bran Van 3000	23014	2022-05-12	0
digitalexplosion	23015	2022-05-12	0
Woody Allen;Eddy Davis;Eddy Davis_ The Manhattan Minstrel;Greg Cohen	23016	2022-05-12	0
Warlock	23017	2022-05-12	0
Bob Willis	23018	2022-05-12	0
Julius La Rosa	23019	2022-05-12	0
Jean Martinon/Orchestre de Paris/Choeurs de l'Opéra National de Paris	23020	2022-05-12	0
Vampire Weekend	23021	2022-05-12	0
Souls Harbor	23022	2022-05-12	0
Sug	23023	2022-05-12	0
The White Birch	23024	2022-05-12	0
Bing Crosby & The Andrews Sisters	23025	2022-05-12	0
Vic Damone	23026	2022-05-12	0
Jets	23027	2022-05-12	0
AM	23028	2022-05-12	0
The Sunshine Underground	23029	2022-05-12	0
Damage	23030	2022-05-12	0
Taken by Cars	23031	2022-05-12	0
Graeme Revell	23032	2022-05-12	0
Adam Rickitt	23033	2022-05-12	0
Thievery Corporation	23034	2022-05-12	0
Antonio Machín	23035	2022-05-12	0
Franky Kubrick	23036	2022-05-12	0
Carol Douglas	23037	2022-05-12	0
Stacie Orrico	23038	2022-05-12	0
Jools Holland And Suggs	23039	2022-05-12	0
Ferry Tayle	23040	2022-05-12	0
Steve Morse Band	23041	2022-05-12	0
Kitchens Of Distinction	23042	2022-05-12	0
Jimmy Hughes	23043	2022-05-12	0
Peter Tosh	23044	2022-05-12	0
Massimo Di Cataldo	23045	2022-05-12	0
Alucidnation	23046	2022-05-12	0
Ammer_ Einheit_ Haage	23047	2022-05-12	0
DeSoto Rust	23048	2022-05-12	0
Steve Azar	23049	2022-05-12	0
Mike Ladd	23050	2022-05-12	0
Sathima Bea Benjamin	23051	2022-05-12	0
Pugh Rogefeldt	23052	2022-05-12	0
Bobby Vinton	23053	2022-05-12	0
Leif Ove Andsnes	23054	2022-05-12	0
Emilio	23055	2022-05-12	0
Royal Philharmonic Orchestra	23056	2022-05-12	0
Earshot	23057	2022-05-12	0
Jazztronik	23058	2022-05-12	0
Thomas Battenstein	23059	2022-05-12	0
The Breakaways	23060	2022-05-12	0
Liz Phair	23061	2022-05-12	0
Tokyo String Quartet;Peter Oundjian;Kikuei Ikeda;Kazuhide Isomura;Sadao Harada	23062	2022-05-12	0
Chris Botti (featuring Shawn Colvin)	23063	2022-05-12	0
Fania All Stars	23064	2022-05-12	0
The Capstan Shafts	23065	2022-05-12	0
Arnaldo Antunes	23066	2022-05-12	0
MZ 412	23067	2022-05-12	0
La Papa Verde	23068	2022-05-12	0
WeSurrender	23069	2022-05-12	0
BZB	23070	2022-05-12	0
Commander Cody	23071	2022-05-12	0
Abe Vigoda	23072	2022-05-12	0
John Wayne Shot Me	23073	2022-05-12	0
2tall	23074	2022-05-12	0
Sonny Terry	23075	2022-05-12	0
Arthur Yoria	23076	2022-05-12	0
Brinkman	23077	2022-05-12	0
Laurent Garnier	23078	2022-05-12	0
The White Sport	23079	2022-05-12	0
Philippe Rochard and Max B. Grant	23080	2022-05-12	0
Slim	23081	2022-05-12	0
Fear	23082	2022-05-12	0
Climax Golden Twins	23083	2022-05-12	0
Mael Mórdha	23084	2022-05-12	0
Wilt	23085	2022-05-12	0
Fred McDowell	23086	2022-05-12	0
Frankie Feliciano / Mike Dunn (Return Of The Lost Soul) In Memory Of A Friend	23087	2022-05-12	0
Rappin' 4-Tay	23088	2022-05-12	0
Machine Head	23089	2022-05-12	0
Old Jerusalem	23090	2022-05-12	0
Junior Mance	23091	2022-05-12	0
Newworldaquarium	23092	2022-05-12	0
The Plastic Ono Band	23093	2022-05-12	0
Bob Baldwin	23094	2022-05-12	0
Andrew Duke	23095	2022-05-12	0
Tube-Tech & Eric Sneo	23096	2022-05-12	0
The Moffatts	23097	2022-05-12	0
Vetiver	23098	2022-05-12	0
Masterblaster	23099	2022-05-12	0
Ohio Express	23100	2022-05-12	0
Crionics	23101	2022-05-12	0
Glen Campbell	23102	2022-05-12	0
Mau Mau	23103	2022-05-12	0
Haujobb	23104	2022-05-12	0
The Sun Ra Arkestra	23105	2022-05-12	0
Jimmy Ruffin	23106	2022-05-12	0
Mercedes Peón	23107	2022-05-12	0
House of Usher	23108	2022-05-12	0
Paul Brandt	23109	2022-05-12	0
Asphyx	23110	2022-05-12	0
Walt Mills	23111	2022-05-12	0
Radar Brothers	23112	2022-05-12	0
Reel Big Fish	23113	2022-05-12	0
Gary Lewis & The Playboys	23114	2022-05-12	0
EPMD / Das Efx	23115	2022-05-12	0
Major Lance	23116	2022-05-12	0
Kendra Shank	23117	2022-05-12	0
Aimable	23118	2022-05-12	0
The Zebras	23119	2022-05-12	0
Working For A Nuclear Free City	23120	2022-05-12	0
Justo Almario	23121	2022-05-12	0
Lunic	23122	2022-05-12	0
Jonathan Snowden_ Bryan Evans	23123	2022-05-12	0
Michael Card	23124	2022-05-12	0
Del Shannon	23125	2022-05-12	0
The Mad Capsule Markets	23126	2022-05-12	0
Caprice	23127	2022-05-12	0
Megaherz	23128	2022-05-12	0
Noam Chomsky	23129	2022-05-12	0
Aeroplane	23130	2022-05-12	0
Ariel Kill Him	23131	2022-05-12	0
Psychedelic Horseshit	23132	2022-05-12	0
Kotki Dwa	23133	2022-05-12	0
Full Flava	23134	2022-05-12	0
Regina Spektor	23135	2022-05-12	0
Terry Bozzio	23136	2022-05-12	0
Melky Sedeck	23137	2022-05-12	0
Jesus Christ Superfly	23138	2022-05-12	0
Los Turntablos	23139	2022-05-12	0
Tubeway Army / Gary Numan	23140	2022-05-12	0
Bloodkin	23141	2022-05-12	0
DAS BO feat. Mounir	23142	2022-05-12	0
Tall Firs	23143	2022-05-12	0
Deathstar	23144	2022-05-12	0
Bethany Dillon	23145	2022-05-12	0
Sorry About Dresden	23146	2022-05-12	0
Banda Lagunera	23147	2022-05-12	0
Jimi Tenor	23148	2022-05-12	0
Crossfade	23149	2022-05-12	0
To Rococo Rot	23150	2022-05-12	0
Complete Control	23151	2022-05-12	0
Bob Frank and John Murry	23152	2022-05-12	0
Two Witches	23153	2022-05-12	0
Peter Martin	23154	2022-05-12	0
Freestyle Fellowship	23155	2022-05-12	0
Kinski	23156	2022-05-12	0
Bad Habits (Red Butane & Glo Butane)	23157	2022-05-12	0
Raphael	23158	2022-05-12	0
Kapasiteettiyksikkö	23159	2022-05-12	0
Trotsky Vengaran	23160	2022-05-12	0
Comecon	23161	2022-05-12	0
Bobby Hackett_ Jack Teagarden	23162	2022-05-12	0
Gabriella	23163	2022-05-12	0
Elizabeth Mitchell	23164	2022-05-12	0
Tolchock Trio	23165	2022-05-12	0
Velocity Girl	23166	2022-05-12	0
London Philharmonic Orchestra/Kent Nagano	23167	2022-05-12	0
Don Johnson and Jeffrey Reid Baker	23168	2022-05-12	0
Bird Names	23169	2022-05-12	0
30 Seconds To Mars	23170	2022-05-12	0
Skindred	23171	2022-05-12	0
Fallou Dieng_ Le DLC	23172	2022-05-12	0
Element of Noïse	23173	2022-05-12	0
Dennis Brain/Philharmonia Orchestra/Walter Susskind	23174	2022-05-12	0
Plankeye	23175	2022-05-12	0
Argemiro Patrocinio	23176	2022-05-12	0
Mikey Dread	23177	2022-05-12	0
Lil Jon / The East Side Boyz / Pharrell Williams / Ying Yang Twins	23178	2022-05-12	0
The Kings	23179	2022-05-12	0
3X Krazy	23180	2022-05-12	0
Dean Frazer	23181	2022-05-12	0
Brainiac	23182	2022-05-12	0
Spragga Benz	23183	2022-05-12	0
Severin	23184	2022-05-12	0
Smoking Popes	23185	2022-05-12	0
Nova Nova	23186	2022-05-12	0
Emmylou Harris / Mark Knopfler	23187	2022-05-12	0
EDU K feat. Deize Tigrona	23188	2022-05-12	0
Doctors Of Madness feat. Richard 'Kid' Strange	23189	2022-05-12	0
Keisha White	23190	2022-05-12	0
Go To Berlin	23191	2022-05-12	0
Optimo	23192	2022-05-12	0
Bruce Ruffin	23193	2022-05-12	0
The Stapler	23194	2022-05-12	0
Esham	23195	2022-05-12	0
Fab 5	23196	2022-05-12	0
Khalil	23197	2022-05-12	0
Pioneers	23198	2022-05-12	0
Philadelphia Orchestra	23199	2022-05-12	0
Kanye West / Lupe Fiasco	23200	2022-05-12	0
Johnny Beast	23201	2022-05-12	0
Armando	23202	2022-05-12	0
Nox	23203	2022-05-12	0
Mick Moloney	23204	2022-05-12	0
Gary Hobbs	23205	2022-05-12	0
Albert Hammond Jr.	23206	2022-05-12	0
Hal 9000	23207	2022-05-12	0
Ninety Pound Wuss	23208	2022-05-12	0
Chris Watson	23209	2022-05-12	0
Venus Hum	23210	2022-05-12	0
Rae & Christian	23211	2022-05-12	0
Stadio	23212	2022-05-12	0
Homesick James Williamson	23213	2022-05-12	0
Nelly / Anthony Hamilton	23214	2022-05-12	0
DJ Teddy Z	23215	2022-05-12	0
Shudder To Think	23216	2022-05-12	0
Huw Williams	23217	2022-05-12	0
Steve Smith	23218	2022-05-12	0
Mulberry Lane	23219	2022-05-12	0
The Stylistics	23220	2022-05-12	0
DJ Phiene	23221	2022-05-12	0
Spahn Ranch	23222	2022-05-12	0
Che Grand	23223	2022-05-12	0
Justin Hinds And The Dominoes	23224	2022-05-12	0
1910 Fruitgum Company	23225	2022-05-12	0
Shaft	23226	2022-05-12	0
Hall & Oates	23227	2022-05-12	0
Van Hunt / Jon McLaughlin / Jason Mraz	23228	2022-05-12	0
Los Suaves	23229	2022-05-12	0
Doe Maar	23230	2022-05-12	0
Forever Einstein	23231	2022-05-12	0
Adeva	23232	2022-05-12	0
Kumikameli	23233	2022-05-12	0
Werner Müller	23234	2022-05-12	0
Azure Ray	23235	2022-05-12	0
Gwen Verdon	23236	2022-05-12	0
Slowpain	23237	2022-05-12	0
Abrar Ul Haq	23238	2022-05-12	0
Gang Of Four	23239	2022-05-12	0
Throttlerod	23240	2022-05-12	0
The Great Redneck Hope	23241	2022-05-12	0
Pomegranate	23242	2022-05-12	0
Stateless	23243	2022-05-12	0
The Commodores	23244	2022-05-12	0
As The Sun Sets	23245	2022-05-12	0
5UU'S	23246	2022-05-12	0
Fabio Concato	23247	2022-05-12	0
Studio Apartment feat. Yasmeen Sulieman	23248	2022-05-12	0
Kolmas Nainen	23249	2022-05-12	0
Rayvon / Shaggy / Ricardo "RikRok" Ducent / Brian & Tony Gold	23250	2022-05-12	0
Donna Fargo	23251	2022-05-12	0
Omid	23252	2022-05-12	0
The Pastels	23253	2022-05-12	0
National Lampoon Comedians	23254	2022-05-12	0
Azymuth featuring Vanessa Freeman	23255	2022-05-12	0
Julien Lourau	23256	2022-05-12	0
Courtney Love	23257	2022-05-12	0
Birdman / All Star / Yo Gotti	23258	2022-05-12	0
The Jon Spencer Blues Explosion	23259	2022-05-12	0
Lisa Lynne and Georege Tortorelli	23260	2022-05-12	0
Lola Beltrán	23261	2022-05-12	0
Julien Jabre	23262	2022-05-12	0
Ali	23263	2022-05-12	0
Doyle Dykes	23264	2022-05-12	0
Shannon	23265	2022-05-12	0
Freddie Cruger Aka Red Astaire	23266	2022-05-12	0
The Sight Below	23267	2022-05-12	0
Russell Watson / Royal Philharmonic Orchestra / John Lubbock	23268	2022-05-12	0
Skunkhour	23269	2022-05-12	0
Josélito	23270	2022-05-12	0
Up Up Down Down Left Right Left Right B A Start	23271	2022-05-12	0
Michael Jackson	23272	2022-05-12	0
Rob Sonic	23273	2022-05-12	0
Shy Child	23274	2022-05-12	0
Joy Salinas	23275	2022-05-12	0
CFCF	23276	2022-05-12	0
Phil Manzanera	23277	2022-05-12	0
Los Titanes	23278	2022-05-12	0
Double Effect	23279	2022-05-12	0
Mark Ashley	23280	2022-05-12	0
Werner Müller / RIAS Tanzorchester	23281	2022-05-12	0
Aaron Watson	23282	2022-05-12	0
Little Boots	23283	2022-05-12	0
Country Teasers	23284	2022-05-12	0
Hi-Standard	23285	2022-05-12	0
67 Special	23286	2022-05-12	0
Black Widow	23287	2022-05-12	0
The Seldom Scene	23288	2022-05-12	0
Freddie Bruno	23289	2022-05-12	0
Chris Brashear	23290	2022-05-12	0
Rank 1	23291	2022-05-12	0
Soundhacker	23292	2022-05-12	0
Colbie Caillat	23293	2022-05-12	0
Kaleth Morales & Juank Ricardo	23294	2022-05-12	0
Mabulu	23295	2022-05-12	0
Milk Inc	23296	2022-05-12	0
The Nashville Teens	23297	2022-05-12	0
Voyager	23298	2022-05-12	0
Parenthetical Girls	23299	2022-05-12	0
Link Wray	23300	2022-05-12	0
Jeanie Tracy	23301	2022-05-12	0
The Boy Least Likely To	23302	2022-05-12	0
Big B	23303	2022-05-12	0
Reverie	23304	2022-05-12	0
Slick Shoes	23305	2022-05-12	0
Sunnyland Slim	23306	2022-05-12	0
Meg & Dia	23307	2022-05-12	0
Rumors	23308	2022-05-12	0
Gorky's Zygotic Mynci	23309	2022-05-12	0
Crack Village	23310	2022-05-12	0
Ulan Bator	23311	2022-05-12	0
Mindy Carson	23312	2022-05-12	0
Electrosoul System	23313	2022-05-12	0
Glenn Jones	23314	2022-05-12	0
Khan / Steve Hillage / Dave Stewart	23315	2022-05-12	0
Willie "Big Eyes" Smith	23316	2022-05-12	0
FRONT	23317	2022-05-12	0
The Reverend Peyton's Big Damn Band	23318	2022-05-12	0
Mike EFEX	23319	2022-05-12	0
Luis Fonsi	23320	2022-05-12	0
Decorate.Decorate	23321	2022-05-12	0
George Balanchine's The Nutcracker	23322	2022-05-12	0
Doug Martsch	23323	2022-05-12	0
Andrew Vasquez	23324	2022-05-12	0
Glass Candy	23325	2022-05-12	0
Mississippi Sheiks	23326	2022-05-12	0
Miranda Lambert	23327	2022-05-12	0
Son House	23328	2022-05-12	0
Diamond Head	23329	2022-05-12	0
Hannah	23330	2022-05-12	0
Brother Cane	23331	2022-05-12	0
Nerina Pallot	23332	2022-05-12	0
Crowded House	23333	2022-05-12	0
Antonio Infantino e i Tarantolati di Tricarico	23334	2022-05-12	0
Severin Blazer	23335	2022-05-12	0
Millie Quezada	23336	2022-05-12	0
Groove Factor	23337	2022-05-12	0
Luciano Pizzella	23338	2022-05-12	0
Blue Ribbon	23339	2022-05-12	0
Frankie Knuckles Presents Satoshi Tomiie	23340	2022-05-12	0
Flaco Jiménez	23341	2022-05-12	0
The Real Estate Agents	23342	2022-05-12	0
Janie Frickie	23343	2022-05-12	0
Serge Lama	23344	2022-05-12	0
Omara Portuondo - Chucho Valdés	23345	2022-05-12	0
Symphorce	23346	2022-05-12	0
Atta	23347	2022-05-12	0
Yes Giantess	23348	2022-05-12	0
Reda Taliani	23349	2022-05-12	0
King Cobb Steelie	23350	2022-05-12	0
The Ragga Twins	23351	2022-05-12	0
Bukue One	23352	2022-05-12	0
The Goldstars	23353	2022-05-12	0
Cross Canadian Ragweed	23354	2022-05-12	0
Sleepy LaBeef	23355	2022-05-12	0
Jean-Luc Ponty	23356	2022-05-12	0
Montt Mardie	23357	2022-05-12	0
E.T.A.	23358	2022-05-12	0
The Panic Channel	23359	2022-05-12	0
Joseph Lamb	23360	2022-05-12	0
Kleenex Girl Wonder	23361	2022-05-12	0
Akira Kiteshi	23362	2022-05-12	0
Daler Mehndi	23363	2022-05-12	0
Martha Raye	23364	2022-05-12	0
089 Clique feat. Mystik Entertainment	23365	2022-05-12	0
Ninja	23366	2022-05-12	0
Dennis Ferrer feat. Mia Tuttavilla	23367	2022-05-12	0
John Gary	23368	2022-05-12	0
Kathy Brown_ White Knights	23369	2022-05-12	0
Stereo Action Unlimited	23370	2022-05-12	0
Mario DaSilva	23371	2022-05-12	0
Devlin	23372	2022-05-12	0
Emmanuel Jal	23373	2022-05-12	0
Stage Dolls	23374	2022-05-12	0
Rodolphe Burger	23375	2022-05-12	0
Souad Massi	23376	2022-05-12	0
Tanya Morgan	23377	2022-05-12	0
Daniel Barenboim	23378	2022-05-12	0
Théophil	23379	2022-05-12	0
Harry Diboula	23380	2022-05-12	0
Spider Loc / 50 Cent / Lloyd Banks	23381	2022-05-12	0
MU330	23382	2022-05-12	0
Sandy Lam	23383	2022-05-12	0
Art Tatum	23384	2022-05-12	0
El Niño Gusano	23385	2022-05-12	0
Diomedes Diaz;Ivan Zuleta	23386	2022-05-12	0
Elmo Williams & Hezekiah Early	23387	2022-05-12	0
Recondita Stirpe	23388	2022-05-12	0
Candiria	23389	2022-05-12	0
Chrome Cranks	23390	2022-05-12	0
Weather Report	23391	2022-05-12	0
C-Block	23392	2022-05-12	0
Space Ritual	23393	2022-05-12	0
ALL SHALL PERISH	23394	2022-05-12	0
New Era	23395	2022-05-12	0
Eve	23396	2022-05-12	0
The Hoosiers	23397	2022-05-12	0
Spencer Parker	23398	2022-05-12	0
Wim Soutaer	23399	2022-05-12	0
Marla Glen	23400	2022-05-12	0
Greg Brown	23401	2022-05-12	0
Gerry Rafferty	23402	2022-05-12	0
Nas	23403	2022-05-12	0
Yuksek / Amanda Blank	23404	2022-05-12	0
The Shore	23405	2022-05-12	0
Lisa McClendon	23406	2022-05-12	0
Mr. Pit	23407	2022-05-12	0
Babbletron	23408	2022-05-12	0
J. Velloso	23409	2022-05-12	0
The Psychedelic Furs	23410	2022-05-12	0
Eric Clapton	23411	2022-05-12	0
Chaka Khan_ Rufus	23412	2022-05-12	0
Mike Dillon's Go-Go Jungle	23413	2022-05-12	0
Ironik	23414	2022-05-12	0
Jay-Z	23415	2022-05-12	0
Lord Tanamo	23416	2022-05-12	0
The Transmissionary Six	23417	2022-05-12	0
Billy Ocean	23418	2022-05-12	0
Ferlin Husky	23419	2022-05-12	0
Astrid Swan	23420	2022-05-12	0
Chick Corea Elektric Band	23421	2022-05-12	0
Rio Grande	23422	2022-05-12	0
Vulgaires Machins	23423	2022-05-12	0
Generic	23424	2022-05-12	0
Renzo Arbore	23425	2022-05-12	0
Sidney Polak	23426	2022-05-12	0
Whateverland	23427	2022-05-12	0
Bob Rivers	23428	2022-05-12	0
Frank Raven	23429	2022-05-12	0
Moonbabies	23430	2022-05-12	0
AZ	23431	2022-05-12	0
Cyantific	23432	2022-05-12	0
Souls Of Mischief	23433	2022-05-12	0
Alison Brown	23434	2022-05-12	0
Lucien Foort	23435	2022-05-12	0
Sanne Wallis de Vries	23436	2022-05-12	0
Juvenile	23437	2022-05-12	0
Harrison Kennedy	23438	2022-05-12	0
Lowell Fulson	23439	2022-05-12	0
Sam Baker	23440	2022-05-12	0
Mike Jones	23441	2022-05-12	0
Patrick Watson	23442	2022-05-12	0
Pride	23443	2022-05-12	0
Los Razos	23444	2022-05-12	0
Fanzine	23445	2022-05-12	0
Damian "Jr. Gong" Marley	23446	2022-05-12	0
Natural Rhythm	23447	2022-05-12	0
Richard Bartz	23448	2022-05-12	0
Afrilounge & Der Thal	23449	2022-05-12	0
Guttermouth	23450	2022-05-12	0
Adolescents	23451	2022-05-12	0
Ramsey Lewis Trio	23452	2022-05-12	0
The Gossip	23453	2022-05-12	0
Inked In Blood	23454	2022-05-12	0
Medina Azahara	23455	2022-05-12	0
Michael J.	23456	2022-05-12	0
Foxy	23457	2022-05-12	0
Tom Zé	23458	2022-05-12	0
Thumper	23459	2022-05-12	0
Jet Set Productions	23460	2022-05-12	0
D.C. 2000	23461	2022-05-12	0
Ciccone Youth	23462	2022-05-12	0
Fjk	23463	2022-05-12	0
Alberto Plaza	23464	2022-05-12	0
Keyshia Cole / Too Short	23465	2022-05-12	0
Discharge	23466	2022-05-12	0
Laura Watling	23467	2022-05-12	0
Branford Marsalis Quartet	23468	2022-05-12	0
Arthur " Big Boy"crudup	23469	2022-05-12	0
Oingo Boingo	23470	2022-05-12	0
Willie Mitchell	23471	2022-05-12	0
Junior Senior	23472	2022-05-12	0
Herbert Von Karajan	23473	2022-05-12	0
Jacqueline Taïeb	23474	2022-05-12	0
Bucks Fizz	23475	2022-05-12	0
Hypertrophy	23476	2022-05-12	0
Harry Lauder	23477	2022-05-12	0
DJ Boogie	23478	2022-05-12	0
Azymuth	23479	2022-05-12	0
Rose Elinor Dougall	23480	2022-05-12	0
Ziggi	23481	2022-05-12	0
J.B. Hutto And His Hawks	23482	2022-05-12	0
Pastora Soler	23483	2022-05-12	0
U-Melt	23484	2022-05-12	0
The Von Bondies	23485	2022-05-12	0
Crystal Waters	23486	2022-05-12	0
Scott Weiland	23487	2022-05-12	0
Apsci	23488	2022-05-12	0
Philip Glass	23489	2022-05-12	0
Alexis Strum	23490	2022-05-12	0
DJ Krush & Toshinori Kondo	23491	2022-05-12	0
Nhocuné Soul	23492	2022-05-12	0
Marc Ribot	23493	2022-05-12	0
Fuenf Freunde	23494	2022-05-12	0
Faith Hill	23495	2022-05-12	0
Goldfish & der Dulz	23496	2022-05-12	0
Lenny Breau	23497	2022-05-12	0
Ray Vega	23498	2022-05-12	0
Dan The Automator	23499	2022-05-12	0
Ángeles del Infierno	23500	2022-05-12	0
Kaada	23501	2022-05-12	0
Elliot Goldenthal	23502	2022-05-12	0
Johnny Hartman	23503	2022-05-12	0
M.C. A.D.E.	23504	2022-05-12	0
Charlotte Martin	23505	2022-05-12	0
D:Fuse & Hiratzka	23506	2022-05-12	0
Monoman	23507	2022-05-12	0
Marvin Sease	23508	2022-05-12	0
Inspector 9	23509	2022-05-12	0
Heavy-Current	23510	2022-05-12	0
Mg	23511	2022-05-12	0
Lighnin' Hopkins	23512	2022-05-12	0
This Providence	23513	2022-05-12	0
Hecate Enthroned	23514	2022-05-12	0
Moimir Papalescu & The Nihilists	23515	2022-05-12	0
D.O.A.	23516	2022-05-12	0
Klaus Schulze & Lisa Gerrard	23517	2022-05-12	0
Lauren Wood	23518	2022-05-12	0
Black Fras	23519	2022-05-12	0
Young Dubliners	23520	2022-05-12	0
G.G. Allin & Antiseen	23521	2022-05-12	0
Primal Plant	23522	2022-05-12	0
Takehisa Kosugi	23523	2022-05-12	0
Bennie Moten's Kansas City Orchestra	23524	2022-05-12	0
Ted Leo/Pharmacists	23525	2022-05-12	0
The Mills Brothers	23526	2022-05-12	0
Three 'N One	23527	2022-05-12	0
Blind Boy Fuller	23528	2022-05-12	0
Denim	23529	2022-05-12	0
Lissat & Voltaxx	23530	2022-05-12	0
The High Dials	23531	2022-05-12	0
Le Volume Courbe	23532	2022-05-12	0
David E. Sugar	23533	2022-05-12	0
Hayes Carll	23534	2022-05-12	0
Axe Riverboy	23535	2022-05-12	0
Peter_ Paul & Mary	23536	2022-05-12	0
Shanice	23537	2022-05-12	0
Silvertide	23538	2022-05-12	0
Michael Gettel	23539	2022-05-12	0
2Pac	23540	2022-05-12	0
Andrzej Piaseczny	23541	2022-05-12	0
Perry Como;Betty Hutton	23542	2022-05-12	0
Beady Belle	23543	2022-05-12	0
Dj Enemy	23544	2022-05-12	0
Curandero	23545	2022-05-12	0
113	23546	2022-05-12	0
Crispy Ambulance	23547	2022-05-12	0
Chirie Vegas	23548	2022-05-12	0
Ricchi E Poveri	23549	2022-05-12	0
Eddie Murphy	23550	2022-05-12	0
Motion Man feat. Kut Masta kurt	23551	2022-05-12	0
The 20 Belows	23552	2022-05-12	0
Shur-I-Kan	23553	2022-05-12	0
Red Stick Ramblers	23554	2022-05-12	0
Emiliana Torrini	23555	2022-05-12	0
Joe Lopez	23556	2022-05-12	0
Moodymann	23557	2022-05-12	0
Janis Joplin	23558	2022-05-12	0
Upsurt	23559	2022-05-12	0
Trevor Rabin	23560	2022-05-12	0
Sanne Salomonsen	23561	2022-05-12	0
Mike Ness	23562	2022-05-12	0
Frederick Rousseau	23563	2022-05-12	0
Bo Bice	23564	2022-05-12	0
Riveryman	23565	2022-05-12	0
The Directors	23566	2022-05-12	0
Small Jackets	23567	2022-05-12	0
Canvas Solaris	23568	2022-05-12	0
Kristin Diable	23569	2022-05-12	0
Hi-5	23570	2022-05-12	0
KTU	23571	2022-05-12	0
Then Jerico	23572	2022-05-12	0
Jay Randall	23573	2022-05-12	0
Brigadier Jerry	23574	2022-05-12	0
East West	23575	2022-05-12	0
Buddy Guy & Junior Wells	23576	2022-05-12	0
Reveille	23577	2022-05-12	0
Tamba Trio	23578	2022-05-12	0
Wormwood	23579	2022-05-12	0
Radar Bros.	23580	2022-05-12	0
Strap-Onz	23581	2022-05-12	0
Tom Browne	23582	2022-05-12	0
Trent Summar And The New Row Mob	23583	2022-05-12	0
Elias Viljanen	23584	2022-05-12	0
Behind The Groove	23585	2022-05-12	0
Rob Tognoni	23586	2022-05-12	0
Vince Guaraldi	23587	2022-05-12	0
Mary Hopkin	23588	2022-05-12	0
Systema	23589	2022-05-12	0
Bardo Pond	23590	2022-05-12	0
Linda Bengtzing	23591	2022-05-12	0
Rebekah	23592	2022-05-12	0
Unearth	23593	2022-05-12	0
Palm	23594	2022-05-12	0
Julie Zenatti	23595	2022-05-12	0
Paolo Nutini	23596	2022-05-12	0
Angels Of Light & Akron/Family	23597	2022-05-12	0
Marc Moulin	23598	2022-05-12	0
Rico Soarez	23599	2022-05-12	0
Cuff the Duke	23600	2022-05-12	0
Cult 45	23601	2022-05-12	0
Mac Wiseman	23602	2022-05-12	0
Anita Lipnicka I John Porter	23603	2022-05-12	0
Scanners	23604	2022-05-12	0
Boubacar Traoré	23605	2022-05-12	0
The Golden Age	23606	2022-05-12	0
Bill Doggett	23607	2022-05-12	0
The Dust Brothers	23608	2022-05-12	0
Alpha	23609	2022-05-12	0
DJ Krush	23610	2022-05-12	0
Violent work of art	23611	2022-05-12	0
J.B. Ritchie	23612	2022-05-12	0
Ihsahn	23613	2022-05-12	0
Fanfare Ciocarlia	23614	2022-05-12	0
Ohrbooten	23615	2022-05-12	0
Giannis Aggelakas	23616	2022-05-12	0
Mogwai	23617	2022-05-12	0
The Dancing Did	23618	2022-05-12	0
dmt	23619	2022-05-12	0
The Staple Singers	23620	2022-05-12	0
The Mavericks	23621	2022-05-12	0
Nusrat Fateh Ali Khan & Party	23622	2022-05-12	0
The Funky Groove Connection	23623	2022-05-12	0
Jeanette	23624	2022-05-12	0
Dawkins & Dawkins	23625	2022-05-12	0
PreEmptive Strike 0.1	23626	2022-05-12	0
Shurwayne Winchester	23627	2022-05-12	0
BRiGHT	23628	2022-05-12	0
Spocks Beard	23629	2022-05-12	0
Cristina Donà	23630	2022-05-12	0
Wax Tailor	23631	2022-05-12	0
Jerry Rivera	23632	2022-05-12	0
Jimmie Rodgers	23633	2022-05-12	0
Headhunter	23634	2022-05-12	0
Michael Rother	23635	2022-05-12	0
Yahel & Riko	23636	2022-05-12	0
Syrinx 2600	23637	2022-05-12	0
Jihad	23638	2022-05-12	0
System of a Down	23639	2022-05-12	0
Company B	23640	2022-05-12	0
MJG featuring Yung D	23641	2022-05-12	0
Christina Rosenvinge	23642	2022-05-12	0
Frl.Menke	23643	2022-05-12	0
La Makina	23644	2022-05-12	0
Nick Oliveri of Queens of the Stone Age presents Mondo Generator	23645	2022-05-12	0
Eric Von Schmidt	23646	2022-05-12	0
Phil Weeks	23647	2022-05-12	0
Eddie Kendricks	23648	2022-05-12	0
Chronicle	23649	2022-05-12	0
Wanda Jackson	23650	2022-05-12	0
Kate Ceberano	23651	2022-05-12	0
Jordan Chan	23652	2022-05-12	0
UNKLE Featuring Black Mountain	23653	2022-05-12	0
Le Rat Luciano;Les X	23654	2022-05-12	0
Soul II Soul Featuring Caron Wheeler	23655	2022-05-12	0
J.Rawls	23656	2022-05-12	0
D-Sisive	23657	2022-05-12	0
Jim Dandy's Black Oak_ Arkansas	23658	2022-05-12	0
Lange	23659	2022-05-12	0
Buzz Aldrin	23660	2022-05-12	0
Artie Shaw & His Orchestra (Vocal: Billie Holiday)	23661	2022-05-12	0
Mr. Fingers	23662	2022-05-12	0
Mundstuhl	23663	2022-05-12	0
Boom Bip	23664	2022-05-12	0
Nick Lowe_ Rockpile	23665	2022-05-12	0
The Tractors	23666	2022-05-12	0
Mynt Featuring Kim Sozzi	23667	2022-05-12	0
Axel Rudi Pell	23668	2022-05-12	0
Brian & Tony Gold	23669	2022-05-12	0
Floor Thirteen	23670	2022-05-12	0
The Flower Kings	23671	2022-05-12	0
Lumidee	23672	2022-05-12	0
RyanDan	23673	2022-05-12	0
T.Love	23674	2022-05-12	0
Autechre	23675	2022-05-12	0
Articles Of Faith	23676	2022-05-12	0
Von Spar	23677	2022-05-12	0
Mandrill	23678	2022-05-12	0
Robert Hazard	23679	2022-05-12	0
Bonnie Raitt	23680	2022-05-12	0
Fletcher Henderson	23681	2022-05-12	0
The Blaenaon Male Voice Choir	23682	2022-05-12	0
Arbon	23683	2022-05-12	0
Shiri Maimon	23684	2022-05-12	0
Imagination	23685	2022-05-12	0
Milk 'n' Cookies	23686	2022-05-12	0
Marva Whitney	23687	2022-05-12	0
Shad	23688	2022-05-12	0
Revive	23689	2022-05-12	0
D-Flame	23690	2022-05-12	0
Manudub Soundsystem	23691	2022-05-12	0
Dark Angel / Untold	23692	2022-05-12	0
Jessy J	23693	2022-05-12	0
Stellastarr*	23694	2022-05-12	0
Franz Josef Degenhardt	23695	2022-05-12	0
John Ralston	23696	2022-05-12	0
Nico Wayne Toussaint	23697	2022-05-12	0
Atari Teenage Riot	23698	2022-05-12	0
Johnny Cash;June Carter Cash	23699	2022-05-12	0
Nysay	23700	2022-05-12	0
Thornley	23701	2022-05-12	0
Hey Hey My My	23702	2022-05-12	0
Michelle & Vickie	23703	2022-05-12	0
Hurricane Bells	23704	2022-05-12	0
Ticon	23705	2022-05-12	0
TAKARU	23706	2022-05-12	0
Apache Indian	23707	2022-05-12	0
Jimmy Wayne	23708	2022-05-12	0
Kutt Calhoun; Tech N9ne	23709	2022-05-12	0
Jacek Kochan	23710	2022-05-12	0
Point Line Plane	23711	2022-05-12	0
The Revolutionary Hydra	23712	2022-05-12	0
Opeth	23713	2022-05-12	0
Nazareth	23714	2022-05-12	0
Peter & The Test Tube Babies	23715	2022-05-12	0
Burning Sky	23716	2022-05-12	0
Afrika Bambaataa and Family	23717	2022-05-12	0
The Monas	23718	2022-05-12	0
Bulutsuzluk Özlemi	23719	2022-05-12	0
Fler & Muhabbet	23720	2022-05-12	0
Oxymoron	23721	2022-05-12	0
Raz Dwa Trzy	23722	2022-05-12	0
Al Di Meola	23723	2022-05-12	0
Thomas Anders	23724	2022-05-12	0
Nothing Painted Blue	23725	2022-05-12	0
Blümchen Blau	23726	2022-05-12	0
Exciter	23727	2022-05-12	0
D.A.R	23728	2022-05-12	0
Devotos	23729	2022-05-12	0
Nelly / St. Lunatics	23730	2022-05-12	0
Loves Ugly Children	23731	2022-05-12	0
José Cepero	23732	2022-05-12	0
Fastway	23733	2022-05-12	0
Baby Bash	23734	2022-05-12	0
Magica	23735	2022-05-12	0
Lucky Thompson	23736	2022-05-12	0
Wesley Willis	23737	2022-05-12	0
Kathy Brown	23738	2022-05-12	0
Machine	23739	2022-05-12	0
Confidence	23740	2022-05-12	0
54 Nude Honeys	23741	2022-05-12	0
RAHA	23742	2022-05-12	0
Stephen Schwartz	23743	2022-05-12	0
Headcrash	23744	2022-05-12	0
RSD	23745	2022-05-12	0
Callenish Circle	23746	2022-05-12	0
Bob Margolin	23747	2022-05-12	0
The Cat's Miaow	23748	2022-05-12	0
Busta Rhymes / Swizz Beatz	23749	2022-05-12	0
Disco Freaks	23750	2022-05-12	0
V/A Music Of Life	23751	2022-05-12	0
Herbert Grönemeyer	23752	2022-05-12	0
Space Streakings	23753	2022-05-12	0
Moony	23754	2022-05-12	0
Hoyt Axton	23755	2022-05-12	0
The Red Clay Ramblers	23756	2022-05-12	0
The Three Tenors	23757	2022-05-12	0
Holiday Symphony & Choir	23758	2022-05-12	0
LITTLE TEXAS	23759	2022-05-12	0
Stiv Bators	23760	2022-05-12	0
Little Willie John	23761	2022-05-12	0
Year Long Disaster	23762	2022-05-12	0
Brian McKnight / Nelly	23763	2022-05-12	0
Stockard Channing	23764	2022-05-12	0
El Pino and the Volunteers_ El Pino & the Volunteers	23765	2022-05-12	0
TV Ghost	23766	2022-05-12	0
Matt Redman	23767	2022-05-12	0
Ana María Martínez - Ignacio Rodes	23768	2022-05-12	0
The Mendoza Line	23769	2022-05-12	0
Glad	23770	2022-05-12	0
Bulb	23771	2022-05-12	0
Medlz	23772	2022-05-12	0
Manuellsen Feat. Inessa	23773	2022-05-12	0
Anathema	23774	2022-05-12	0
Jaguares	23775	2022-05-12	0
Brad Paisley	23776	2022-05-12	0
Elliott Smith	23777	2022-05-12	0
Stonebridge	23778	2022-05-12	0
George Thorogood & The Destroyers	23779	2022-05-12	0
Tyree	23780	2022-05-12	0
Mad Dog Loose	23781	2022-05-12	0
Mel Blanc	23782	2022-05-12	0
The Tannahill Weavers	23783	2022-05-12	0
Jezebel	23784	2022-05-12	0
Muddy Waters;Johnny Winter;James Cotton	23785	2022-05-12	0
Modaji	23786	2022-05-12	0
Black Crowes_ The	23787	2022-05-12	0
Rebeca Jimenez	23788	2022-05-12	0
Abe Duque	23789	2022-05-12	0
Phantom Planet	23790	2022-05-12	0
Georges Delerue	23791	2022-05-12	0
Microdizko	23792	2022-05-12	0
Brave Saint Saturn	23793	2022-05-12	0
Lenzman	23794	2022-05-12	0
Charles Brown	23795	2022-05-12	0
Roy Montgomery	23796	2022-05-12	0
Nicole Willis / The Soul Investigators	23797	2022-05-12	0
Nous Non Plus	23798	2022-05-12	0
Cupid	23799	2022-05-12	0
Today Forever	23800	2022-05-12	0
Del Amitri	23801	2022-05-12	0
Envelopes	23802	2022-05-12	0
We Shot the Moon	23803	2022-05-12	0
The Steep Canyon Rangers	23804	2022-05-12	0
Nonpoint	23805	2022-05-12	0
Shurman	23806	2022-05-12	0
The Last Poets	23807	2022-05-12	0
Kelis	23808	2022-05-12	0
Maria Lawson	23809	2022-05-12	0
N-Dubz / Mr Hudson	23810	2022-05-12	0
Delerium	23811	2022-05-12	0
Fous De La Mer	23812	2022-05-12	0
Pistol	23813	2022-05-12	0
Voo Doo Phunk	23814	2022-05-12	0
Middle Distance Runner	23815	2022-05-12	0
Sugarland	23816	2022-05-12	0
Disaster Strikes	23817	2022-05-12	0
Taya wooden	23818	2022-05-12	0
Candy Bars	23819	2022-05-12	0
Evacuate	23820	2022-05-12	0
Smokie	23821	2022-05-12	0
T-Spoon	23822	2022-05-12	0
Mel Waiters	23823	2022-05-12	0
Velvet	23824	2022-05-12	0
DJ Dizzy	23825	2022-05-12	0
Jean Michel Jarre	23826	2022-05-12	0
Jim Jones_ Max B_ NOE	23827	2022-05-12	0
Bain Mattox	23828	2022-05-12	0
The Dead C.	23829	2022-05-12	0
Moose	23830	2022-05-12	0
Deep Enough To Die	23831	2022-05-12	0
Old Town School of Folk Music	23832	2022-05-12	0
Toxic Field Mice	23833	2022-05-12	0
Patrik Isaksson	23834	2022-05-12	0
Big Mama Thornton	23835	2022-05-12	0
Zakopower	23836	2022-05-12	0
Mentors	23837	2022-05-12	0
Hank Williams Jr.	23838	2022-05-12	0
Leonard Kwan	23839	2022-05-12	0
Joe Brown And The Bruvvers	23840	2022-05-12	0
Fine China	23841	2022-05-12	0
Ice Mc	23842	2022-05-12	0
Sick Of It All	23843	2022-05-12	0
Flower Travellin' Band	23844	2022-05-12	0
R'n'b	23845	2022-05-12	0
Dolorean	23846	2022-05-12	0
Joss Stone	23847	2022-05-12	0
Nite Jewel	23848	2022-05-12	0
Jigsaw	23849	2022-05-12	0
New Kidz	23850	2022-05-12	0
Roots of Rebellion	23851	2022-05-12	0
Aziz Mian	23852	2022-05-12	0
Econoline Crush	23853	2022-05-12	0
Raekwon	23854	2022-05-12	0
Sly & Robbie / Amp Fiddler	23855	2022-05-12	0
love like blood	23856	2022-05-12	0
Billy Eckstine	23857	2022-05-12	0
Late	23858	2022-05-12	0
Frankie Ford	23859	2022-05-12	0
Chieli Minucci & Special EFX	23860	2022-05-12	0
Hocus Pocus	23861	2022-05-12	0
The Simpletons	23862	2022-05-12	0
Alibi	23863	2022-05-12	0
Juan Carlos Baglietto	23864	2022-05-12	0
Kol Simcha	23865	2022-05-12	0
Raze	23866	2022-05-12	0
Daryl Hall	23867	2022-05-12	0
David Navarro	23868	2022-05-12	0
IYOV	23869	2022-05-12	0
Mars Ill	23870	2022-05-12	0
Kaloyan Ivanoff	23871	2022-05-12	0
LOFOFORA	23872	2022-05-12	0
The Magic Numbers	23873	2022-05-12	0
GTR	23874	2022-05-12	0
Los Autenticos Decadentes	23875	2022-05-12	0
Kill Hannah	23876	2022-05-12	0
Los Warahuaco	23877	2022-05-12	0
Smash Mouth	23878	2022-05-12	0
Cantovano and His Orchestra	23879	2022-05-12	0
Sentino	23880	2022-05-12	0
Aaron Jerome	23881	2022-05-12	0
Cashmere The PRO	23882	2022-05-12	0
Priscilla Ahn	23883	2022-05-12	0
Angelica Maria	23884	2022-05-12	0
Curtis	23885	2022-05-12	0
Status Quo	23886	2022-05-12	0
Pirupa & Pigi	23887	2022-05-12	0
Soerba	23888	2022-05-12	0
Ray Kane	23889	2022-05-12	0
The Real Tuesday Weld - Remix By Senor Coconut	23890	2022-05-12	0
Buff Medways	23891	2022-05-12	0
Ransom	23892	2022-05-12	0
The Threads	23893	2022-05-12	0
Loverboy	23894	2022-05-12	0
Stardust	23895	2022-05-12	0
Relatives Menschsein	23896	2022-05-12	0
Armageddon Dildos	23897	2022-05-12	0
Koffin Kats	23898	2022-05-12	0
Kaija Koo	23899	2022-05-12	0
Hopesfall	23900	2022-05-12	0
Dorothy Carless / Eugene Pini & His Orchestra	23901	2022-05-12	0
Ramsey Lewis	23902	2022-05-12	0
Anne Ducros	23903	2022-05-12	0
Frank The Baptist	23904	2022-05-12	0
Fursaxa	23905	2022-05-12	0
Highfish	23906	2022-05-12	0
Bianca Ryan	23907	2022-05-12	0
Seminole County	23908	2022-05-12	0
Buster Benton	23909	2022-05-12	0
Mike Tramp	23910	2022-05-12	0
Tiamat	23911	2022-05-12	0
Ghetto y gastan	23912	2022-05-12	0
Grand Theft Audio	23913	2022-05-12	0
Wizack Twizack	23914	2022-05-12	0
Aneta Langerova	23915	2022-05-12	0
Peter H. Olesen	23916	2022-05-12	0
Black Mountain	23917	2022-05-12	0
Knack	23918	2022-05-12	0
Alexi Murdoch	23919	2022-05-12	0
Marusha	23920	2022-05-12	0
Mariachi Sol De Mexico	23921	2022-05-12	0
Cheo García	23922	2022-05-12	0
Kelly Sweet	23923	2022-05-12	0
The Mungolian Jet Set	23924	2022-05-12	0
The Skatalites	23925	2022-05-12	0
Roberto Menescal	23926	2022-05-12	0
Akina Nakamori	23927	2022-05-12	0
Wighnomy Brothers	23928	2022-05-12	0
Bounty Killer  & Jagwa	23929	2022-05-12	0
Dick Dale & His Del-Tones	23930	2022-05-12	0
MyGrain	23931	2022-05-12	0
Kasia Kowalska	23932	2022-05-12	0
Omar Geles	23933	2022-05-12	0
Phoebe Snow	23934	2022-05-12	0
Audio Adrenaline	23935	2022-05-12	0
Ted Nugent's Amboy Dukes	23936	2022-05-12	0
Aidan Moffat + The Best-Ofs	23937	2022-05-12	0
Jefferson Starship	23938	2022-05-12	0
Jay Tee	23939	2022-05-12	0
Elvis Costello & The Attractions	23940	2022-05-12	0
Dave Brubeck;Gerry Mulligan	23941	2022-05-12	0
Bill Streett	23942	2022-05-12	0
Henry Mancini & His Orchestra	23943	2022-05-12	0
Charlie Daniels	23944	2022-05-12	0
Juana Molina	23945	2022-05-12	0
Thee Mighty Caesers	23946	2022-05-12	0
Improvisators Dub Meets Iration Steppas	23947	2022-05-12	0
Macka B	23948	2022-05-12	0
Al Petteway and Amy White	23949	2022-05-12	0
Günter Wand	23950	2022-05-12	0
DESTRUCTION	23951	2022-05-12	0
Melba Moore	23952	2022-05-12	0
Soundtrack - Music by Chris Vrenna	23953	2022-05-12	0
Finn_ Tim	23954	2022-05-12	0
Raulin Rodriguez	23955	2022-05-12	0
Hipbone Slim and the Knee Tremblers	23956	2022-05-12	0
David Sylvian	23957	2022-05-12	0
Astralasia	23958	2022-05-12	0
Cabbageboy	23959	2022-05-12	0
313 Bass Mechanics	23960	2022-05-12	0
Royal Gigolos	23961	2022-05-12	0
J. Blackfoot	23962	2022-05-12	0
Tender Trap	23963	2022-05-12	0
Marc Andrae	23964	2022-05-12	0
Soutien Gorge	23965	2022-05-12	0
Eugene Chadbourne / Andrea Centazzo	23966	2022-05-12	0
Hunter S. Thompson	23967	2022-05-12	0
Aleandro Baldi	23968	2022-05-12	0
DEATH	23969	2022-05-12	0
Average White Band	23970	2022-05-12	0
Miguel Aceves Mejía	23971	2022-05-12	0
Artificial Intelligence	23972	2022-05-12	0
Chukki Starr	23973	2022-05-12	0
High On Fire	23974	2022-05-12	0
Avalon	23975	2022-05-12	0
Art Garfunkel	23976	2022-05-12	0
hey Negrita	23977	2022-05-12	0
Geoff Moore And the Distance	23978	2022-05-12	0
Kia Shine / 8-Ball / MJG	23979	2022-05-12	0
Sodom	23980	2022-05-12	0
London Symphony Orchestra and Sixten Ehrling	23981	2022-05-12	0
DADA Feat. Sandy Rivera & Trix	23982	2022-05-12	0
Badar Ali Khan	23983	2022-05-12	0
Cancer	23984	2022-05-12	0
Postmortem Promises	23985	2022-05-12	0
DJ Tomekk	23986	2022-05-12	0
Tony Rebel	23987	2022-05-12	0
Jimmie Lee Robinson	23988	2022-05-12	0
Jeff Lorber / Dave Koz	23989	2022-05-12	0
Leon Ashley	23990	2022-05-12	0
Tryo	23991	2022-05-12	0
Carrie Rodriguez	23992	2022-05-12	0
George Carlin & Jack Burns	23993	2022-05-12	0
Man With No Name	23994	2022-05-12	0
Ben Harper	23995	2022-05-12	0
Less Pain Forever	23996	2022-05-12	0
The Ebonys	23997	2022-05-12	0
Esther Williams	23998	2022-05-12	0
The Windupdeads	23999	2022-05-12	0
Ninjaman	24000	2022-05-12	0
Marina Rei	24001	2022-05-12	0
Happy Birthday	24002	2022-05-12	0
Marc Van Linden feat. De/Vision	24003	2022-05-12	0
Mass Production	24004	2022-05-12	0
Martyn Hare	24005	2022-05-12	0
Blake Jarrell	24006	2022-05-12	0
Prince Far I	24007	2022-05-12	0
Big City Orchestra	24008	2022-05-12	0
Cary Brothers	24009	2022-05-12	0
Rob Swift	24010	2022-05-12	0
M.I.K.E. vs. Andrew Bennett	24011	2022-05-12	0
Debbie Reynolds	24012	2022-05-12	0
Al Denson	24013	2022-05-12	0
Der Mystic	24014	2022-05-12	0
The Lord Henry	24015	2022-05-12	0
Choir of Young Believers	24016	2022-05-12	0
Giant Drag	24017	2022-05-12	0
Meat Beat Manifesto	24018	2022-05-12	0
Joanna Connor	24019	2022-05-12	0
Francis Magalona	24020	2022-05-12	0
New Orleans Rhythm Kings	24021	2022-05-12	0
The Embarrassment	24022	2022-05-12	0
Scott Colby	24023	2022-05-12	0
Drones	24024	2022-05-12	0
Architecture In Helsinki	24025	2022-05-12	0
The Fleetwoods	24026	2022-05-12	0
Informatik	24027	2022-05-12	0
Jeff Kashiwa	24028	2022-05-12	0
Dick Hyman	24029	2022-05-12	0
R-Tem	24030	2022-05-12	0
The Hokum Boys	24031	2022-05-12	0
Gina Foster + Chris Ballin	24032	2022-05-12	0
Die Bandbreite	24033	2022-05-12	0
The Wiggles	24034	2022-05-12	0
Gift of Gab	24035	2022-05-12	0
Lead Belly	24036	2022-05-12	0
Anguilla Project	24037	2022-05-12	0
I-Roy	24038	2022-05-12	0
kuniaki takenaga	24039	2022-05-12	0
Dylan Rhymes	24040	2022-05-12	0
Minnesota Orchestra and Stanislaw Skrowaczewski	24041	2022-05-12	0
Der Tobi & Das Bo	24042	2022-05-12	0
Abbacadabra	24043	2022-05-12	0
Pete Yorn	24044	2022-05-12	0
Lady GaGa	24045	2022-05-12	0
The Colour	24046	2022-05-12	0
Timbaland & Magoo / Bubba Sparxxx	24047	2022-05-12	0
Alfonzo Hunter	24048	2022-05-12	0
The Jason Bonham Band	24049	2022-05-12	0
Lenny Dee & Promo	24050	2022-05-12	0
Halo	24051	2022-05-12	0
The Limeliters	24052	2022-05-12	0
The Young Republic	24053	2022-05-12	0
Runaway Totem	24054	2022-05-12	0
Jolene	24055	2022-05-12	0
Ed O.G.	24056	2022-05-12	0
Capitol Punishment	24057	2022-05-12	0
She Keeps Bees	24058	2022-05-12	0
Jaded Heart	24059	2022-05-12	0
The Lemonheads	24060	2022-05-12	0
Beyoncé and Walter Williams_ Sr. (of The O'Jays)	24061	2022-05-12	0
Elixir	24062	2022-05-12	0
Strawbs	24063	2022-05-12	0
Skyhooks	24064	2022-05-12	0
Astral Social Club	24065	2022-05-12	0
Jett Alinia	24066	2022-05-12	0
Paco De Lucia / Ramón Algeciras	24067	2022-05-12	0
The Outfield	24068	2022-05-12	0
Les Sans Culottes	24069	2022-05-12	0
Tony Orlando & Dawn	24070	2022-05-12	0
Michael Jones	24071	2022-05-12	0
Tum Tum	24072	2022-05-12	0
Guru Josh	24073	2022-05-12	0
Mc Chris	24074	2022-05-12	0
Chanel	24075	2022-05-12	0
Ike Reilly	24076	2022-05-12	0
Catamenia	24077	2022-05-12	0
Richy Pitch	24078	2022-05-12	0
Claudia Cazacu	24079	2022-05-12	0
Macabre	24080	2022-05-12	0
Suburbs	24081	2022-05-12	0
Maynard Ferguson / Big Bop Nouveau	24082	2022-05-12	0
Factoria	24083	2022-05-12	0
Inner Circle	24084	2022-05-12	0
La Sonrisa De Julia	24085	2022-05-12	0
Israel López Cachao	24086	2022-05-12	0
Speedstar	24087	2022-05-12	0
Faiz Ali Faiz	24088	2022-05-12	0
Facto Delafe y las flores azules	24089	2022-05-12	0
The Trammps	24090	2022-05-12	0
Jack Margolis & Jere Alan Brain	24091	2022-05-12	0
Rollerskate Skinny	24092	2022-05-12	0
Steve Thorne	24093	2022-05-12	0
Disney Razors	24094	2022-05-12	0
Diecast	24095	2022-05-12	0
The Dingees	24096	2022-05-12	0
Canned Heat	24097	2022-05-12	0
Via Audio	24098	2022-05-12	0
Leo Gandelman	24099	2022-05-12	0
Tommy Page	24100	2022-05-12	0
Heather Nova	24101	2022-05-12	0
Mama's Jasje	24102	2022-05-12	0
DD/MM/YYYY	24103	2022-05-12	0
Credo	24104	2022-05-12	0
Jessi Colter	24105	2022-05-12	0
Chris Berardo & The DesBerardos	24106	2022-05-12	0
Bertine Zetlitz	24107	2022-05-12	0
Counting Crows / Vanessa Carlton	24108	2022-05-12	0
Haji & Emanuel Feat. Erire	24109	2022-05-12	0
Indian Bottom Association Old Regular Baptists / Elliot Goldenthal	24110	2022-05-12	0
Kompulsor	24111	2022-05-12	0
Mary Chapin Carpenter	24112	2022-05-12	0
Monogato	24113	2022-05-12	0
Brutal Knights	24114	2022-05-12	0
Prince Allah	24115	2022-05-12	0
Daz Dillnger featuring Andrea Gray	24116	2022-05-12	0
Voodoo Glow Skulls	24117	2022-05-12	0
Phil Vassar	24118	2022-05-12	0
Masakazu Yoshizawa	24119	2022-05-12	0
Misty Roses	24120	2022-05-12	0
Nadine Sutherland	24121	2022-05-12	0
Calum Kennedy	24122	2022-05-12	0
Reunion Show	24123	2022-05-12	0
Unique 3	24124	2022-05-12	0
Stefanie Sun	24125	2022-05-12	0
Puffball	24126	2022-05-12	0
Daniel Weber	24127	2022-05-12	0
Samuel L Session	24128	2022-05-12	0
DREAMDAZE	24129	2022-05-12	0
Tones On Tail	24130	2022-05-12	0
Eddie Gonzalez	24131	2022-05-12	0
Jose Cid	24132	2022-05-12	0
Mandingo	24133	2022-05-12	0
Ernie K. Doe	24134	2022-05-12	0
Zoot Money's Big Roll Band	24135	2022-05-12	0
Apulanta	24136	2022-05-12	0
Young Fresh Fellows	24137	2022-05-12	0
Candy Dulfer Featuring Cozy Powell and Jan Akkerman	24138	2022-05-12	0
The Cliks	24139	2022-05-12	0
Jeff Linsky	24140	2022-05-12	0
Brave Combo	24141	2022-05-12	0
Tumi And The Volume	24142	2022-05-12	0
Stuff Smith Quartet Feat. Svend Asmussen	24143	2022-05-12	0
Brass Construction	24144	2022-05-12	0
The Mississippi Mass Choir	24145	2022-05-12	0
Solas	24146	2022-05-12	0
Noah D & No Thing	24147	2022-05-12	0
Brainkicker Vs Bass Modulators	24148	2022-05-12	0
Hem	24149	2022-05-12	0
The Wonder Years / All Or Nothing	24150	2022-05-12	0
FSTZ	24151	2022-05-12	0
Banda Sinaloense El Recodo De Cruz Lizarraga	24152	2022-05-12	0
Patience & Prudence	24153	2022-05-12	0
Valete	24154	2022-05-12	0
Little Tony	24155	2022-05-12	0
Hector Zazou & Swara	24156	2022-05-12	0
Soloman Burke	24157	2022-05-12	0
Rydah J Klyde & Fed X	24158	2022-05-12	0
Alela Diane	24159	2022-05-12	0
A-FS	24160	2022-05-12	0
Kurupt & Ras Kass	24161	2022-05-12	0
Ace Frehley	24162	2022-05-12	0
Peter Richard	24163	2022-05-12	0
Genghis Tron	24164	2022-05-12	0
Dany Bédar	24165	2022-05-12	0
Chris Murray	24166	2022-05-12	0
Anane	24167	2022-05-12	0
Edoardo Vianello	24168	2022-05-12	0
Edgar Meyer and Chris Thile	24169	2022-05-12	0
R.L. Burnside	24170	2022-05-12	0
Miljoonasade	24171	2022-05-12	0
Albert King	24172	2022-05-12	0
Showaddywaddy	24173	2022-05-12	0
Robbie Dupree	24174	2022-05-12	0
Dany Dan	24175	2022-05-12	0
Yvonne Loriod	24176	2022-05-12	0
Pinetop Perkins	24177	2022-05-12	0
Plain White T S	24178	2022-05-12	0
Yusef Lateef	24179	2022-05-12	0
Nesian Mystik	24180	2022-05-12	0
Gilberto Gil	24181	2022-05-12	0
Los Rotos	24182	2022-05-12	0
Dave Holland Sextet	24183	2022-05-12	0
Fotomaker	24184	2022-05-12	0
Pedro Costa	24185	2022-05-12	0
The Twilight Sad	24186	2022-05-12	0
Ferhat Livaneli	24187	2022-05-12	0
Malu	24188	2022-05-12	0
Gratitude	24189	2022-05-12	0
Cerrone	24190	2022-05-12	0
Ray_ Goodman & Brown	24191	2022-05-12	0
The Solid Doctor	24192	2022-05-12	0
Miguel Taveras	24193	2022-05-12	0
Go Fish	24194	2022-05-12	0
Angela Lashley	24195	2022-05-12	0
James Kakande	24196	2022-05-12	0
Giorgio Moroder	24197	2022-05-12	0
Airiel	24198	2022-05-12	0
The Gits	24199	2022-05-12	0
Anti Nowhere League	24200	2022-05-12	0
Sarantis	24201	2022-05-12	0
Escapade	24202	2022-05-12	0
Beck	24203	2022-05-12	0
Mama	24204	2022-05-12	0
Propaganda	24205	2022-05-12	0
Keren Ann	24206	2022-05-12	0
Elastinen	24207	2022-05-12	0
Dan Hill	24208	2022-05-12	0
Stoneface & Terminal	24209	2022-05-12	0
Rainer Trueby	24210	2022-05-12	0
The Hold Steady	24211	2022-05-12	0
Vakill & Molemen	24212	2022-05-12	0
Dooley Wilson	24213	2022-05-12	0
Weird Al Yankovic	24214	2022-05-12	0
Push	24215	2022-05-12	0
Benny Goodman Quartet	24216	2022-05-12	0
Melt Banana	24217	2022-05-12	0
The Bangles	24218	2022-05-12	0
Diesel Park West	24219	2022-05-12	0
Cex	24220	2022-05-12	0
Man Man	24221	2022-05-12	0
Cansis	24222	2022-05-12	0
Charles River Valley Boys	24223	2022-05-12	0
DJ Attila	24224	2022-05-12	0
Unsane	24225	2022-05-12	0
Kasia Cerekwicka	24226	2022-05-12	0
Gebrüder Blattschuss	24227	2022-05-12	0
Jay Haze	24228	2022-05-12	0
Judy Garland_ Lucille Bremer And Ensemble	24229	2022-05-12	0
Androgyn Network	24230	2022-05-12	0
Ricardo Lemvo	24231	2022-05-12	0
At The Gates	24232	2022-05-12	0
Tone-Loc	24233	2022-05-12	0
Franz Ferdinand	24234	2022-05-12	0
Eileen Farrell	24235	2022-05-12	0
The Beta Band	24236	2022-05-12	0
Manolo Sanlucar	24237	2022-05-12	0
Flamingokvintetten	24238	2022-05-12	0
Comeback Kid	24239	2022-05-12	0
Backside Artists	24240	2022-05-12	0
D-Tune	24241	2022-05-12	0
Gary Myrick	24242	2022-05-12	0
Susan Gritton	24243	2022-05-12	0
Not From There	24244	2022-05-12	0
Smoke Dza	24245	2022-05-12	0
Phonique	24246	2022-05-12	0
Ame Strong	24247	2022-05-12	0
Ettison Clio	24248	2022-05-12	0
Blues Company	24249	2022-05-12	0
John Cafferty	24250	2022-05-12	0
By The Tree	24251	2022-05-12	0
Vaggelis Perpiniadis	24252	2022-05-12	0
Scarface	24253	2022-05-12	0
Fall Of Serenity	24254	2022-05-12	0
Joe South	24255	2022-05-12	0
Skids	24256	2022-05-12	0
Yolanda Be Cool	24257	2022-05-12	0
School Of Language	24258	2022-05-12	0
Sweet Honey In The Rock	24259	2022-05-12	0
Tigerstyle	24260	2022-05-12	0
Live	24261	2022-05-12	0
Osi	24262	2022-05-12	0
Millenium	24263	2022-05-12	0
Symphony in Peril	24264	2022-05-12	0
The Blood Arm	24265	2022-05-12	0
Markus Nikolai	24266	2022-05-12	0
Kerkko Koskinen	24267	2022-05-12	0
Jacqueline François	24268	2022-05-12	0
Orioles	24269	2022-05-12	0
Jack Greene	24270	2022-05-12	0
Jane Monheit	24271	2022-05-12	0
Good Old War	24272	2022-05-12	0
Boom Bip & Doseone	24273	2022-05-12	0
The Shangri-Las	24274	2022-05-12	0
Rick Ross / Magazeen	24275	2022-05-12	0
C.V. Jørgensen	24276	2022-05-12	0
Moongarden	24277	2022-05-12	0
Margaret Whiting	24278	2022-05-12	0
Fancy	24279	2022-05-12	0
Mamonas Assassinas	24280	2022-05-12	0
Eastern Star	24281	2022-05-12	0
G.T.A.	24282	2022-05-12	0
Lee Curtiss	24283	2022-05-12	0
Mantronix Featuring Wondress	24284	2022-05-12	0
Césaria Evora	24285	2022-05-12	0
Let's Get Out of This Terrible Sandwich Shop	24286	2022-05-12	0
Yes	24287	2022-05-12	0
The Fine Arts Showcase	24288	2022-05-12	0
Owsley	24289	2022-05-12	0
Stacy Keibler	24290	2022-05-12	0
DAVE MATTHEWS BAND	24291	2022-05-12	0
Nick Holder	24292	2022-05-12	0
Mista	24293	2022-05-12	0
Howard Jones	24294	2022-05-12	0
White Hot Ice	24295	2022-05-12	0
Alliance Ethnik	24296	2022-05-12	0
Who Made Who	24297	2022-05-12	0
Space	24298	2022-05-12	0
Earth Crisis	24299	2022-05-12	0
Jean-Louis Aubert	24300	2022-05-12	0
Mange Schmidt	24301	2022-05-12	0
Blindside	24302	2022-05-12	0
Celtic Spirit	24303	2022-05-12	0
Bugs_ The	24304	2022-05-12	0
Anhken	24305	2022-05-12	0
Escolanía de Montserrat	24306	2022-05-12	0
Jeremy Camp and Adie Camp	24307	2022-05-12	0
Lou Pride	24308	2022-05-12	0
Big Tymers	24309	2022-05-12	0
Bloodbound	24310	2022-05-12	0
Mother's Finest	24311	2022-05-12	0
Enrico Caruso	24312	2022-05-12	0
Holly Valance	24313	2022-05-12	0
Vlidge	24314	2022-05-12	0
del Valle	24315	2022-05-12	0
Who's Your Favorite Son God	24316	2022-05-12	0
Sippie Wallace	24317	2022-05-12	0
Finntroll	24318	2022-05-12	0
Bobby Rush	24319	2022-05-12	0
Xhelazz	24320	2022-05-12	0
David Granha	24321	2022-05-12	0
Grand Magus	24322	2022-05-12	0
Death In Vegas	24323	2022-05-12	0
Kryztow De Fier	24324	2022-05-12	0
Kasey Chambers	24325	2022-05-12	0
Kym Marsh	24326	2022-05-12	0
Berrogüetto	24327	2022-05-12	0
Manu Dibango	24328	2022-05-12	0
Britney Spears	24329	2022-05-12	0
Digital Underground	24330	2022-05-12	0
Front  242	24331	2022-05-12	0
(We Are) Performance	24332	2022-05-12	0
The Next Best Thing	24333	2022-05-12	0
The Breaks	24334	2022-05-12	0
Beatnik Filmstars	24335	2022-05-12	0
Country Cajun	24336	2022-05-12	0
Yip-Yip	24337	2022-05-12	0
Stephanie McIntosh	24338	2022-05-12	0
Era	24339	2022-05-12	0
Jimmy Bo Horne	24340	2022-05-12	0
Cannon's Jug Stompers	24341	2022-05-12	0
Cedric Myton	24342	2022-05-12	0
Super Chikan	24343	2022-05-12	0
Alvino Rey And His Orchestra	24344	2022-05-12	0
Riserva Moac	24345	2022-05-12	0
Creedence Clearwater Revived	24346	2022-05-12	0
Spook And The Guay	24347	2022-05-12	0
Cassandra Wilson	24348	2022-05-12	0
Wretch 32_ Haydon	24349	2022-05-12	0
Stern	24350	2022-05-12	0
Karla Bonoff	24351	2022-05-12	0
Oneida	24352	2022-05-12	0
Pawnshop Orchestra	24488	2022-05-12	0
Hezekiah Walker & The Love Fellowship Crusade Choir	24353	2022-05-12	0
Al Hirt	24354	2022-05-12	0
Elbicho	24355	2022-05-12	0
Chuck E. Weiss	24356	2022-05-12	0
Nikki Sudden And Phil Shoenfelt	24357	2022-05-12	0
Jabberjaw	24358	2022-05-12	0
Curt Boetcher	24359	2022-05-12	0
Ike And Tina Turner	24360	2022-05-12	0
Buddy Cole	24361	2022-05-12	0
Ides Of March	24362	2022-05-12	0
The Spektrum	24363	2022-05-12	0
Steve Cropper & Felix Cavaliere	24364	2022-05-12	0
Pitch Shifter	24365	2022-05-12	0
Rise and Fall of a Decade	24366	2022-05-12	0
Max Brannslokker	24367	2022-05-12	0
911	24368	2022-05-12	0
Blood Music	24369	2022-05-12	0
Bobby Sherman	24370	2022-05-12	0
Emma Shapplin	24371	2022-05-12	0
Neville Grant	24372	2022-05-12	0
Rah Digga	24373	2022-05-12	0
MNEMIC	24374	2022-05-12	0
Fridge	24375	2022-05-12	0
Saliva	24376	2022-05-12	0
Gloomy Grim	24377	2022-05-12	0
Dennis Christopher vs. Tony Cha Cha	24378	2022-05-12	0
John Davis & Emma Doyle	24379	2022-05-12	0
Major Lazer / Nina Sky / Ricky Blaze	24380	2022-05-12	0
The Paper Faces	24381	2022-05-12	0
The Timeout Drawer	24382	2022-05-12	0
Joy Lynn White	24383	2022-05-12	0
Brigitte Bardot / Serge Gainsbourg	24384	2022-05-12	0
Geeshie Wiley	24385	2022-05-12	0
Georgia Steamroller	24386	2022-05-12	0
The Slovak National Symphony Orchestra	24387	2022-05-12	0
The Hope Blister	24388	2022-05-12	0
Marco Van Bassken	24389	2022-05-12	0
Klartext	24390	2022-05-12	0
Cracker/Leftover Salmon	24391	2022-05-12	0
Green Day	24392	2022-05-12	0
Toto Coelo	24393	2022-05-12	0
Pato Pooh	24394	2022-05-12	0
Paul Deighton	24395	2022-05-12	0
Artful Dodger Featuring Michelle Escoffery	24396	2022-05-12	0
To Rococo Rot And I-Sound	24397	2022-05-12	0
Gary Numan	24398	2022-05-12	0
Billy Bragg & The Blokes	24399	2022-05-12	0
Dave's True Story	24400	2022-05-12	0
Udi Yorgo Bacanos	24401	2022-05-12	0
Juniper	24402	2022-05-12	0
Ryan Bingham	24403	2022-05-12	0
Chicks On Speed	24404	2022-05-12	0
Matt Nathanson	24405	2022-05-12	0
Sam Roberts	24406	2022-05-12	0
Navajita Platea	24407	2022-05-12	0
Emo	24408	2022-05-12	0
The Centurions	24409	2022-05-12	0
Norman Greenbaum	24410	2022-05-12	0
The Chairmen of the Board	24411	2022-05-12	0
The Master Musicians Of Jajouka	24412	2022-05-12	0
Margaret Cho	24413	2022-05-12	0
Sonicflood	24414	2022-05-12	0
The Detachment Kit	24415	2022-05-12	0
Upsetters	24416	2022-05-12	0
Peps Blodsband	24417	2022-05-12	0
The Untouchables	24418	2022-05-12	0
The Small Faces	24419	2022-05-12	0
Gavin Osborn	24420	2022-05-12	0
Blame ft. Ruff Sqwad	24421	2022-05-12	0
Walter Beasley	24422	2022-05-12	0
Swiss	24423	2022-05-12	0
Maria Daniela Y Su Sonido Lasser	24424	2022-05-12	0
Just Left	24425	2022-05-12	0
Caz	24426	2022-05-12	0
Paul White	24427	2022-05-12	0
LOFT 17	24428	2022-05-12	0
Shipwreck ad	24429	2022-05-12	0
Impact	24430	2022-05-12	0
Oliver Rohrbeck	24431	2022-05-12	0
Geoff And Maria Muldaur	24432	2022-05-12	0
Eoghan Quigg	24433	2022-05-12	0
Timex Social Club	24434	2022-05-12	0
The Radiators	24435	2022-05-12	0
Jan Hruby & Kukulin	24436	2022-05-12	0
Chris Eckman	24437	2022-05-12	0
Mandible Chatter	24438	2022-05-12	0
Amy Lambert	24439	2022-05-12	0
Michele Zarrillo	24440	2022-05-12	0
Bessie Tucker	24441	2022-05-12	0
Fate	24442	2022-05-12	0
Dale Watson and His Lone Stars	24443	2022-05-12	0
Joseph Arthur and The Lonely Astronauts	24444	2022-05-12	0
Gretchen Wilson	24445	2022-05-12	0
TOKA	24446	2022-05-12	0
Trouble	24447	2022-05-12	0
George Benson	24448	2022-05-12	0
Chamberlain	24449	2022-05-12	0
Sodom & Gomorrah	24450	2022-05-12	0
Ya Boy	24451	2022-05-12	0
Flaco	24452	2022-05-12	0
Gob	24453	2022-05-12	0
Cell	24454	2022-05-12	0
George Thorogood And The Destroyers	24455	2022-05-12	0
The Brother Kite	24456	2022-05-12	0
Sanctity	24457	2022-05-12	0
Johnny Ca$h	24458	2022-05-12	0
The Sweet Inspirations	24459	2022-05-12	0
JV	24460	2022-05-12	0
Schloss Tegal	24461	2022-05-12	0
Inaya Day	24462	2022-05-12	0
Loveninjas	24463	2022-05-12	0
Kisha	24464	2022-05-12	0
Kreator	24465	2022-05-12	0
El Trono de Mexico	24466	2022-05-12	0
Moped	24467	2022-05-12	0
Choir & Orchestra Of The Civic Opera Of Dallas_ Maria Callas_ Jon Vickers_ Teresa Berganza	24468	2022-05-12	0
Against All Authority	24469	2022-05-12	0
Token Entry	24470	2022-05-12	0
The Gathering	24471	2022-05-12	0
Johnny Dorelli	24472	2022-05-12	0
Brian Sanhaji	24473	2022-05-12	0
Juliana Hatfield	24474	2022-05-12	0
Simone & Zélia Duncan	24475	2022-05-12	0
Bajaga & Instruktori	24476	2022-05-12	0
Mack 10 Featuring Red Café & Wanted (Skoop Delena & Young Soprano)	24477	2022-05-12	0
Simone Cristicchi	24478	2022-05-12	0
mechanical bride	24479	2022-05-12	0
Fred Anderson Quartet	24480	2022-05-12	0
Ungdomskulen	24481	2022-05-12	0
Björn Heuser	24482	2022-05-12	0
Tom Trago	24483	2022-05-12	0
Jae Millz	24484	2022-05-12	0
Care Factor	24485	2022-05-12	0
Miss Jools	24486	2022-05-12	0
Milky Wimpshake	24487	2022-05-12	0
Lucky Fonz III	24489	2022-05-12	0
Fast Offensive	24490	2022-05-12	0
András Schiff_ Dénas Várjon_ Heinz Holliger & Budapest Festival Orchestra	24491	2022-05-12	0
The Rutles	24492	2022-05-12	0
Swimming The Nile	24493	2022-05-12	0
Bill Fay	24494	2022-05-12	0
J Church	24495	2022-05-12	0
Switchfoot	24496	2022-05-12	0
Glutamato Ye Ye	24497	2022-05-12	0
Mindflayer	24498	2022-05-12	0
Charles Aznavour	24499	2022-05-12	0
The Gone Jackals	24500	2022-05-12	0
Paul Cantelon	24501	2022-05-12	0
Sabri Brothers	24502	2022-05-12	0
Ralph Stanley	24503	2022-05-12	0
Alvin Stardust	24504	2022-05-12	0
The Budos Band	24505	2022-05-12	0
YACHT_ YACHT	24506	2022-05-12	0
Alabama Thunderpussy	24507	2022-05-12	0
Jinx Jones	24508	2022-05-12	0
Jah Legacy	24509	2022-05-12	0
Gunnar Danielsson	24510	2022-05-12	0
Eskimo Disco	24511	2022-05-12	0
Opal	24512	2022-05-12	0
Peter Cetera	24513	2022-05-12	0
Throb	24514	2022-05-12	0
Jerk With A Bomb	24515	2022-05-12	0
Scott Holt	24516	2022-05-12	0
Rise Against	24517	2022-05-12	0
Blessed By a Broken Heart	24518	2022-05-12	0
Parks & Wilson	24519	2022-05-12	0
The Alan Parsons Project	24520	2022-05-12	0
Marsheaux	24521	2022-05-12	0
Kid Abelha	24522	2022-05-12	0
The Red Chord	24523	2022-05-12	0
Daniel Merriweather	24524	2022-05-12	0
Jack Off Jill	24525	2022-05-12	0
June Carter Cash	24526	2022-05-12	0
Misery Loves Co	24527	2022-05-12	0
Gun Club	24528	2022-05-12	0
Roberto Roena	24529	2022-05-12	0
Cathy Dennis	24530	2022-05-12	0
Savatage	24531	2022-05-12	0
Sin Plomo	24532	2022-05-12	0
More Than Crossed	24533	2022-05-12	0
Binomio de Oro de América	24534	2022-05-12	0
Novalima	24535	2022-05-12	0
Eddie Rabbitt	24536	2022-05-12	0
Hitmakers_ Inc.	24537	2022-05-12	0
Squares On Both Sides	24538	2022-05-12	0
Ivy Queen	24539	2022-05-12	0
Rhian Lois	24540	2022-05-12	0
The Ovationz	24541	2022-05-12	0
Peaktwins	24542	2022-05-12	0
Asian Dub Foundation	24543	2022-05-12	0
Tony Rohr	24544	2022-05-12	0
Supershine	24545	2022-05-12	0
The Ohio Players	24546	2022-05-12	0
De/Vision	24547	2022-05-12	0
Desastre Capital	24548	2022-05-12	0
Epic Soundtracks	24549	2022-05-12	0
I.N.T.	24550	2022-05-12	0
Grinderswitch	24551	2022-05-12	0
Crystal Fighters	24552	2022-05-12	0
John Sebastian	24553	2022-05-12	0
Angela Ro Ro	24554	2022-05-12	0
Thee Merry Widows	24555	2022-05-12	0
Tommy Roe	24556	2022-05-12	0
Mozez (Rap)	24557	2022-05-12	0
Jennifer Saunders	24558	2022-05-12	0
Atlantic Starr	24559	2022-05-12	0
Punk TV	24560	2022-05-12	0
The Scabs	24561	2022-05-12	0
Home Made Mutant	24562	2022-05-12	0
Grandmaster Flash	24563	2022-05-12	0
Gerardo	24564	2022-05-12	0
Ben Connelly	24565	2022-05-12	0
Anne Grete Preus	24566	2022-05-12	0
Udo Lindenberg	24567	2022-05-12	0
Vitalic	24568	2022-05-12	0
Demo	24569	2022-05-12	0
Jerry Beeks	24570	2022-05-12	0
Solange	24571	2022-05-12	0
Hoobastank	24572	2022-05-12	0
Blue Six	24573	2022-05-12	0
Kate Bush	24574	2022-05-12	0
Men's Recovery Project	24575	2022-05-12	0
These Animal Men	24576	2022-05-12	0
Audio Bullys Featuring Nancy Sinatra	24577	2022-05-12	0
Ashbrg	24578	2022-05-12	0
Latterman	24579	2022-05-12	0
Of Reality Beyond	24580	2022-05-12	0
Seres Vacios	24581	2022-05-12	0
X Makeena	24582	2022-05-12	0
Robin Thicke	24583	2022-05-12	0
Uli Jon Roth	24584	2022-05-12	0
Jancee Pornick Casino	24585	2022-05-12	0
Kool And The Gang	24586	2022-05-12	0
Phil Keaggy	24587	2022-05-12	0
Kiril Marichkov	24588	2022-05-12	0
The Caribbean	24589	2022-05-12	0
Cheb Khaled & Cheba Zahouania	24590	2022-05-12	0
Less Du Neuf	24591	2022-05-12	0
Gillie Da Kid	24592	2022-05-12	0
Current	24593	2022-05-12	0
Litfiba	24594	2022-05-12	0
Girls Aloud	24595	2022-05-12	0
Phalanx	24596	2022-05-12	0
Moya Brennan	24597	2022-05-12	0
The-Quartet	24598	2022-05-12	0
Joyous Celebration	24599	2022-05-12	0
ZENO	24600	2022-05-12	0
The Teddybears	24601	2022-05-12	0
Tony Caro and John	24602	2022-05-12	0
Tellison	24603	2022-05-12	0
Tree63	24604	2022-05-12	0
Los Tigrillos	24605	2022-05-12	0
John Novacek	24606	2022-05-12	0
Doc Houlind & His Copenhagen Ragtime Band	24607	2022-05-12	0
Shit and Shine	24608	2022-05-12	0
Ophélie Winter	24609	2022-05-12	0
Seidenmatt	24610	2022-05-12	0
Trey Songz	24611	2022-05-12	0
Ghost Machine	24612	2022-05-12	0
The Four Horsemen	24613	2022-05-12	0
Celesty	24614	2022-05-12	0
Jefferson Pepper	24615	2022-05-12	0
Vital Information	24616	2022-05-12	0
Vessels	24617	2022-05-12	0
Alfoa	24618	2022-05-12	0
Brusco	24619	2022-05-12	0
El Piporro	24620	2022-05-12	0
D.Black	24621	2022-05-12	0
Embodyment	24622	2022-05-12	0
The Monkees	24623	2022-05-12	0
Aphrodite's Child	24624	2022-05-12	0
Eneida Marta	24625	2022-05-12	0
Jeff Buckley	24626	2022-05-12	0
Gerry Menu	24627	2022-05-12	0
Juicy J	24628	2022-05-12	0
Nitzer Ebb	24629	2022-05-12	0
Kay the Aquanaut	24630	2022-05-12	0
Uphill Battle	24631	2022-05-12	0
Semprini	24632	2022-05-12	0
Tom Cochrane	24633	2022-05-12	0
Silver Scooter	24634	2022-05-12	0
TV On The Radio	24635	2022-05-12	0
Rockefeller	24636	2022-05-12	0
Peto Tazok & Karaoke Tundra	24637	2022-05-12	0
The Four Tops_ The Dramatics_ The Miracles_ & The Contours	24638	2022-05-12	0
The Jordanaires	24639	2022-05-12	0
Moreno+2	24640	2022-05-12	0
Manzanita	24641	2022-05-12	0
Union_ La	24642	2022-05-12	0
Zebda	24643	2022-05-12	0
The Rivingtons	24644	2022-05-12	0
DJ Godfather	24645	2022-05-12	0
The Ejected	24646	2022-05-12	0
The Medicine	24647	2022-05-12	0
Kashmir	24648	2022-05-12	0
Wild Billy Childish And The Musicians Of The British Empire	24649	2022-05-12	0
The Duke Spirit	24650	2022-05-12	0
San Quinn	24651	2022-05-12	0
Lou Reed	24652	2022-05-12	0
Cockney Rejects	24653	2022-05-12	0
Rhydian	24654	2022-05-12	0
Bad Company	24655	2022-05-12	0
Sundawner	24656	2022-05-12	0
Siempre asi	24657	2022-05-12	0
Van She	24658	2022-05-12	0
Raz Ohara	24659	2022-05-12	0
Nucleus Roots	24660	2022-05-12	0
Sole & the Skyrider Band	24661	2022-05-12	0
Niño De León	24662	2022-05-12	0
T-Model Ford	24663	2022-05-12	0
Bitter Sweet	24664	2022-05-12	0
Su ta gar	24665	2022-05-12	0
Rich Mullins	24666	2022-05-12	0
Rain Tree Crow	24667	2022-05-12	0
Cadaveria	24668	2022-05-12	0
Mike Ladd_ Vijay Iyer	24669	2022-05-12	0
Iris Dement	24670	2022-05-12	0
Dark At Dawn	24671	2022-05-12	0
Jan De Wilde	24672	2022-05-12	0
Band`Eros	24673	2022-05-12	0
The Fourmost	24674	2022-05-12	0
Syd Matters	24675	2022-05-12	0
Paola Turci	24676	2022-05-12	0
Swordmaster	24677	2022-05-12	0
Toño Rosario	24678	2022-05-12	0
The Duhks	24679	2022-05-12	0
Infa Riot	24680	2022-05-12	0
Les Paul and Mary Ford	24681	2022-05-12	0
Joram	24682	2022-05-12	0
Kim Carnes	24683	2022-05-12	0
Jose James	24684	2022-05-12	0
Arrogant Worms	24685	2022-05-12	0
Quatuor mosaïques	24686	2022-05-12	0
Erasure	24687	2022-05-12	0
VIA GRA (??? ???)	24688	2022-05-12	0
Dido	24689	2022-05-12	0
Cesaria Evora	24690	2022-05-12	0
CPM22	24691	2022-05-12	0
Jerry Reed	24692	2022-05-12	0
Starski and Clutch	24693	2022-05-12	0
Slique	24694	2022-05-12	0
Fred Gianelli	24695	2022-05-12	0
Jerry Jones	24696	2022-05-12	0
Sivert Høyem & The Volunteers	24697	2022-05-12	0
A.B. Quintanilla III Y Los Kumbia Kings	24698	2022-05-12	0
Jack Wall/Slovak National Symphony Orchestra/Crouch End Festival Chorus/David Temple	24699	2022-05-12	0
Nu-Contrast	24700	2022-05-12	0
Idlewild	24701	2022-05-12	0
Myra	24702	2022-05-12	0
Elephant Beach (Thaione Davis & J. Sayne)	24703	2022-05-12	0
Chad Rex and the Victorstands	24704	2022-05-12	0
Metro	24705	2022-05-12	0
Hardsoul feat. Ron Carrol	24706	2022-05-12	0
TW Walsh	24707	2022-05-12	0
Hilary Duff	24708	2022-05-12	0
The Paramounts	24709	2022-05-12	0
Michel Montecrossa	24710	2022-05-12	0
Ella Washington	24711	2022-05-12	0
YZ	24712	2022-05-12	0
Vox Dei	24713	2022-05-12	0
Sidney Bechet And His New Orleans Feetwarmers	24714	2022-05-12	0
The Surf Trio	24715	2022-05-12	0
Les 2 Tom	24716	2022-05-12	0
She	24717	2022-05-12	0
Zion & Lennox	24718	2022-05-12	0
Shpongle	24719	2022-05-12	0
The Rich Kids	24720	2022-05-12	0
Tin Armor	24721	2022-05-12	0
Marguerite Lambert	24722	2022-05-12	0
Cannibal Corpse	24723	2022-05-12	0
Pearl Harbor Soundtrack	24724	2022-05-12	0
Amanda Miguel	24725	2022-05-12	0
Sharam Jey & Loulou Players	24726	2022-05-12	0
Oracle	24727	2022-05-12	0
Matmatah	24728	2022-05-12	0
Tafelmusik & Matthew White	24729	2022-05-12	0
Racebannon	24730	2022-05-12	0
DJ Aligator Project	24731	2022-05-12	0
Agression	24732	2022-05-12	0
The Dickies	24733	2022-05-12	0
Remy Zero	24734	2022-05-12	0
Chico DeBarge	24735	2022-05-12	0
Orquesta Aragón	24736	2022-05-12	0
Daniele Faraotti Band	24737	2022-05-12	0
Maria (Maria Ivanova)	24738	2022-05-12	0
Artful Dodger Featuring Melanie Blatt	24739	2022-05-12	0
The Millboard Message	24740	2022-05-12	0
Simone Langlois	24741	2022-05-12	0
Ragnheiður Gröndal	24742	2022-05-12	0
Drop Dead_ Gorgeous	24743	2022-05-12	0
Joelle Leandre / Mat Maneri / Christophe Marquet / Joel Ryan	24744	2022-05-12	0
Joe Jones	24745	2022-05-12	0
Jah Cure Feat. Spectacular	24746	2022-05-12	0
mister pringle	24747	2022-05-12	0
Gary Burton / Chick Corea / Roy Haynes / Dave Holland / Pat Metheny	24748	2022-05-12	0
Gang Gang Dance	24749	2022-05-12	0
Deliverance	24750	2022-05-12	0
Cold Cave	24751	2022-05-12	0
Ali Farka Toure_ Toumani Diabate	24752	2022-05-12	0
DJ Vix	24753	2022-05-12	0
Chris Gaffney and the Cold Hard Facts	24754	2022-05-12	0
All Good Funk Alliance	24755	2022-05-12	0
Born Against	24756	2022-05-12	0
At Vance	24757	2022-05-12	0
Bernadette Peters/2003 Broadway Cast "Gypsy	24758	2022-05-12	0
Frank Gambale	24759	2022-05-12	0
Ladell McLin	24760	2022-05-12	0
Reincidentes	24761	2022-05-12	0
Eddie Santiago	24762	2022-05-12	0
Decyfer Down	24763	2022-05-12	0
Et Sans	24764	2022-05-12	0
Red Blooded Women	24765	2022-05-12	0
Magic Affair	24766	2022-05-12	0
Ebba Forsberg	24767	2022-05-12	0
P J Harvey	24768	2022-05-12	0
DOA	24769	2022-05-12	0
Conway Twitty	24770	2022-05-12	0
Mikel Erentxun & las malas influencias	24771	2022-05-12	0
Angel Doolas	24772	2022-05-12	0
Nicky Thomas	24773	2022-05-12	0
Parchman Farm	24774	2022-05-12	0
Carl Sims	24775	2022-05-12	0
Young Parisians	24776	2022-05-12	0
The Trews	24777	2022-05-12	0
Fiftyfifty	24778	2022-05-12	0
Mauricio Y Palo De Agua	24779	2022-05-12	0
I Concur	24780	2022-05-12	0
The Lens	24781	2022-05-12	0
Method Of Defiance	24782	2022-05-12	0
K-rAd	24783	2022-05-12	0
DJ Jazzy Jeff & The Fresh Prince	24784	2022-05-12	0
J Mascis	24785	2022-05-12	0
Damnation A.d.	24786	2022-05-12	0
Lunar Heights	24787	2022-05-12	0
SCHMOELLING_ JOHANNES	24788	2022-05-12	0
Lenny Dee	24789	2022-05-12	0
Go-Go's	24790	2022-05-12	0
Big Pokey	24791	2022-05-12	0
Sworn Enemy	24792	2022-05-12	0
Five Horse Johnson	24793	2022-05-12	0
All Shall Persih	24794	2022-05-12	0
Instigators	24795	2022-05-12	0
High Strung_ The	24796	2022-05-12	0
Johnny Clegg & Savuka	24797	2022-05-12	0
Alessandro Di Liberto	24798	2022-05-12	0
Gene Harris	24799	2022-05-12	0
Gustaf Spetz	24800	2022-05-12	0
Friends & Lovers	24801	2022-05-12	0
Morgana	24802	2022-05-12	0
Gram Parsons	24803	2022-05-12	0
The Faces	24804	2022-05-12	0
Sinitta	24805	2022-05-12	0
Guru	24806	2022-05-12	0
Carlo Maria Cordio	24807	2022-05-12	0
Saving Abel	24808	2022-05-12	0
The Steamy Dumplings	24809	2022-05-12	0
Harry Pussy	24810	2022-05-12	0
Cheech & Chong	24811	2022-05-12	0
Charlie Sexton & The Mystic Knights Of The Sea	24812	2022-05-12	0
Dikers	24813	2022-05-12	0
Purity	24814	2022-05-12	0
Prince Alla	24815	2022-05-12	0
Klimt 1918	24816	2022-05-12	0
R. Carlos Nakai	24817	2022-05-12	0
Blind Willie Mctell & The Regal Country Blues	24818	2022-05-12	0
The Gonads	24819	2022-05-12	0
Royal Philharmonic Orchestra_ Sir Thomas Beecham	24820	2022-05-12	0
Liam Finn	24821	2022-05-12	0
Hatcha & Benga	24822	2022-05-12	0
Tormenta	24823	2022-05-12	0
Hank Marvin	24824	2022-05-12	0
Shriekback	24825	2022-05-12	0
Base Ball Bear	24826	2022-05-12	0
Through The Sparks	24827	2022-05-12	0
Ultra DJ's	24828	2022-05-12	0
Furious George	24829	2022-05-12	0
The Cate Brothers	24830	2022-05-12	0
Aphasia	24831	2022-05-12	0
Elmo	24832	2022-05-12	0
Loon	24833	2022-05-12	0
Buju Banton (feat. Nadine Sutherland)	24834	2022-05-12	0
Tatana & Andrew Bennett feat. Tiff Lacey	24835	2022-05-12	0
David Ruffin	24836	2022-05-12	0
Lemon & Einar K	24837	2022-05-12	0
Aughra	24838	2022-05-12	0
Mountain Goats	24839	2022-05-12	0
J.T. Money	24840	2022-05-12	0
Miguel & Berny	24841	2022-05-12	0
Gerling	24842	2022-05-12	0
The Like	24843	2022-05-12	0
Almedal	24844	2022-05-12	0
States	24845	2022-05-12	0
Edmundo Ros	24846	2022-05-12	0
Feeder	24847	2022-05-12	0
Sa-ra Creative Partners	24848	2022-05-12	0
Chet Atkins	24849	2022-05-12	0
Squealer	24850	2022-05-12	0
Herborg Kråkevik	24851	2022-05-12	0
Aidan Baker	24852	2022-05-12	0
Kirsty Hawkshaw	24853	2022-05-12	0
Gentle Touch	24854	2022-05-12	0
Calabrese	24855	2022-05-12	0
Suzy Bogguss	24856	2022-05-12	0
The Car Is On Fire	24857	2022-05-12	0
Hell N' Diesel	24858	2022-05-12	0
Warner mack	24859	2022-05-12	0
Sara Gazarek	24860	2022-05-12	0
Pariisin Kevät	24861	2022-05-12	0
Waldemar Bastos / Dulce Pontes	24862	2022-05-12	0
Bombay Bicycle Club	24863	2022-05-12	0
Bebo & Cachao	24864	2022-05-12	0
Attic Lights	24865	2022-05-12	0
Wes Cunningham	24866	2022-05-12	0
Jimmy Martin	24867	2022-05-12	0
Baden Powell / Jimmy Pratt	24868	2022-05-12	0
Hiawata!	24869	2022-05-12	0
Ganjaman	24870	2022-05-12	0
Screaming Jets	24871	2022-05-12	0
Samuele Bersani	24872	2022-05-12	0
Dan Israel	24873	2022-05-12	0
Tycho	24874	2022-05-12	0
Greta Y Los Garbo	24875	2022-05-12	0
The Disco Biscuits	24876	2022-05-12	0
Alex Cappelli	24877	2022-05-12	0
Matthew Barber	24878	2022-05-12	0
John Fahey	24879	2022-05-12	0
Omar Pene	24880	2022-05-12	0
Alicia Bridges	24881	2022-05-12	0
Jack Kerouac	24882	2022-05-12	0
Julius Beat	24883	2022-05-12	0
Elkie Brooks	24884	2022-05-12	0
Frumpies	24885	2022-05-12	0
Helen Hobson	24886	2022-05-12	0
Fatal Bazooka	24887	2022-05-12	0
Man or Astro-man?	24888	2022-05-12	0
Total Science	24889	2022-05-12	0
Bee Gees	24890	2022-05-12	0
Plastic Bertrand	24891	2022-05-12	0
Ricky Fobis	24892	2022-05-12	0
Hed Pe	24893	2022-05-12	0
Damon And Naomi	24894	2022-05-12	0
Damnation of Adam Blessing	24895	2022-05-12	0
Il Genio	24896	2022-05-12	0
Kings Of Convenience	24897	2022-05-12	0
Tres Tristes Tigres	24898	2022-05-12	0
Colin James	24899	2022-05-12	0
Wednesday Night Heroes	24900	2022-05-12	0
Hi Red Center	24901	2022-05-12	0
Joana Zimmer	24902	2022-05-12	0
SINNER	24903	2022-05-12	0
Palehorse	24904	2022-05-12	0
Naturi Naughton	24905	2022-05-12	0
Montefiori Cocktail	24906	2022-05-12	0
Oliver Brooks	24907	2022-05-12	0
Sensuuri	24908	2022-05-12	0
Pelt	24909	2022-05-12	0
Charlie Feathers & His Musical Warriors	24910	2022-05-12	0
Venuti_ Goaty	24911	2022-05-12	0
Cledus T. Judd feat. Daryle Singletary	24912	2022-05-12	0
Ras Droppa	24913	2022-05-12	0
Nick Muir	24914	2022-05-12	0
Loose Ends	24915	2022-05-12	0
Golden Boys	24916	2022-05-12	0
Apoptygma Berzerk	24917	2022-05-12	0
Midnight Oil	24918	2022-05-12	0
Judie Tzuke	24919	2022-05-12	0
Pentagram	24920	2022-05-12	0
The Stains	24921	2022-05-12	0
Peabo Bryson	24922	2022-05-12	0
Uzeb	24923	2022-05-12	0
Silent Kids	24924	2022-05-12	0
Ayleon	24925	2022-05-12	0
Bonnie St. Claire and Unit Gloria	24926	2022-05-12	0
Tampa Red	24927	2022-05-12	0
Danielson	24928	2022-05-12	0
Shihad	24929	2022-05-12	0
L.A. Guns	24930	2022-05-12	0
Let's Go Outside	24931	2022-05-12	0
Urban Hype	24932	2022-05-12	0
Members Of Mayday	24933	2022-05-12	0
DJ Chus & Peter Gelderblom	24934	2022-05-12	0
Focal Point	24935	2022-05-12	0
Lonnie Liston Smith and the Cosmic Echoes	24936	2022-05-12	0
Rocky Whatule	24937	2022-05-12	0
Clay Hammond	24938	2022-05-12	0
Los Sabrosos Del Merengue	24939	2022-05-12	0
Delphi Performers	24940	2022-05-12	0
Newton Faulkner	24941	2022-05-12	0
Hardwell & Greatski	24942	2022-05-12	0
Slagsmalsklubben	24943	2022-05-12	0
Meade "Lux" Lewis	24944	2022-05-12	0
Arts & Decay	24945	2022-05-12	0
Rotten Sound	24946	2022-05-12	0
Branco	24947	2022-05-12	0
Free Kitten	24948	2022-05-12	0
Janek Schaefer	24949	2022-05-12	0
Craig Armstrong	24950	2022-05-12	0
Frank Sinatra	24951	2022-05-12	0
Circle II Circle	24952	2022-05-12	0
Jennings	24953	2022-05-12	0
Y-LUK-O	24954	2022-05-12	0
Miranda	24955	2022-05-12	0
A Made Up Sound	24956	2022-05-12	0
Onyx	24957	2022-05-12	0
Charizma	24958	2022-05-12	0
Hackberry Ramblers	24959	2022-05-12	0
Bobby Byrd	24960	2022-05-12	0
Mustafa Sandal	24961	2022-05-12	0
Every Move A Picture	24962	2022-05-12	0
Terrell	24963	2022-05-12	0
Isis (Female)	24964	2022-05-12	0
Amar Azul	24965	2022-05-12	0
Jazz Addixx	24966	2022-05-12	0
Alison Krauss / The Cox Family	24967	2022-05-12	0
Elisa	24968	2022-05-12	0
Pascow	24969	2022-05-12	0
Soul II Soul	24970	2022-05-12	0
Zoo Brazil	24971	2022-05-12	0
Masta Ace	24972	2022-05-12	0
WeltZwei	24973	2022-05-12	0
Cobna	24974	2022-05-12	0
Cymbals Eat Guitars	24975	2022-05-12	0
Charlie Mars	24976	2022-05-12	0
The London Fox Orchestra	24977	2022-05-12	0
Future Breeze	24978	2022-05-12	0
Grupo Huave Siete Mares	24979	2022-05-12	0
Lisa Gerrard_Patrick Cassidy	24980	2022-05-12	0
Banaroo	24981	2022-05-12	0
Calypso Rose	24982	2022-05-12	0
Samba de Rainha	24983	2022-05-12	0
Sonora Carruseles	24984	2022-05-12	0
Apocalyptica featuring Corey Taylor	24985	2022-05-12	0
Paula Santoro	24986	2022-05-12	0
James Brown / The J.B.'s	24987	2022-05-12	0
Billy Talent	24988	2022-05-12	0
Crash Rickshaw	24989	2022-05-12	0
Huss und Hodn	24990	2022-05-12	0
The Radiators (From Space)	24991	2022-05-12	0
Dorothy Kirsten	24992	2022-05-12	0
Terje Lie	24993	2022-05-12	0
David Ball	24994	2022-05-12	0
Whitecross	24995	2022-05-12	0
Clube Do Balanco	24996	2022-05-12	0
m.m.m.	24997	2022-05-12	0
4u	24998	2022-05-12	0
Hot Lips Page	24999	2022-05-12	0
UK Subs	25000	2022-05-12	0
Simon Cooper featuring soprano Manuela Van Geenhoven	25001	2022-05-12	0
RBD	25002	2022-05-12	0
Psychic TV	25003	2022-05-12	0
Frisco Kid	25004	2022-05-12	0
Capitalist Casualties	25005	2022-05-12	0
Toby Tobias	25006	2022-05-12	0
King Diamond & Black Rose	25007	2022-05-12	0
Elvis Costello / Allen Toussaint	25008	2022-05-12	0
Jah Mason	25009	2022-05-12	0
Flevans	25010	2022-05-12	0
Last Chance Jug Band	25011	2022-05-12	0
Pagan Wanderer Lu	25012	2022-05-12	0
Echo Is Your Love	25013	2022-05-12	0
Daggers	25014	2022-05-12	0
Ruff Endz	25015	2022-05-12	0
Dokaka	25016	2022-05-12	0
Purple Hearts	25017	2022-05-12	0
New Century Classics	25018	2022-05-12	0
Aniceto Molina	25019	2022-05-12	0
Robert Cray	25020	2022-05-12	0
Dark Side Cowboys	25021	2022-05-12	0
Secret Garden	25022	2022-05-12	0
Dark Funeral	25023	2022-05-12	0
Ida Olsson	25024	2022-05-12	0
Phil Kieran	25025	2022-05-12	0
Kikki Danielsson	25026	2022-05-12	0
Bayanihan Phillipine Dance Company	25027	2022-05-12	0
Altar	25028	2022-05-12	0
Jodeci	25029	2022-05-12	0
Cheb Balowski	25030	2022-05-12	0
Spitalfield	25031	2022-05-12	0
The Woodentops	25032	2022-05-12	0
Segismundo Toxicómano	25033	2022-05-12	0
Pólo Norte	25034	2022-05-12	0
Band Of Susans	25035	2022-05-12	0
SOiL	25036	2022-05-12	0
Olle Ljungström	25037	2022-05-12	0
Rumble!	25038	2022-05-12	0
Eyehategod	25039	2022-05-12	0
La Taberna De Moe	25040	2022-05-12	0
Tripp	25041	2022-05-12	0
Angie Stone / Betty Wright	25042	2022-05-12	0
Dark Distant Spaces	25043	2022-05-12	0
Yvette Horner & Her Musette Ensemble	25044	2022-05-12	0
Compulsion	25045	2022-05-12	0
Bernadette Peters	25046	2022-05-12	0
Mason Proffit	25047	2022-05-12	0
The Flash Express	25048	2022-05-12	0
Spinvis / Vinkenoog	25049	2022-05-12	0
Cloud Cult	25050	2022-05-12	0
Dudley Perkins	25051	2022-05-12	0
Lowlife	25052	2022-05-12	0
The Nelons	25053	2022-05-12	0
Morten Gunnar Larsen	25054	2022-05-12	0
Austin Lounge Lizards	25055	2022-05-12	0
Go West	25056	2022-05-12	0
Prestige	25057	2022-05-12	0
Something With Numbers	25058	2022-05-12	0
Skizoo	25059	2022-05-12	0
Something Like Silas	25060	2022-05-12	0
Bitches Sin	25061	2022-05-12	0
Jamal Abdillah	25062	2022-05-12	0
John D. Loudermilk	25063	2022-05-12	0
Jimmy Gilmer	25064	2022-05-12	0
Albin Myers & Sandro Monte featuring Abigail Bailey	25065	2022-05-12	0
Delaney & Bonnie	25066	2022-05-12	0
Jules & The Polar Bears	25067	2022-05-12	0
Cellador	25068	2022-05-12	0
Lyn Collins	25069	2022-05-12	0
Robert Moore	25070	2022-05-12	0
Paul Siebel	25071	2022-05-12	0
Benassi Bros. Feat. Dhany	25072	2022-05-12	0
Laurie Berkner	25073	2022-05-12	0
Solution	25074	2022-05-12	0
Frodus	25075	2022-05-12	0
Jesper Kyd	25076	2022-05-12	0
Lo Borges/Part. Especial: Uakti	25077	2022-05-12	0
El Gran Silencio	25078	2022-05-12	0
Club 8	25079	2022-05-12	0
Simon McBride	25080	2022-05-12	0
Flowchart	25081	2022-05-12	0
Lil Jon / The East Side Boyz / Nate Dogg / Snoop Dogg / Suga Free / Oobie	25082	2022-05-12	0
Miriam Yeung	25083	2022-05-12	0
Spike 1000	25084	2022-05-12	0
Debauchery	25085	2022-05-12	0
Krosfyah Feat. Edwin Yearwood	25086	2022-05-12	0
Immolation	25087	2022-05-12	0
Holly Williams	25088	2022-05-12	0
Olivia Ruiz	25089	2022-05-12	0
Tube Tech feat. Cleo X	25090	2022-05-12	0
Julie's Haircut	25091	2022-05-12	0
The Monroe Brothers	25092	2022-05-12	0
Vulgar Pigeons	25093	2022-05-12	0
Thicke	25094	2022-05-12	0
Big Brovaz	25095	2022-05-12	0
Telefuzz	25096	2022-05-12	0
Lars Frederiksen And The Bastards	25097	2022-05-12	0
Rod Mason	25098	2022-05-12	0
Hird	25099	2022-05-12	0
Pat Metheny/Brad Mehldau	25100	2022-05-12	0
The Race	25101	2022-05-12	0
Donnie McClurkin	25102	2022-05-12	0
Ulf Lundell	25103	2022-05-12	0
Peter Spence	25104	2022-05-12	0
Helium Vola	25105	2022-05-12	0
Matthew Good	25106	2022-05-12	0
Mordecai Shehori	25107	2022-05-12	0
Regner	25108	2022-05-12	0
Zora Young	25109	2022-05-12	0
Lutan Fyah	25110	2022-05-12	0
Agonised By Love	25111	2022-05-12	0
Big Brother & The Holding Company;Janis Joplin	25112	2022-05-12	0
Rusconi	25113	2022-05-12	0
Rattlesnake Remedy	25114	2022-05-12	0
Rosa Passos	25115	2022-05-12	0
Ross 154	25116	2022-05-12	0
Lulu	25117	2022-05-12	0
Jason Becker	25118	2022-05-12	0
Sugar Minott	25119	2022-05-12	0
Luniz featuring Eightball & MJG	25120	2022-05-12	0
Intrinzik	25121	2022-05-12	0
Global Communication	25122	2022-05-12	0
Eyes Cream	25123	2022-05-12	0
Erik Friedlander	25124	2022-05-12	0
3-11 Porter	25125	2022-05-12	0
Jonathan King	25126	2022-05-12	0
Eddy  Clearwater	25127	2022-05-12	0
Spiritual Beggars	25128	2022-05-12	0
Dab Hands	25129	2022-05-12	0
Bill Evans	25130	2022-05-12	0
Domu presents Pete Simpson	25131	2022-05-12	0
Wild Honey	25132	2022-05-12	0
Burnt By The Sun	25133	2022-05-12	0
The Jeff Healey Band	25134	2022-05-12	0
Lock And Key	25135	2022-05-12	0
The Duke Ellington Orchestra	25136	2022-05-12	0
Gyptian	25137	2022-05-12	0
Bobby Bare	25138	2022-05-12	0
Van Der Graaf Generator	25139	2022-05-12	0
Eskimo Joe	25140	2022-05-12	0
Sa	25141	2022-05-12	0
Kevin Hearn And Thin Buckle	25142	2022-05-12	0
Dennis Ferrer feat. Daniele	25143	2022-05-12	0
Amplifier	25144	2022-05-12	0
Peter Rowan	25145	2022-05-12	0
Nester Torres	25146	2022-05-12	0
Beeda Weeda	25147	2022-05-12	0
Silk	25148	2022-05-12	0
Tamlins	25149	2022-05-12	0
Jack Oblivian	25150	2022-05-12	0
Blut Aus Nord	25151	2022-05-12	0
Ion Dissonance	25152	2022-05-12	0
Gina V. D'Orio	25153	2022-05-12	0
Roger Meno	25154	2022-05-12	0
Widespread Panic Tribute	25155	2022-05-12	0
Piemont	25156	2022-05-12	0
Mauro Picotto	25157	2022-05-12	0
Stan Whitmire	25158	2022-05-12	0
Alexia Bomtempo	25159	2022-05-12	0
Mike Thomas And The Sure Thing	25160	2022-05-12	0
311	25161	2022-05-12	0
Beth Quist	25162	2022-05-12	0
Factory	25163	2022-05-12	0
Crowbar	25164	2022-05-12	0
Little Beaver	25165	2022-05-12	0
The Fevers	25166	2022-05-12	0
A-Studio	25167	2022-05-12	0
Billie Jo Spears	25168	2022-05-12	0
Factor	25169	2022-05-12	0
Svenne Rubins	25170	2022-05-12	0
Restless Heart	25171	2022-05-12	0
Géraldine Cozier	25172	2022-05-12	0
Ronnie Earl & the Broadcasters	25173	2022-05-12	0
The Waking Eyes	25174	2022-05-12	0
Gaylads	25175	2022-05-12	0
Sheila On 7	25176	2022-05-12	0
My Little Cheap Dictaphone	25177	2022-05-12	0
Rikarena	25316	2022-05-12	0
Eraldo Bernocchi / Harold Budd	25178	2022-05-12	0
Whip	25179	2022-05-12	0
The Blockheads	25180	2022-05-12	0
Ultra Naté	25181	2022-05-12	0
Saxon	25182	2022-05-12	0
Fivespeed	25183	2022-05-12	0
Screaming Jay Hawkins	25184	2022-05-12	0
Phillip Boa And The Voodooclub	25185	2022-05-12	0
Anne Dudley	25186	2022-05-12	0
Radiotones	25187	2022-05-12	0
Bobby Hutcherson	25188	2022-05-12	0
Phil Miller	25189	2022-05-12	0
The Lovin' Spoonful	25190	2022-05-12	0
The Courteeners	25191	2022-05-12	0
PJ Harvey	25192	2022-05-12	0
Mugison	25193	2022-05-12	0
Steroid Maximus	25194	2022-05-12	0
Inspectah Deck featuring La the Darkman	25195	2022-05-12	0
Three Dog Night	25196	2022-05-12	0
Edith Lefel	25197	2022-05-12	0
De Sela Lhasa	25198	2022-05-12	0
Robert Wilkins	25199	2022-05-12	0
Psychopomps	25200	2022-05-12	0
Tito Puente	25201	2022-05-12	0
Ron Hardy	25202	2022-05-12	0
Burzum	25203	2022-05-12	0
Lena Philipsson	25204	2022-05-12	0
Rick Wakeman	25205	2022-05-12	0
Dabrye feat. Jay Dee & Phat Kat	25206	2022-05-12	0
Chrisma	25207	2022-05-12	0
Pele	25208	2022-05-12	0
Big Midnight	25209	2022-05-12	0
Love and Rockets	25210	2022-05-12	0
Southland Gangsters	25211	2022-05-12	0
40 Cal.	25212	2022-05-12	0
Pedro Garcia & His Del Prado Orchestra	25213	2022-05-12	0
Sharkey & C-Rayz Walz	25214	2022-05-12	0
Liquid Zen	25215	2022-05-12	0
Sweeney's Men	25216	2022-05-12	0
Jus Wan	25217	2022-05-12	0
The Workin' Stiffs	25218	2022-05-12	0
Alyson Stoner	25219	2022-05-12	0
Disembowelment	25220	2022-05-12	0
U2	25221	2022-05-12	0
Capital Tax	25222	2022-05-12	0
Rocio Banquells	25223	2022-05-12	0
Ian Brown	25224	2022-05-12	0
Skye Sweetnam	25225	2022-05-12	0
Bob Hope	25226	2022-05-12	0
Winter Hours	25227	2022-05-12	0
Os Cariocas	25228	2022-05-12	0
Sonny & Linda Sharrock	25229	2022-05-12	0
Marco Bailey & Dany Rodriguez	25230	2022-05-12	0
Wizzy Noise	25231	2022-05-12	0
Babylon Bombs	25232	2022-05-12	0
Tranzmitors	25233	2022-05-12	0
Fire Town	25234	2022-05-12	0
Pisces	25235	2022-05-12	0
Piney Gir	25236	2022-05-12	0
Mays	25237	2022-05-12	0
Margarita	25238	2022-05-12	0
Paul Jackson Jr.	25239	2022-05-12	0
Cowboy Prostitutes	25240	2022-05-12	0
Byron Metcalf	25241	2022-05-12	0
M.O.E.	25242	2022-05-12	0
Tinga Stewart	25243	2022-05-12	0
Harry Choo Choo Romero	25244	2022-05-12	0
The Roadside Graves	25245	2022-05-12	0
Gordian Knot	25246	2022-05-12	0
Lennie Tristano	25247	2022-05-12	0
Enter Shikari	25248	2022-05-12	0
Dancing Fantasy	25249	2022-05-12	0
Adrenalin O.D.	25250	2022-05-12	0
Mad Lion	25251	2022-05-12	0
Jukebox The Ghost	25252	2022-05-12	0
Shania Twain	25253	2022-05-12	0
Roger McGuinn	25254	2022-05-12	0
VIVA VOCE die a cappella Band	25255	2022-05-12	0
Pop Will Eat Itself	25256	2022-05-12	0
Talking Heads	25257	2022-05-12	0
Bedouin Soundclash	25258	2022-05-12	0
Witchdoctor	25259	2022-05-12	0
Juan Gabriel	25260	2022-05-12	0
Les Hell On Heels	25261	2022-05-12	0
Mark Heard	25262	2022-05-12	0
So Called Plan	25263	2022-05-12	0
Neuromotor	25264	2022-05-12	0
Lil' Romeo	25265	2022-05-12	0
Frankie Knuckles	25266	2022-05-12	0
Holy National Victims	25267	2022-05-12	0
FM Attack	25268	2022-05-12	0
Keith Jarrett_ Gary Peacock_ Jack DeJohnette	25269	2022-05-12	0
Bob Lind	25270	2022-05-12	0
Shooter Jennings	25271	2022-05-12	0
Lonnie Plaxico	25272	2022-05-12	0
Danny Diablo feat. Ill-Bill & Everlast of La Coka Nostra	25273	2022-05-12	0
Syd Barrett	25274	2022-05-12	0
Caesars	25275	2022-05-12	0
Rakim feat. Maino_ Tracey Horton	25276	2022-05-12	0
Docenterna	25277	2022-05-12	0
Bermuda Triangle	25278	2022-05-12	0
Susan Gritton / Magdalena Kozená / Gabrieli Players / Paul McCreesh	25279	2022-05-12	0
House Of Pain	25280	2022-05-12	0
Bobby Goldsboro	25281	2022-05-12	0
Good Shoes	25282	2022-05-12	0
Blue Murder	25283	2022-05-12	0
Ellay Khule a.k.a. Rifleman	25284	2022-05-12	0
Bruce Katz Band	25285	2022-05-12	0
Gramercy Arms	25286	2022-05-12	0
Glenn Hughes	25287	2022-05-12	0
Wishbone Ash	25288	2022-05-12	0
Improbable People	25289	2022-05-12	0
Cirez D	25290	2022-05-12	0
Mr. Sche	25291	2022-05-12	0
The Hot Puppies	25292	2022-05-12	0
Looking Forward	25293	2022-05-12	0
Sheep on Drugs	25294	2022-05-12	0
Patti Smith	25295	2022-05-12	0
Bass Mekanik	25296	2022-05-12	0
Pyranja	25297	2022-05-12	0
Groove Coverage	25298	2022-05-12	0
Kenny Loggins;Jim Messina	25299	2022-05-12	0
EMBASSY	25300	2022-05-12	0
Diamond D	25301	2022-05-12	0
Jan Garbarek	25302	2022-05-12	0
London Philharmonic Orchestra	25303	2022-05-12	0
Chencha Berrinches	25304	2022-05-12	0
Earth Nation	25305	2022-05-12	0
Charmaine	25306	2022-05-12	0
Annie Blanchard	25307	2022-05-12	0
Sudden Death	25308	2022-05-12	0
Clp	25309	2022-05-12	0
I Gufi	25310	2022-05-12	0
Cultural Roots	25311	2022-05-12	0
Michael Forzza	25312	2022-05-12	0
Toyland	25313	2022-05-12	0
Lab°	25314	2022-05-12	0
Silke Frost	25315	2022-05-12	0
Mr. Lee	25317	2022-05-12	0
Itzhak Perlman/Pinchas Zukerman	25318	2022-05-12	0
Saturday's Heroes	25319	2022-05-12	0
Fruko Y Sus Tesos	25320	2022-05-12	0
Sven-R-G_ Bass-T	25321	2022-05-12	0
Sunburn In Cyprus	25322	2022-05-12	0
Chaim Tannenbaum	25323	2022-05-12	0
Albergo Intergalattico Spaziale	25324	2022-05-12	0
Jongo Trio	25325	2022-05-12	0
The Merseybeats	25326	2022-05-12	0
Thee Midniters	25327	2022-05-12	0
Malachi	25328	2022-05-12	0
Messy Marv	25329	2022-05-12	0
Taking Pictures	25330	2022-05-12	0
Henry Fiol	25331	2022-05-12	0
Los Fabulosos	25332	2022-05-12	0
Tim Rayborn	25333	2022-05-12	0
Dob Russkin	25334	2022-05-12	0
Tegan Northwood	25335	2022-05-12	0
This Is Hell	25336	2022-05-12	0
Algunos Hombres Buenos	25337	2022-05-12	0
Old 97's	25338	2022-05-12	0
The Pazant Brothers	25339	2022-05-12	0
Frode Gjerstad Trio	25340	2022-05-12	0
Julien creance	25341	2022-05-12	0
Deep Blue	25342	2022-05-12	0
Melba Montgomery	25343	2022-05-12	0
Elf Power	25344	2022-05-12	0
Josh Groban	25345	2022-05-12	0
The Mock Turtles	25346	2022-05-12	0
Nosfell	25347	2022-05-12	0
Rozza	25348	2022-05-12	0
Pram	25349	2022-05-12	0
Eftos	25350	2022-05-12	0
Danielle Bollinger	25351	2022-05-12	0
Rene Froger	25352	2022-05-12	0
Mojo Nixon	25353	2022-05-12	0
John Heffron	25354	2022-05-12	0
Bongzilla	25355	2022-05-12	0
Cryonic Temple	25356	2022-05-12	0
El Guapo Stuntteam	25357	2022-05-12	0
Dino MC 47	25358	2022-05-12	0
Flipper	25359	2022-05-12	0
Fragma	25360	2022-05-12	0
The Albion Dance Band	25361	2022-05-12	0
Simon Says	25362	2022-05-12	0
Solitary Experiments	25363	2022-05-12	0
Buddy Greco	25364	2022-05-12	0
Kid Loco/Sistema	25365	2022-05-12	0
Keenhouse	25366	2022-05-12	0
Noumena	25367	2022-05-12	0
Simply Red	25368	2022-05-12	0
Fletcher Henderson & His Orchestra	25369	2022-05-12	0
Blackness	25370	2022-05-12	0
Lords Of The New Church	25371	2022-05-12	0
Christophe Maé	25372	2022-05-12	0
The Five Crowns	25373	2022-05-12	0
Jay-Z/ Linkin Park	25374	2022-05-12	0
Burn Down Rome	25375	2022-05-12	0
Kenny Hayes	25376	2022-05-12	0
Rabih Abou-Khalil	25377	2022-05-12	0
La Barbería Del Sur	25378	2022-05-12	0
Goldfinger	25379	2022-05-12	0
Shinjuku Thief	25380	2022-05-12	0
Whistler	25381	2022-05-12	0
be your own PET	25382	2022-05-12	0
B-Tribe	25383	2022-05-12	0
Eyes Set to Kill	25384	2022-05-12	0
Ward 21	25385	2022-05-12	0
George Friedrich Handel	25386	2022-05-12	0
Bitch Alert	25387	2022-05-12	0
Mick Clarke_ Lou Martin	25388	2022-05-12	0
Sugarman Three	25389	2022-05-12	0
DJ T-Rock	25390	2022-05-12	0
Just Jack	25391	2022-05-12	0
Vaughn Monroe	25392	2022-05-12	0
Fattburger	25393	2022-05-12	0
Pro Arte Orchestra Of London / Michael Davis / Alexandre Desplat	25394	2022-05-12	0
Black 47	25395	2022-05-12	0
Nardo Ranks	25396	2022-05-12	0
Tieum vs Unexist	25397	2022-05-12	0
Cheb Mami - K-Maro	25398	2022-05-12	0
Balla	25399	2022-05-12	0
Pery Ribeiro	25400	2022-05-12	0
Virgos Merlot	25401	2022-05-12	0
Ronan Hardiman	25402	2022-05-12	0
L.A.V.I	25403	2022-05-12	0
Abigail Washburn	25404	2022-05-12	0
Darcelys	25405	2022-05-12	0
Dug Pinnick	25406	2022-05-12	0
Chantal Goya	25407	2022-05-12	0
MC Solaar	25408	2022-05-12	0
Lester Bowie	25409	2022-05-12	0
Artifacts	25410	2022-05-12	0
Tuscadero	25411	2022-05-12	0
Inkubus Sukkubus	25412	2022-05-12	0
Katya Chorover	25413	2022-05-12	0
Jewel	25414	2022-05-12	0
Sivion	25415	2022-05-12	0
Sunship Feat. Charlise	25416	2022-05-12	0
The Archies	25417	2022-05-12	0
Tuesday	25418	2022-05-12	0
Messy Marv & Marvaless	25419	2022-05-12	0
Ansell Collins	25420	2022-05-12	0
Louis Andriessen	25421	2022-05-12	0
City	25422	2022-05-12	0
Lauryn Hill	25423	2022-05-12	0
Sugar Mountain	25424	2022-05-12	0
Urbanize feat. Honke	25425	2022-05-12	0
3ème Oeil	25426	2022-05-12	0
Cathedral	25427	2022-05-12	0
Longing For Tomorrow	25428	2022-05-12	0
Fiend	25429	2022-05-12	0
The Other	25430	2022-05-12	0
Gary Primich	25431	2022-05-12	0
Cajun Dance Party	25432	2022-05-12	0
Tony Rivers & The Castaways	25433	2022-05-12	0
Nellie McKay	25434	2022-05-12	0
Killah Priest	25435	2022-05-12	0
Chet Atkins And Doc Watson	25436	2022-05-12	0
Sierra Leone's Refugee All Stars	25437	2022-05-12	0
Maddy Prior & Tim Hart	25438	2022-05-12	0
The Humpers	25439	2022-05-12	0
Alice Peacock	25440	2022-05-12	0
Spektrum	25441	2022-05-12	0
Liederjan	25442	2022-05-12	0
Skapsom	25443	2022-05-12	0
Dexy's Midnight Runners	25444	2022-05-12	0
Katerine	25445	2022-05-12	0
Biquini Cavadao	25446	2022-05-12	0
Funki Porcini	25447	2022-05-12	0
Royal Crown Revue	25448	2022-05-12	0
Sacred Hoop	25449	2022-05-12	0
The Temptations	25450	2022-05-12	0
Ragheb Alama	25451	2022-05-12	0
Michalis Koumbios	25452	2022-05-12	0
Blind Willie Johnson	25453	2022-05-12	0
San Quinn and T-Nutty	25454	2022-05-12	0
DeadSwans	25455	2022-05-12	0
Void Construct	25456	2022-05-12	0
Mastodon	25457	2022-05-12	0
Blondie	25458	2022-05-12	0
Edu Lobo	25459	2022-05-12	0
Los Vegetales	25460	2022-05-12	0
Tiffany Giardina	25461	2022-05-12	0
Lycia	25462	2022-05-12	0
Lee Ann Womack	25463	2022-05-12	0
Lal and Norma Warterson	25464	2022-05-12	0
Movado	25465	2022-05-12	0
Rom.C & Remakerz	25466	2022-05-12	0
Valen Hsu	25467	2022-05-12	0
Gli Inquilini	25468	2022-05-12	0
F.O.	25469	2022-05-12	0
Carlos Giffoni	25470	2022-05-12	0
Stupid Fresh	25471	2022-05-12	0
Zarah Leander	25472	2022-05-12	0
Roger Miret & The Disasters	25473	2022-05-12	0
David Fridlund	25474	2022-05-12	0
Pam Thum	25475	2022-05-12	0
Jack Ketch And The Crowmen	25476	2022-05-12	0
Lucille Hegamin	25477	2022-05-12	0
Sylvia Tosun	25478	2022-05-12	0
Tea Time	25479	2022-05-12	0
Cattle Decapitation	25480	2022-05-12	0
George Smallwood	25481	2022-05-12	0
Kreators	25482	2022-05-12	0
Aquasky & Meat Katie w/ Lucky Cat	25483	2022-05-12	0
Nina Nastasia	25484	2022-05-12	0
Charlie Mole	25485	2022-05-12	0
Interstate	25486	2022-05-12	0
Schneider Tm	25487	2022-05-12	0
Cueshé	25488	2022-05-12	0
Tinariwen	25489	2022-05-12	0
The Revels	25490	2022-05-12	0
Kotipelto	25491	2022-05-12	0
RareForm Vs Total Science	25492	2022-05-12	0
Sex Machine	25493	2022-05-12	0
Peatbog Faeries	25494	2022-05-12	0
Ripchord	25495	2022-05-12	0
Polly Paulusma	25496	2022-05-12	0
Jan Wayne	25497	2022-05-12	0
The Poise Rite	25498	2022-05-12	0
Elektrochemie	25499	2022-05-12	0
Breakestra	25500	2022-05-12	0
Hank Jones	25501	2022-05-12	0
Cold Pumas and Brassica	25502	2022-05-12	0
Runaway Cab	25503	2022-05-12	0
Daz Dillnger	25504	2022-05-12	0
Jan Wayne vs. RainDropz!	25505	2022-05-12	0
Lys	25506	2022-05-12	0
Rafael Cortes	25507	2022-05-12	0
Terror Squad / Tony Sunshine / Armageddon	25508	2022-05-12	0
Happy The Man	25509	2022-05-12	0
Joe Liggins & His Honeydrippers	25510	2022-05-12	0
Fra Lippo Lippi	25511	2022-05-12	0
The Nimmo Brothers	25512	2022-05-12	0
Joe Turner	25513	2022-05-12	0
The King Khan & BBQ Show	25514	2022-05-12	0
Stars on 45 feat. Discomaniacs	25515	2022-05-12	0
Christine Fellows	25516	2022-05-12	0
Talib Kweli / Hi-Tek	25517	2022-05-12	0
Giovanni Malatesta	25518	2022-05-12	0
Kiss	25519	2022-05-12	0
The Pierces	25520	2022-05-12	0
Minus 8	25521	2022-05-12	0
Hedgehoppers Anonymous	25522	2022-05-12	0
Nuclear Blast Allstars	25523	2022-05-12	0
Oldelaf et Monsieur D	25524	2022-05-12	0
Kelly Llorenna	25525	2022-05-12	0
Pink Spiders_ The	25526	2022-05-12	0
Simple Acoustic Trio	25527	2022-05-12	0
The Association	25528	2022-05-12	0
Cowboy Troy (Featuring Big & Rich)	25529	2022-05-12	0
Four Letter Word	25530	2022-05-12	0
Seventeen Evergreen	25531	2022-05-12	0
Ben Gold	25532	2022-05-12	0
Otros Aires	25533	2022-05-12	0
Mainstay	25534	2022-05-12	0
New Trolls	25535	2022-05-12	0
Märtini Brös	25536	2022-05-12	0
House of Broken Promises	25537	2022-05-12	0
Síntesis	25538	2022-05-12	0
By Divine Right	25539	2022-05-12	0
Woman In Panic	25540	2022-05-12	0
Bob Wills	25541	2022-05-12	0
Vox Celesta	25542	2022-05-12	0
I Was A King	25543	2022-05-12	0
Panic DHH	25544	2022-05-12	0
Twinkle Brothers	25545	2022-05-12	0
Action Reaction	25546	2022-05-12	0
Nurzery [Rhymes]	25547	2022-05-12	0
Pohlmann.	25548	2022-05-12	0
Jawbreaker	25549	2022-05-12	0
X-Perience / Joachim Witt	25550	2022-05-12	0
Spektre	25551	2022-05-12	0
808 State	25552	2022-05-12	0
Sneeze	25553	2022-05-12	0
Georg Gabler	25554	2022-05-12	0
Autumnblaze	25555	2022-05-12	0
Salvador	25556	2022-05-12	0
B. R. Gunna	25557	2022-05-12	0
Small Arms Dealer	25558	2022-05-12	0
Boikot	25559	2022-05-12	0
Fanny	25560	2022-05-12	0
The Veronicas	25561	2022-05-12	0
Big Electric Cat	25562	2022-05-12	0
Los Traileros Del Norte	25563	2022-05-12	0
Anastasio Dum	25564	2022-05-12	0
Papa Charlie Jackson	25565	2022-05-12	0
Monster Mike Welch	25566	2022-05-12	0
Israel Philharmonic Orchestra	25567	2022-05-12	0
Ian Betts	25568	2022-05-12	0
Ressu Redford ja Sarita	25569	2022-05-12	0
Sergio Mendes & Brasil '66	25570	2022-05-12	0
Pivot	25571	2022-05-12	0
Pan.a.ce.a	25572	2022-05-12	0
Silvestre Dangond & Juancho de La Espriella	25573	2022-05-12	0
Matt Borghi	25574	2022-05-12	0
The Aquatones	25575	2022-05-12	0
Anoraak	25576	2022-05-12	0
Skeptics	25577	2022-05-12	0
Plummet	25578	2022-05-12	0
Bobby Brown & The Curios	25579	2022-05-12	0
Martin Landsky	25580	2022-05-12	0
Broken Time Orchestra	25581	2022-05-12	0
Empty Trash	25582	2022-05-12	0
The Backyardigans	25583	2022-05-12	0
Plump DJs	25584	2022-05-12	0
Gamat 3000	25585	2022-05-12	0
Merche	25586	2022-05-12	0
José Malhoa	25587	2022-05-12	0
Blind Willie McTell	25588	2022-05-12	0
Josh Canova	25589	2022-05-12	0
Octagen & MIDOR	25590	2022-05-12	0
Todd Barry	25591	2022-05-12	0
Violent Femmes	25592	2022-05-12	0
Ottavo Padiglione	25593	2022-05-12	0
Slave	25594	2022-05-12	0
Les Philippes	25595	2022-05-12	0
Jamie O'Neal	25596	2022-05-12	0
Iron Sy	25597	2022-05-12	0
Bodo Wartke	25598	2022-05-12	0
Nifelheim	25599	2022-05-12	0
Parken	25600	2022-05-12	0
Melanie Doane	25601	2022-05-12	0
Sophie B. Hawkins	25602	2022-05-12	0
Marlene	25603	2022-05-12	0
If There Is Something	25604	2022-05-12	0
Wildhearts	25605	2022-05-12	0
Airi L	25606	2022-05-12	0
Alain Morisod	25607	2022-05-12	0
Ohm Guru	25608	2022-05-12	0
Liane Foly	25609	2022-05-12	0
Konflict	25610	2022-05-12	0
El Jesus de Magico	25611	2022-05-12	0
Roger Tillison	25612	2022-05-12	0
Sidonio Pereira	25613	2022-05-12	0
Haberdashery	25614	2022-05-12	0
Dreams Come True	25615	2022-05-12	0
Rally	25616	2022-05-12	0
The Soul Children	25617	2022-05-12	0
Excepter	25618	2022-05-12	0
David Banner	25619	2022-05-12	0
New Order	25620	2022-05-12	0
Kirk Brandon	25621	2022-05-12	0
Deniece Williams	25622	2022-05-12	0
Stephen Fretwell	25623	2022-05-12	0
MC Lyte	25624	2022-05-12	0
Heredeiros Da Crus	25625	2022-05-12	0
Mood II Swing	25626	2022-05-12	0
The Bar-Kays	25627	2022-05-12	0
The Neckbones	25628	2022-05-12	0
Årabrot	25629	2022-05-12	0
Yulduz Usmanova	25630	2022-05-12	0
Les Dales Hawerchuk	25631	2022-05-12	0
The Les Claypool Frog Brigade	25632	2022-05-12	0
Andres Cabas	25633	2022-05-12	0
Nanuchka	25634	2022-05-12	0
María de Lourdes	25635	2022-05-12	0
Sun Dial	25636	2022-05-12	0
Willie Clancy	25637	2022-05-12	0
Pee Wee Crayton	25638	2022-05-12	0
Ronan O Snodaigh	25639	2022-05-12	0
Spare Lead	25640	2022-05-12	0
His Name Is Alive	25641	2022-05-12	0
Alquimia	25642	2022-05-12	0
Indigenous	25643	2022-05-12	0
Tommy Alverson_ Leon Rausch	25644	2022-05-12	0
Rivermaya	25645	2022-05-12	0
Randy Crawford	25646	2022-05-12	0
Kadim Al Sahir	25647	2022-05-12	0
DJ Mitsu The Beats	25648	2022-05-12	0
Turbulence	25649	2022-05-12	0
Minnesota Orchestra	25650	2022-05-12	0
Skitsystem	25651	2022-05-12	0
Los Peces	25652	2022-05-12	0
Two-Minute Miracles	25653	2022-05-12	0
Prudence Liew	25654	2022-05-12	0
Aaron Hedges & Dan D	25655	2022-05-12	0
Zetan Spore	25656	2022-05-12	0
Lloyd Parks	25657	2022-05-12	0
The Red Jumpsuit Apparatus	25658	2022-05-12	0
Ghetto Soldiers	25659	2022-05-12	0
Ana Nikolic	25660	2022-05-12	0
MV & EE	25661	2022-05-12	0
Clint Mansell	25662	2022-05-12	0
Suzi Quatro	25663	2022-05-12	0
Blind Boys of Alabama	25664	2022-05-12	0
Preacher	25665	2022-05-12	0
Don Johnson	25666	2022-05-12	0
Grain	25667	2022-05-12	0
Asio Kids	25668	2022-05-12	0
Howling Diablos	25669	2022-05-12	0
Belle and Sebastian	25670	2022-05-12	0
Les Petits Pilous	25671	2022-05-12	0
BWO	25672	2022-05-12	0
Bow Wow feat. Trey Songz	25673	2022-05-12	0
Hugo Strasser Und Sein Tanzorchester	25674	2022-05-12	0
Ganxsta Nip	25675	2022-05-12	0
The Forester Sisters	25676	2022-05-12	0
Sissy	25677	2022-05-12	0
Davie Allan and the Arrows	25678	2022-05-12	0
Infinite Livez feat. Barry Convex_ Marmoset and Mrs Convex	25679	2022-05-12	0
Britta Persson	25680	2022-05-12	0
Angels and Airwaves	25681	2022-05-12	0
Deep Purple	25682	2022-05-12	0
Fats Domino	25683	2022-05-12	0
Kate Farrow	25684	2022-05-12	0
Garbage	25685	2022-05-12	0
Marie et Les Garcons	25686	2022-05-12	0
Lacy J. Dalton	25687	2022-05-12	0
Jose Fajardo	25688	2022-05-12	0
The Special Goodness	25689	2022-05-12	0
NewFound Road	25690	2022-05-12	0
Kelta	25691	2022-05-12	0
Christine Perfect	25692	2022-05-12	0
galactic cowboys	25693	2022-05-12	0
Necronomicon	25694	2022-05-12	0
Szwagierkolaska	25695	2022-05-12	0
Levitation	25696	2022-05-12	0
Soul Seekers featuring Harvey Watkins_ Jr.	25697	2022-05-12	0
Jimmy & Mama Yancey	25698	2022-05-12	0
Ozone Cocktail	25699	2022-05-12	0
Fine Young Cannibals	25700	2022-05-12	0
Nu Jerzey Devil	25701	2022-05-12	0
Tony Faline	25702	2022-05-12	0
Reverend Gary Davis	25703	2022-05-12	0
Bob Crosby and the Bobcats	25704	2022-05-12	0
Renaissance	25705	2022-05-12	0
Plastique de Rêve	25706	2022-05-12	0
The Lilac Time	25707	2022-05-12	0
Binomio de Oro	25708	2022-05-12	0
Cedar Walton	25709	2022-05-12	0
Barry Brown	25710	2022-05-12	0
Pupo	25711	2022-05-12	0
My Hero Is Me	25712	2022-05-12	0
Espresso del Lago	25713	2022-05-12	0
Insyderz	25714	2022-05-12	0
Changing Faces	25715	2022-05-12	0
EverAfter	25716	2022-05-12	0
Jackie De Shannon	25717	2022-05-12	0
Anna Vissi;Nikos Karvelas	25718	2022-05-12	0
Fausto Papetti	25719	2022-05-12	0
Einstuerzende Neubauten	25720	2022-05-12	0
Rolo vs Raul Lokura	25721	2022-05-12	0
The Malibooz	25722	2022-05-12	0
Quella Vecchia Locanda	25723	2022-05-12	0
Paul Butterfield's Better Days	25724	2022-05-12	0
Line Renaud	25725	2022-05-12	0
Age Of Chance	25726	2022-05-12	0
Generation X featuring Billy Idol	25727	2022-05-12	0
40 Below Summer	25728	2022-05-12	0
Van Dyke Parks	25729	2022-05-12	0
Mark Hummel	25730	2022-05-12	0
[kaleidoskop]	25731	2022-05-12	0
Ruxpin	25732	2022-05-12	0
Starship	25733	2022-05-12	0
Cultus Sanguine	25734	2022-05-12	0
Myriam Makeba	25735	2022-05-12	0
Bosson	25736	2022-05-12	0
Gama Bomb	25737	2022-05-12	0
Dave Holland_ Chris Potter_ Robin Eubanks_ Steve Nelson_ Billy Kilson	25738	2022-05-12	0
Slick Rick	25739	2022-05-12	0
The Dreadful Yawns	25740	2022-05-12	0
Milemarker	25741	2022-05-12	0
Peace_ Love & Pitbulls	25742	2022-05-12	0
Ryan Malcolm	25743	2022-05-12	0
Natalie Walker	25744	2022-05-12	0
blessthefall	25745	2022-05-12	0
Delaney & Bonnie & Friends	25746	2022-05-12	0
Jamie Foxx	25747	2022-05-12	0
World Leader Pretend	25748	2022-05-12	0
The Bees	25749	2022-05-12	0
Armando Manzanero	25750	2022-05-12	0
To Overflow Evidence	25751	2022-05-12	0
Los Enemigos	25752	2022-05-12	0
Dave Evans	25753	2022-05-12	0
Jeff Foxworthy/Bill Engvall/Ron White/Larry The Cable Guy	25754	2022-05-12	0
Daycare Swindlers	25755	2022-05-12	0
F5	25756	2022-05-12	0
Sly & The Family Stone	25757	2022-05-12	0
Ivy	25758	2022-05-12	0
Big Brother & The Holding Company	25759	2022-05-12	0
Christos Dantis	25760	2022-05-12	0
Blazer	25761	2022-05-12	0
Bill Engvall	25762	2022-05-12	0
Sonic Youth	25763	2022-05-12	0
Pretty Maids	25764	2022-05-12	0
West End Orchestra & Singers	25765	2022-05-12	0
La Camorra	25766	2022-05-12	0
Halford	25767	2022-05-12	0
Hot Tuna	25768	2022-05-12	0
Jesse Malin	25769	2022-05-12	0
Jokers Of The Scene	25770	2022-05-12	0
A Day In Black and White	25771	2022-05-12	0
Kitty Margolis	25772	2022-05-12	0
Electric Frankenstein	25773	2022-05-12	0
Soilent Green	25774	2022-05-12	0
Piero Esteriore	25775	2022-05-12	0
Cecil Gant	25776	2022-05-12	0
Brighter Death Now	25777	2022-05-12	0
Kurrupt & Kris Kelly	25778	2022-05-12	0
Spider Murphy Gang	25779	2022-05-12	0
The Zen Tricksters	25780	2022-05-12	0
Tito Schipa	25781	2022-05-12	0
Al Cook	25782	2022-05-12	0
Terry Linen	25783	2022-05-12	0
Chris Cummings	25784	2022-05-12	0
Nueva Vulcano	25785	2022-05-12	0
Münchener Freiheit	25786	2022-05-12	0
13 Cats	25787	2022-05-12	0
Sightings	25788	2022-05-12	0
Gonzoe	25789	2022-05-12	0
Crazy World Of Arthur Brown	25790	2022-05-12	0
Mike Bloomfield	25791	2022-05-12	0
Larry Coryell	25792	2022-05-12	0
Beautiful Lies	25793	2022-05-12	0
DJ Shortstop	25794	2022-05-12	0
The Hippy Boys	25795	2022-05-12	0
The Spill Canvas	25796	2022-05-12	0
Technicolor with Flowchart	25797	2022-05-12	0
JOSEF LOCKE & ORCHESTRA	25798	2022-05-12	0
Marilyn Manson	25799	2022-05-12	0
Thelonius Monk	25800	2022-05-12	0
Roger Cicero	25801	2022-05-12	0
Straight Faced	25802	2022-05-12	0
Concrete Djz	25803	2022-05-12	0
Ava Inferi	25804	2022-05-12	0
Ball in the House	25805	2022-05-12	0
Karan Casey	25806	2022-05-12	0
The Pop Rivets	25807	2022-05-12	0
The Stan Getz Quintet	25808	2022-05-12	0
Sl2	25809	2022-05-12	0
Nick Alexander	25810	2022-05-12	0
Fairground Attraction	25811	2022-05-12	0
Willy Chirino	25812	2022-05-12	0
Madilu System	25813	2022-05-12	0
Free Spirit	25814	2022-05-12	0
Delirious?	25815	2022-05-12	0
Frenkie	25816	2022-05-12	0
Living Colour	25817	2022-05-12	0
Cosmic Gate feat. Kyler England	25818	2022-05-12	0
Angel Romero	25819	2022-05-12	0
The Pink Snowflakes	25820	2022-05-12	0
Chad Smith's Bombastic Meatbats	25821	2022-05-12	0
The Chameleons	25822	2022-05-12	0
DT8 Project	25823	2022-05-12	0
The Brand New Heavies	25824	2022-05-12	0
Moussa Clarke	25825	2022-05-12	0
Blaudzun	25826	2022-05-12	0
Charlie Brown Jr	25827	2022-05-12	0
Daphne	25828	2022-05-12	0
Gossip	25829	2022-05-12	0
Nimal	25830	2022-05-12	0
Andre Crom	25831	2022-05-12	0
Walter Brennan	25832	2022-05-12	0
Michael Schenker Group	25833	2022-05-12	0
Co-Ed	25834	2022-05-12	0
Frank Hutchison	25835	2022-05-12	0
New Buffalo	25836	2022-05-12	0
Kay Starr	25837	2022-05-12	0
General Echo	25838	2022-05-12	0
James Yuill	25839	2022-05-12	0
Rehab	25840	2022-05-12	0
Charles Schillings	25841	2022-05-12	0
Rainer Maria	25842	2022-05-12	0
2 Player_D.J. Vadim	25843	2022-05-12	0
The Angelic Gospel Singers & The Dixie Hummingbirds	25844	2022-05-12	0
Cecil Leuter	25845	2022-05-12	0
The Jane Shermans	25846	2022-05-12	0
Hello Sailor	25847	2022-05-12	0
Hanging Garden	25848	2022-05-12	0
Alex Hentze	25849	2022-05-12	0
Fatals Picards	25850	2022-05-12	0
Yvonne Catterfeld	25851	2022-05-12	0
The Jimmy Castor Bunch	25852	2022-05-12	0
Mitch Ryder	25853	2022-05-12	0
Strojovna 07	25854	2022-05-12	0
Billy Grammer	25855	2022-05-12	0
Peter Broderick	25856	2022-05-12	0
Wynton Marsalis Septet	25857	2022-05-12	0
Danny De Munk	25858	2022-05-12	0
Armin van Buuren feat. Sharon den Adel	25859	2022-05-12	0
LOUIS JORDAN	25860	2022-05-12	0
Jessica Simpson	25861	2022-05-12	0
Llwybr Llaethog	25862	2022-05-12	0
Charlotte Diamond	25863	2022-05-12	0
Prime STH	25864	2022-05-12	0
Tristan Prettyman	25865	2022-05-12	0
Brother Sun Sister Moon	25866	2022-05-12	0
Antonio Carlos Jobim	25867	2022-05-12	0
Doug Wimbish	25868	2022-05-12	0
Manhattan Transfer	25869	2022-05-12	0
DJ Magic Mike	25870	2022-05-12	0
Mark Eitzel	25871	2022-05-12	0
Mr. Lucci	25872	2022-05-12	0
Peter Metro	25873	2022-05-12	0
Poison Control Center	25874	2022-05-12	0
Lavay Smith & Her Red Hot Skillet Lickers	25875	2022-05-12	0
Kenny Dope	25876	2022-05-12	0
John Jackson	25877	2022-05-12	0
Silvia Telles	25878	2022-05-12	0
Fuzzy Logic	25879	2022-05-12	0
Colossal	25880	2022-05-12	0
The Proclaimers	25881	2022-05-12	0
Mortiis	25882	2022-05-12	0
Karen Peck & New River	25883	2022-05-12	0
Dean Dirg	25884	2022-05-12	0
Calima	25885	2022-05-12	0
Twin Atlantic	25886	2022-05-12	0
Welle: Erdball	25887	2022-05-12	0
Heloise & the Savoir Faire	25888	2022-05-12	0
Alain Bashung	25889	2022-05-12	0
Johnny Moore	25890	2022-05-12	0
Steppenwolf	25891	2022-05-12	0
Howie Day	25892	2022-05-12	0
The Gun Club	25893	2022-05-12	0
Andreus	25894	2022-05-12	0
Mentallo and The Fixer	25895	2022-05-12	0
sea of sin	25896	2022-05-12	0
Miguel Mateos - Zas	25897	2022-05-12	0
Jean-Yves Thibaudet	25898	2022-05-12	0
Edwin Hawkins	25899	2022-05-12	0
Royal Melody	25900	2022-05-12	0
Fama	25901	2022-05-12	0
Fantasia featuring Missy Elliot	25902	2022-05-12	0
Fragil	25903	2022-05-12	0
Dub Pistols feat. Terry Hall	25904	2022-05-12	0
Kaiser Chiefs	25905	2022-05-12	0
Mercury Rev	25906	2022-05-12	0
Devil Sold His Soul	25907	2022-05-12	0
& And Oceans	25908	2022-05-12	0
Kiran Murti	25909	2022-05-12	0
Alberto Fortis	25910	2022-05-12	0
Crash	25911	2022-05-12	0
Tamia	25912	2022-05-12	0
Guasones	25913	2022-05-12	0
Kite Flying Society	25914	2022-05-12	0
Munga	25915	2022-05-12	0
The Clash	25916	2022-05-12	0
Legiao Urbana	25917	2022-05-12	0
Lost Acapulco	25918	2022-05-12	0
Antonio Vivaldi	25919	2022-05-12	0
Sérgio Godinho	25920	2022-05-12	0
The Koobas	25921	2022-05-12	0
Moodswings	25922	2022-05-12	0
Ashes to Ashes	25923	2022-05-12	0
D'espairs Ray	25924	2022-05-12	0
Xavier Caféïne	25925	2022-05-12	0
BK	25926	2022-05-12	0
Ishmael	25927	2022-05-12	0
Free Loan Investments	25928	2022-05-12	0
Rhymin Simon	25929	2022-05-12	0
Craig G	25930	2022-05-12	0
Mark Otten	25931	2022-05-12	0
Dixie Dregs	25932	2022-05-12	0
Annet Artani	25933	2022-05-12	0
The Mission	25934	2022-05-12	0
Monica & Monica	25935	2022-05-12	0
Espen Hana	25936	2022-05-12	0
Mungo	25937	2022-05-12	0
Team Sleep	25938	2022-05-12	0
Emalkay	25939	2022-05-12	0
Chihei Hatakeyama	25940	2022-05-12	0
The House Crew	25941	2022-05-12	0
The xx	25942	2022-05-12	0
NNENNA FREELON	25943	2022-05-12	0
V/A Friction Records	25944	2022-05-12	0
Vice On Victory	25945	2022-05-12	0
Marah	25946	2022-05-12	0
Kiko Veneno	25947	2022-05-12	0
You Me and The Atom Bomb	25948	2022-05-12	0
Hex Static & Tom Middleton	25949	2022-05-12	0
Downliners Sect	25950	2022-05-12	0
Chairmen Of The Board	25951	2022-05-12	0
Il Parto Delle Nuvole Pesanti	25952	2022-05-12	0
Equalizers	25953	2022-05-12	0
Solade	25954	2022-05-12	0
Martin Orford	25955	2022-05-12	0
Icewater	25956	2022-05-12	0
Cream	25957	2022-05-12	0
Lethal Bizzle	25958	2022-05-12	0
Roger Whittaker	25959	2022-05-12	0
David Olney	25960	2022-05-12	0
Travolta	25961	2022-05-12	0
Electric Eel Shock	25962	2022-05-12	0
Hocus Pocus / Omar	25963	2022-05-12	0
Zumjay	25964	2022-05-12	0
Patti LuPone / Mark Syers / Mandy Patinkin / Various Artists	25965	2022-05-12	0
Tru	25966	2022-05-12	0
John Michael Talbot	25967	2022-05-12	0
Taras	25968	2022-05-12	0
Secos And Molhados	25969	2022-05-12	0
Cut Copy	25970	2022-05-12	0
Sebastian Krämer	25971	2022-05-12	0
Snider_ Todd	25972	2022-05-12	0
Johnny Moped	25973	2022-05-12	0
Sex In Dallas feat. Biladoll	25974	2022-05-12	0
Die Skeptiker	25975	2022-05-12	0
Che Sudaka	25976	2022-05-12	0
Hisham Abbas	25977	2022-05-12	0
Ernest Tubb	25978	2022-05-12	0
Gutbucket	25979	2022-05-12	0
Neil Finn	25980	2022-05-12	0
Eight Frozen Modules	25981	2022-05-12	0
Artie Shaw	25982	2022-05-12	0
Yahir	25983	2022-05-12	0
Unshine	25984	2022-05-12	0
Foster & Allen	25985	2022-05-12	0
The Answering Machine	25986	2022-05-12	0
Johnny Copeland	25987	2022-05-12	0
Bong-ra	25988	2022-05-12	0
Andrew Lloyd Webber	25989	2022-05-12	0
Sons And Daughters	25990	2022-05-12	0
Suicidal Romance	25991	2022-05-12	0
Oscar Mulero	25992	2022-05-12	0
Stir	25993	2022-05-12	0
Office	25994	2022-05-12	0
Dave Angel	25995	2022-05-12	0
Mood Ruff	25996	2022-05-12	0
Alastis	25997	2022-05-12	0
Frameshift	25998	2022-05-12	0
The One Ensemble Of Daniel Padden	25999	2022-05-12	0
Global Deejays	26000	2022-05-12	0
Mackie Ranks	26001	2022-05-12	0
Silkie	26002	2022-05-12	0
Ray Anthony	26003	2022-05-12	0
Centro13	26004	2022-05-12	0
Rúzsa Magdi	26005	2022-05-12	0
Klubbingman	26006	2022-05-12	0
The Rural Alberta Advantage	26007	2022-05-12	0
Undertakin' Daddies	26008	2022-05-12	0
Nikos Xilouris	26009	2022-05-12	0
Eggshell Egoz	26010	2022-05-12	0
Highway 101	26011	2022-05-12	0
Blur	26012	2022-05-12	0
Grav	26013	2022-05-12	0
Krzysztof Penderecki/London Symphony Orchestra	26014	2022-05-12	0
Wamdue Project Featuring Jonathan Mendelsohn	26015	2022-05-12	0
Pigeon John	26016	2022-05-12	0
Taxpayer	26017	2022-05-12	0
Save Ferris	26018	2022-05-12	0
Debbie Davies	26019	2022-05-12	0
Jetplane Landing	26020	2022-05-12	0
Airged L'amh	26021	2022-05-12	0
The Devil Makes Three	26022	2022-05-12	0
Kany Garcia	26023	2022-05-12	0
Ray Lynch	26024	2022-05-12	0
CIRITH GORGOR	26025	2022-05-12	0
Space Frog;Duke	26026	2022-05-12	0
Throbbing Gristle	26027	2022-05-12	0
Gene Krupa & His Orchestra	26028	2022-05-12	0
Pirates Of The Mississippi	26029	2022-05-12	0
Murray Perahia;Sir Colin Davis;Symphonie Orchester des Bayerischen Rundfunks	26030	2022-05-12	0
East Side Beat	26031	2022-05-12	0
DJ Jorn	26032	2022-05-12	0
Haste The Day	26033	2022-05-12	0
Johan	26034	2022-05-12	0
Frankie Trumbauer & His Orchestra; featuirng Bix Beiderbecke and Eddie Lang	26035	2022-05-12	0
Brand New Sin	26036	2022-05-12	0
Pauline Oliveros	26037	2022-05-12	0
Memphis Jug Band	26038	2022-05-12	0
Melanii Diva	26039	2022-05-12	0
The Gaslamp Killer	26040	2022-05-12	0
Fehlfarben	26041	2022-05-12	0
Marco Parente	26042	2022-05-12	0
T'Pau	26043	2022-05-12	0
ALO	26044	2022-05-12	0
Stuck In The Sound	26045	2022-05-12	0
Lester Flatt & Earl Scruggs And The Stanley Brothers	26046	2022-05-12	0
Marvin & Johnny	26047	2022-05-12	0
Bless	26048	2022-05-12	0
Paul McCartney And Wings	26049	2022-05-12	0
Vijay Iyer/Mike Ladd	26050	2022-05-12	0
Nanci Griffith	26051	2022-05-12	0
Emre Aydin	26052	2022-05-12	0
Tapes n Tapes	26053	2022-05-12	0
Buck 65	26054	2022-05-12	0
Lost Boyz	26055	2022-05-12	0
Astroqueen	26056	2022-05-12	0
Choix	26057	2022-05-12	0
Todd Wolfe Band	26058	2022-05-12	0
Red Hot Chili Peppers	26059	2022-05-12	0
Chuck Strong	26060	2022-05-12	0
Chilled C'quence	26061	2022-05-12	0
Etron Fou Leloublan	26062	2022-05-12	0
Dorothy Norwood & The Mississippi Mass Choir	26063	2022-05-12	0
Oh No Ono	26064	2022-05-12	0
Damhnait Doyle	26065	2022-05-12	0
Joshua Redman	26066	2022-05-12	0
Dianne Reeves	26067	2022-05-12	0
Brenda Holloway	26068	2022-05-12	0
John Prine	26069	2022-05-12	0
Trim	26070	2022-05-12	0
Domina Noctis	26071	2022-05-12	0
Jaimy & Kenny D	26072	2022-05-12	0
Of Montreal	26073	2022-05-12	0
Shayne Ward	26074	2022-05-12	0
Invisible	26075	2022-05-12	0
Inês	26076	2022-05-12	0
Peter Pan Speedrock	26077	2022-05-12	0
Tom Tykwer_ Johnny Klimek_ Reinhold Heil	26078	2022-05-12	0
Herbie Nichols	26079	2022-05-12	0
Eugene Chadbourne and Jimmy Carl Black	26080	2022-05-12	0
Scratch Pet Land	26081	2022-05-12	0
Chic	26082	2022-05-12	0
Fred Hammond	26083	2022-05-12	0
Helloween	26084	2022-05-12	0
Eartha Kitt	26085	2022-05-12	0
Gabriella Cilmi	26086	2022-05-12	0
Lila Downs / Mariachi Juvenil de Tecalitlán	26087	2022-05-12	0
CDOASS	26088	2022-05-12	0
Franz Waxman_ Joel McNeely_ Royal Scottish National Orchestra	26089	2022-05-12	0
Carl Smith	26090	2022-05-12	0
Shub-Niggurath	26091	2022-05-12	0
Alison Limerick	26092	2022-05-12	0
Lucio Battisti	26093	2022-05-12	0
Zia	26094	2022-05-12	0
Count Basie Big Band	26095	2022-05-12	0
Debra Killings	26096	2022-05-12	0
MIDIFine Systems	26097	2022-05-12	0
1. Futurologischer Congress	26098	2022-05-12	0
Los Melodicos	26099	2022-05-12	0
Muriel Anderson	26100	2022-05-12	0
Javier Mendoza	26101	2022-05-12	0
Pat Benatar	26102	2022-05-12	0
Honeyrider	26103	2022-05-12	0
Bunny Wailer & The Reggaestra	26104	2022-05-12	0
Ultra X	26105	2022-05-12	0
Aesthetic Perfection	26106	2022-05-12	0
Parkway Drive	26107	2022-05-12	0
Karjalan Sissit	26108	2022-05-12	0
Hooverphonic	26109	2022-05-12	0
Bügsküll	26110	2022-05-12	0
Walt Wilkins	26111	2022-05-12	0
Boss Martians	26112	2022-05-12	0
Wendy & Lisa	26113	2022-05-12	0
Georgia Satellites	26114	2022-05-12	0
Susana Seivane	26115	2022-05-12	0
John Holm	26116	2022-05-12	0
Casus Belli	26117	2022-05-12	0
Babbie Mason	26118	2022-05-12	0
Shadows Fall	26119	2022-05-12	0
John Mooney	26120	2022-05-12	0
Guru Josh Project	26121	2022-05-12	0
Migraine	26122	2022-05-12	0
Grand Kalle Et l'African Jazz	26123	2022-05-12	0
First Blood	26124	2022-05-12	0
Orangez	26125	2022-05-12	0
G Unit feat. 50 Cent	26126	2022-05-12	0
Hush Arbors	26127	2022-05-12	0
Elvin Bishop	26128	2022-05-12	0
Vincenzo	26129	2022-05-12	0
LazyTown	26130	2022-05-12	0
Roy Milton	26131	2022-05-12	0
Sally	26132	2022-05-12	0
Steve Hill vs Technikal	26133	2022-05-12	0
Brandi Carlile	26134	2022-05-12	0
Tom Lehrer	26135	2022-05-12	0
Judy Rodman	26136	2022-05-12	0
Oliver Mtukudzi	26137	2022-05-12	0
PRIMAL FEAR	26138	2022-05-12	0
Grave	26139	2022-05-12	0
Smokey Robinson	26140	2022-05-12	0
Karnig Sarkissian	26141	2022-05-12	0
McCoy Tyner	26142	2022-05-12	0
The Sainte Catherines	26143	2022-05-12	0
Jawan Bey/Word of Mouth Band	26144	2022-05-12	0
Fedde Le Grand	26145	2022-05-12	0
Liona Boyd	26146	2022-05-12	0
(hed) p.e.	26147	2022-05-12	0
Luis Miguel	26148	2022-05-12	0
Rosana / Maria Dolores Pradera	26149	2022-05-12	0
Operahouse	26150	2022-05-12	0
Grand Archives	26151	2022-05-12	0
Sport	26152	2022-05-12	0
Machine Go Boom	26153	2022-05-12	0
Mr. De.	26154	2022-05-12	0
Jenna Mammina	26155	2022-05-12	0
Ultravox!	26156	2022-05-12	0
Dessau	26157	2022-05-12	0
Donnie Munro	26158	2022-05-12	0
La Guardia	26159	2022-05-12	0
Sunrider	26160	2022-05-12	0
Natalie Merchant	26161	2022-05-12	0
Lucky Luciano	26162	2022-05-12	0
The Earlies	26163	2022-05-12	0
Count Five	26164	2022-05-12	0
Grady Martin & His Slew Foot Five	26165	2022-05-12	0
Ogris Debris	26166	2022-05-12	0
Niamh Kavanagh	26167	2022-05-12	0
Diane Schuur	26168	2022-05-12	0
Kyu Sakamoto	26169	2022-05-12	0
Gigi Barocco	26170	2022-05-12	0
T.Roc	26171	2022-05-12	0
The Electric Flag	26172	2022-05-12	0
Lil Wayne / Kevin Rudolf	26173	2022-05-12	0
OV7	26174	2022-05-12	0
Omega Drive	26175	2022-05-12	0
The Brian Jonestown Massacre	26176	2022-05-12	0
Nile	26177	2022-05-12	0
Benevento / Russo Duo	26178	2022-05-12	0
Aly	26179	2022-05-12	0
Kaye Styles	26180	2022-05-12	0
Red Rider	26181	2022-05-12	0
Karl Jenkins/Carmine Lauri/London Symphony Orchestra/Neil Percy	26182	2022-05-12	0
New Found Glory	26183	2022-05-12	0
Avantasia	26184	2022-05-12	0
Marco Calliari	26185	2022-05-12	0
Daryl Coley	26186	2022-05-12	0
Marcus Sommer	26187	2022-05-12	0
Bill Haley & The Comets	26188	2022-05-12	0
Todos Tus Muertos	26189	2022-05-12	0
RODNEY CROWELL	26190	2022-05-12	0
Eric Copeland	26191	2022-05-12	0
MARC COHN	26192	2022-05-12	0
Paul Wall & Chamillionaire	26193	2022-05-12	0
cholo	26194	2022-05-12	0
Rumillajta	26195	2022-05-12	0
Infectious Organisms	26196	2022-05-12	0
La Gran Orquesta Republicana	26197	2022-05-12	0
Isabella Taviani	26198	2022-05-12	0
Dave Spoon	26199	2022-05-12	0
Raashan Ahmad	26200	2022-05-12	0
Colonel Abrams	26201	2022-05-12	0
Joy Denalane	26202	2022-05-12	0
Mannheim Steamroller_ Spencer Nilsen	26203	2022-05-12	0
The Gordons	26204	2022-05-12	0
The Morning Benders	26205	2022-05-12	0
Billy Cobham	26206	2022-05-12	0
Sam Collins	26207	2022-05-12	0
Chris T-T	26208	2022-05-12	0
Zucchero / Mousse T.	26209	2022-05-12	0
Juilliard String Quartet	26210	2022-05-12	0
Fredi	26211	2022-05-12	0
Mistaken Element	26212	2022-05-12	0
NYOIL	26213	2022-05-12	0
The Dayton Family	26214	2022-05-12	0
André Verchuren	26215	2022-05-12	0
Alexis Korner's Blues Incorporated	26216	2022-05-12	0
Cindy Morgan	26217	2022-05-12	0
Big Bill Broonzy	26218	2022-05-12	0
The Turtles	26219	2022-05-12	0
Frankie Yankovic	26220	2022-05-12	0
E For Explosion	26221	2022-05-12	0
Three 6 Mafia featuring La Chat	26222	2022-05-12	0
Spock's Beard	26223	2022-05-12	0
Humanos	26224	2022-05-12	0
James & Bobby Purify	26225	2022-05-12	0
Desmond Dekker & The Aces	26226	2022-05-12	0
Believe	26227	2022-05-12	0
Uochi Toki	26228	2022-05-12	0
Misha Omar	26229	2022-05-12	0
Sarah	26230	2022-05-12	0
Nevada Tan	26231	2022-05-12	0
Gerard Requena	26232	2022-05-12	0
Pitch Black	26233	2022-05-12	0
Danger Radio	26234	2022-05-12	0
The Promise Ring	26235	2022-05-12	0
Tara Angell	26236	2022-05-12	0
Rasmus Nøhr	26237	2022-05-12	0
Santo Barrio	26238	2022-05-12	0
Eternal Tears Of Sorrow	26239	2022-05-12	0
Information Society	26240	2022-05-12	0
October Tide	26241	2022-05-12	0
Living Sacrifice	26242	2022-05-12	0
The Klezmatics	26243	2022-05-12	0
Mark Mallman	26244	2022-05-12	0
Alove For Enemies	26245	2022-05-12	0
The Jones Girls	26246	2022-05-12	0
Larue	26247	2022-05-12	0
Gary Allan	26248	2022-05-12	0
Vinnie Paz	26249	2022-05-12	0
Pestilence	26250	2022-05-12	0
Camel	26251	2022-05-12	0
The Auteurs	26252	2022-05-12	0
Brian Melo	26253	2022-05-12	0
Pariah	26254	2022-05-12	0
Blink-182	26255	2022-05-12	0
Scooter	26256	2022-05-12	0
Konceptual Dominance	26257	2022-05-12	0
The Hellblinki Sextet	26258	2022-05-12	0
Nadine Sutherland_ Buju Banton	26259	2022-05-12	0
Alasdair Clayre	26260	2022-05-12	0
Juicebox	26261	2022-05-12	0
Paul Carrack	26262	2022-05-12	0
THERION	26263	2022-05-12	0
Para	26264	2022-05-12	0
Rod Price	26265	2022-05-12	0
Silvio Rodriguez and Pablo Milanes	26266	2022-05-12	0
Money Mark	26267	2022-05-12	0
Lara & The Gumbo Lickers	26268	2022-05-12	0
Beto Quintanilla	26269	2022-05-12	0
Terrance Simien	26270	2022-05-12	0
Jon Wayne	26271	2022-05-12	0
Persiana Jones	26272	2022-05-12	0
JC	26273	2022-05-12	0
Delroy Washington	26274	2022-05-12	0
Carlos Argentino	26275	2022-05-12	0
Ewan MacColl	26276	2022-05-12	0
Eternal featuring Grand Puba & Sadat X	26277	2022-05-12	0
Rev. Edward W. Clayborn	26278	2022-05-12	0
The Handsome Family	26279	2022-05-12	0
Priscilla Chan	26280	2022-05-12	0
Riva Starr	26281	2022-05-12	0
Nick Heyward	26282	2022-05-12	0
Stephin Merritt	26283	2022-05-12	0
DJ Drez & Marty Williams	26284	2022-05-12	0
Boney James (Featuring Trina Broussard)	26285	2022-05-12	0
Drifters	26286	2022-05-12	0
Mystic Rhythms Band	26287	2022-05-12	0
Every Time I Die	26288	2022-05-12	0
Seatrain	26289	2022-05-12	0
Elvis Presley	26290	2022-05-12	0
Haris & Panos Katsimihas	26291	2022-05-12	0
Late Of The Pier	26292	2022-05-12	0
The Brought Low	26293	2022-05-12	0
Uniting Nations	26294	2022-05-12	0
Frankie Knuckles with Jamie Principle	26295	2022-05-12	0
The Delgados	26296	2022-05-12	0
Disturbing Tha Peace / I-20 / Lil Fate / Tity Boi / Chimere	26297	2022-05-12	0
Stone Senses	26298	2022-05-12	0
Karl Bartos	26299	2022-05-12	0
Love Equals Death	26300	2022-05-12	0
Consortium Project III	26301	2022-05-12	0
Kosheen	26302	2022-05-12	0
Toby Lightman	26303	2022-05-12	0
Mick Overman	26304	2022-05-12	0
Cold Blood	26305	2022-05-12	0
The American Boychoir	26306	2022-05-12	0
Carol Channing	26307	2022-05-12	0
It Hugs Back	26308	2022-05-12	0
AfroReggae	26309	2022-05-12	0
Aeroc	26310	2022-05-12	0
Das EFX	26311	2022-05-12	0
Max Stalling	26312	2022-05-12	0
Rufus Zuphall	26313	2022-05-12	0
On File	26314	2022-05-12	0
Cornell Dupree	26315	2022-05-12	0
Screaming Lord Sutch	26316	2022-05-12	0
Davy Jones	26317	2022-05-12	0
1976	26318	2022-05-12	0
Slobberbone	26319	2022-05-12	0
The Funky Lowlives	26320	2022-05-12	0
Big Bill Morganfield	26321	2022-05-12	0
LeAnn Rimes	26322	2022-05-12	0
Marcelo D2 & Pitty	26323	2022-05-12	0
Stephan Eicher	26324	2022-05-12	0
Subhumans	26325	2022-05-12	0
Blast Stereos Loud	26326	2022-05-12	0
Fisher	26327	2022-05-12	0
Robert Hood	26328	2022-05-12	0
Paulina Rubio	26329	2022-05-12	0
Paramore	26330	2022-05-12	0
Sido	26331	2022-05-12	0
ACO feat. Elmar Gunsch	26332	2022-05-12	0
Diskoteka Avariya	26333	2022-05-12	0
Alex M	26334	2022-05-12	0
Agent K	26335	2022-05-12	0
George Dalaras	26336	2022-05-12	0
Krum Bums	26337	2022-05-12	0
The Notorious B.I.G.	26338	2022-05-12	0
Mr. P!NK	26339	2022-05-12	0
Starless & Bible Black	26340	2022-05-12	0
Andomat 3000	26341	2022-05-12	0
Timbuk 3	26342	2022-05-12	0
Ebony Ark	26343	2022-05-12	0
Cadena Perpetua	26344	2022-05-12	0
Osunlade	26345	2022-05-12	0
Sandy Resek	26346	2022-05-12	0
Dark Shadows	26347	2022-05-12	0
Cobblestone Jazz	26348	2022-05-12	0
Ana Carolina	26349	2022-05-12	0
Warren G (featuring Nate Dogg And Snoop Dogg)	26350	2022-05-12	0
La Union	26351	2022-05-12	0
Boney M. 2000	26352	2022-05-12	0
Red	26353	2022-05-12	0
Rezound	26354	2022-05-12	0
Teebee & Noisia	26355	2022-05-12	0
One Man Army	26356	2022-05-12	0
Black Moon	26357	2022-05-12	0
The Marketts	26358	2022-05-12	0
Burmese	26359	2022-05-12	0
Dj Marbrax	26360	2022-05-12	0
A Life Once Lost	26361	2022-05-12	0
Side Effect	26362	2022-05-12	0
Colin Newman	26363	2022-05-12	0
Mike Foyle	26364	2022-05-12	0
Emmy The Great	26365	2022-05-12	0
Straylight Run	26366	2022-05-12	0
Marie & Les Garçons	26367	2022-05-12	0
Dreadzone	26368	2022-05-12	0
Royal Flush	26369	2022-05-12	0
Jani Wickholm	26370	2022-05-12	0
Dirt Bag	26371	2022-05-12	0
Domine	26372	2022-05-12	0
Dobie Gray	26373	2022-05-12	0
Marcelo	26374	2022-05-12	0
Radium	26375	2022-05-12	0
The Orchestra	26376	2022-05-12	0
Mirko Loko	26377	2022-05-12	0
Violeta Parra	26378	2022-05-12	0
Los Cuates de Sinaloa	26379	2022-05-12	0
Quovadis	26380	2022-05-12	0
Delons	26381	2022-05-12	0
God Bullies	26382	2022-05-12	0
The Marbles	26383	2022-05-12	0
Jega	26384	2022-05-12	0
Tackhead	26385	2022-05-12	0
Holy Smokes	26386	2022-05-12	0
Nightmares On Wax	26387	2022-05-12	0
Moonsorrow	26388	2022-05-12	0
David Julyan	26389	2022-05-12	0
Gurtz	26390	2022-05-12	0
Freaky Chakra	26391	2022-05-12	0
The Bots	26392	2022-05-12	0
Chase & Status	26393	2022-05-12	0
Big & Rich	26394	2022-05-12	0
Blind Ego	26395	2022-05-12	0
3 Cold Men	26396	2022-05-12	0
John Hammond	26397	2022-05-12	0
Chicago	26398	2022-05-12	0
Waldemar Bastos	26399	2022-05-12	0
Quim Barreiros	26400	2022-05-12	0
Mississippi John Hurt	26401	2022-05-12	0
Bad Lieutenant	26402	2022-05-12	0
Ignitor	26403	2022-05-12	0
The Exploited	26404	2022-05-12	0
Naked Lunch	26405	2022-05-12	0
O	26406	2022-05-12	0
Sue Foley	26407	2022-05-12	0
Code Of Ethics	26408	2022-05-12	0
Lorenzo Antonio	26409	2022-05-12	0
Volebeats	26410	2022-05-12	0
GEORGE SOULE	26411	2022-05-12	0
Los Nemus del Pacifico	26412	2022-05-12	0
Sveta	26413	2022-05-12	0
Carey Ott	26414	2022-05-12	0
DecembeRadio	26415	2022-05-12	0
La Maquina De Hacer Pájaros	26416	2022-05-12	0
Garnet Silk_ Sharon Forrester	26417	2022-05-12	0
Thomas Schumacher	26418	2022-05-12	0
Big Tuck	26419	2022-05-12	0
Heikki Silvennoinen	26420	2022-05-12	0
Copper Box	26421	2022-05-12	0
Ronnie Dove	26422	2022-05-12	0
Bobby Solo	26423	2022-05-12	0
Ryoji Ikeda	26424	2022-05-12	0
Defying Control	26425	2022-05-12	0
John Alexander Ericson	26426	2022-05-12	0
Tift Merritt	26427	2022-05-12	0
Hypatia Lake	26428	2022-05-12	0
Orchestral Manoeuvres In The Dark	26429	2022-05-12	0
Wir Sind Helden	26430	2022-05-12	0
Lo Fidelity Allstars	26431	2022-05-12	0
Betty Boo	26432	2022-05-12	0
Frenchy	26433	2022-05-12	0
Albert Ayler Trio	26434	2022-05-12	0
Jello Biafra & The Melvins	26435	2022-05-12	0
Azucar Moreno	26436	2022-05-12	0
Tasmin Archer	26437	2022-05-12	0
Photek	26438	2022-05-12	0
Nokie Edwards	26439	2022-05-12	0
Aromabar	26440	2022-05-12	0
Myself	26441	2022-05-12	0
Them Wranch	26442	2022-05-12	0
TasteXperience	26443	2022-05-12	0
Asking Alexandria	26444	2022-05-12	0
André Thivet	26445	2022-05-12	0
Hollywood Flames	26446	2022-05-12	0
Grassella Oliphant Quartet	26447	2022-05-12	0
Tori Amos	26448	2022-05-12	0
Le Loup	26449	2022-05-12	0
Cherbourg	26450	2022-05-12	0
John Carpenter	26451	2022-05-12	0
John Martyn	26452	2022-05-12	0
Pacha Massive	26453	2022-05-12	0
Gordie Tentrees	26454	2022-05-12	0
Avis Vox	26455	2022-05-12	0
Lifer	26456	2022-05-12	0
Sensations	26457	2022-05-12	0
Chalk	26458	2022-05-12	0
Chicken Shack	26459	2022-05-12	0
Steril	26460	2022-05-12	0
Sunnysmack	26461	2022-05-12	0
Dave Cousins	26462	2022-05-12	0
Jane Kelly Williams	26463	2022-05-12	0
Down	26464	2022-05-12	0
Jaime	26465	2022-05-12	0
Tracey Thorn	26466	2022-05-12	0
Jet Black Crayon	26467	2022-05-12	0
The Coasters	26468	2022-05-12	0
Sébastien Schuller	26469	2022-05-12	0
Pete Escovedo	26470	2022-05-12	0
Ruxe Ruxe	26471	2022-05-12	0
CMW - Compton's Most Wanted	26472	2022-05-12	0
Ruby Murray	26473	2022-05-12	0
I'm Being Good	26474	2022-05-12	0
Barleyjuice	26475	2022-05-12	0
Shannon Lee	26476	2022-05-12	0
Siegfried & Roy - Lesungen	26477	2022-05-12	0
Paulo Flores	26478	2022-05-12	0
Deep Dish;Richard Morel;Brian Transeau	26479	2022-05-12	0
The Ruts	26480	2022-05-12	0
Teenage Fanclub and Jad Fair	26481	2022-05-12	0
Brendan Shine	26482	2022-05-12	0
P.U.S.H.	26483	2022-05-12	0
The Roots / Mercedes Martinez	26484	2022-05-12	0
Teena Marie	26485	2022-05-12	0
Tony Curtis	26486	2022-05-12	0
J.D. Souther	26487	2022-05-12	0
Raiders of the lost ARP	26488	2022-05-12	0
Megapuss	26489	2022-05-12	0
Itchyworms	26490	2022-05-12	0
Dan Zanes Feat. Rosanne Cash	26491	2022-05-12	0
Madball	26492	2022-05-12	0
Briskeby	26493	2022-05-12	0
Takara	26494	2022-05-12	0
Forever In Terror	26495	2022-05-12	0
Darren Smith	26496	2022-05-12	0
Pete Rock	26497	2022-05-12	0
Cheech And Chong with Alice Bowie	26498	2022-05-12	0
Sindre Eide	26499	2022-05-12	0
State Radio	26500	2022-05-12	0
? & The Mysterians	26501	2022-05-12	0
Heidi Talbot	26502	2022-05-12	0
Sharko	26503	2022-05-12	0
Haffa Combino	26504	2022-05-12	0
Rosana	26505	2022-05-12	0
Grupo Batuque	26506	2022-05-12	0
Logan Square	26507	2022-05-12	0
Catherine Wheel	26508	2022-05-12	0
Helena Josefsson	26509	2022-05-12	0
Marc Seal	26510	2022-05-12	0
Moca	26511	2022-05-12	0
Laura Canales	26512	2022-05-12	0
Mitty Collier	26513	2022-05-12	0
Big Shug	26514	2022-05-12	0
Charlie Hunter	26515	2022-05-12	0
The Associates	26516	2022-05-12	0
The Yardbirds	26517	2022-05-12	0
NG²	26518	2022-05-12	0
Torpedo Boyz	26519	2022-05-12	0
Dave Barnes	26520	2022-05-12	0
Planet X	26521	2022-05-12	0
Bilge Pump	26522	2022-05-12	0
Nathaniel Bartlett	26523	2022-05-12	0
Alan Barratt	26524	2022-05-12	0
John Huijbers	26525	2022-05-12	0
Hamster Theatre	26526	2022-05-12	0
Ashley Parker Angel	26527	2022-05-12	0
Chico Che	26528	2022-05-12	0
Alexandre Desplat & Aaron Zigman	26529	2022-05-12	0
Charger	26530	2022-05-12	0
PIONEER 10	26531	2022-05-12	0
Jack Sheldon	26532	2022-05-12	0
Mark Lemhouse	26533	2022-05-12	0
Peven Everett	26534	2022-05-12	0
Clepsydra	26535	2022-05-12	0
Ghostland Observatory	26536	2022-05-12	0
Thomas Di Leva	26537	2022-05-12	0
Nobs	26538	2022-05-12	0
Sean Paul	26539	2022-05-12	0
Scars On Broadway	26540	2022-05-12	0
Nahoru po schodisti dolu band	26541	2022-05-12	0
Slant	26542	2022-05-12	0
Anne Briggs	26543	2022-05-12	0
Framing Hanley	26544	2022-05-12	0
Spartaque	26545	2022-05-12	0
Nobody's Perfect	26546	2022-05-12	0
Metric	26547	2022-05-12	0
Sir Charles Mackerras;The Hanover Band;Andrea Rost;London Voices	26548	2022-05-12	0
The Grifters	26549	2022-05-12	0
The Billions	26550	2022-05-12	0
Zacarias Ferreira	26551	2022-05-12	0
Domi	26552	2022-05-12	0
Temple Of The Dog	26553	2022-05-12	0
Tommie Jenkins	26554	2022-05-12	0
Pavel Dobes	26555	2022-05-12	0
Eric Chase	26556	2022-05-12	0
Juan Formell y los Van Van	26557	2022-05-12	0
DJ ROXX	26558	2022-05-12	0
Alternate Vision	26559	2022-05-12	0
Chris Rea	26560	2022-05-12	0
Jessie Baylin	26561	2022-05-12	0
Shaman	26562	2022-05-12	0
I-F	26563	2022-05-12	0
Bröderna Djup	26564	2022-05-12	0
Martin O'Donnell And Michael Salvatori	26565	2022-05-12	0
Transilvanian Beat Club	26566	2022-05-12	0
Benümb	26567	2022-05-12	0
The Chuck Norris Experiment	26568	2022-05-12	0
Little Steven And The Disciples Of Soul	26569	2022-05-12	0
Daouda	26570	2022-05-12	0
Orbital	26571	2022-05-12	0
Hirshee feat. Messinian	26572	2022-05-12	0
Two Loons For Tea	26573	2022-05-12	0
Pedro Infante	26574	2022-05-12	0
Avi Buffalo	26575	2022-05-12	0
Francis Cabrel	26576	2022-05-12	0
Malvina Reynolds	26577	2022-05-12	0
Jeff Lang	26578	2022-05-12	0
Camilo Sesto	26579	2022-05-12	0
Dave Dobbyn	26580	2022-05-12	0
Eighteen Visions	26581	2022-05-12	0
Monkey And The Mighty Disciplinarians	26582	2022-05-12	0
Jordin Sparks	26583	2022-05-12	0
polarkreis 18	26584	2022-05-12	0
Rocko	26585	2022-05-12	0
Kelly_ Sean	26586	2022-05-12	0
Codeine	26587	2022-05-12	0
Luna City Express featuring Diamondancer	26588	2022-05-12	0
J.B. Lenoir	26589	2022-05-12	0
Eric Champion	26590	2022-05-12	0
Kid606	26591	2022-05-12	0
Dust Junkys	26592	2022-05-12	0
Coko	26593	2022-05-12	0
Sherrie Lea	26594	2022-05-12	0
Tina Rainford	26595	2022-05-12	0
The Mob	26596	2022-05-12	0
Vernessa Mitchell	26597	2022-05-12	0
John Sims	26598	2022-05-12	0
Danser Med Drenge	26599	2022-05-12	0
Trademark	26600	2022-05-12	0
Andi Sex Gang	26601	2022-05-12	0
Les Sexareenos	26602	2022-05-12	0
Ajattara	26603	2022-05-12	0
B.E.N & Mr. Pit	26604	2022-05-12	0
Mighty Mo Rodgers	26605	2022-05-12	0
The Future Sound of London	26606	2022-05-12	0
The Magnetic Fields	26607	2022-05-12	0
Richard Thompson	26608	2022-05-12	0
Mamou Sidibé	26609	2022-05-12	0
Benighted	26610	2022-05-12	0
Propagandhi	26611	2022-05-12	0
Blue Lunar Monkey	26612	2022-05-12	0
Frigg A-Go-Go	26613	2022-05-12	0
Silkk The Shocker	26614	2022-05-12	0
Epitome	26615	2022-05-12	0
Reverend And The Makers	26616	2022-05-12	0
Aramis Galindo	26617	2022-05-12	0
Unwound	26618	2022-05-12	0
Inner Terrestrials	26619	2022-05-12	0
Cab Calloway & His Orchestra	26620	2022-05-12	0
Juan José Sáenz	26621	2022-05-12	0
Mercedes Castro	26622	2022-05-12	0
Rachael McShane	26623	2022-05-12	0
C Note featuring Mangu	26624	2022-05-12	0
Lauren Mason	26625	2022-05-12	0
The Bihlman Bros.	26626	2022-05-12	0
Darren Williams	26627	2022-05-12	0
The Pinkerton Thugs	26628	2022-05-12	0
Freemasons	26629	2022-05-12	0
Jo Privat	26630	2022-05-12	0
Wild Colonials	26631	2022-05-12	0
Pretty Tony	26632	2022-05-12	0
The Rocket Summer	26633	2022-05-12	0
David Francey	26634	2022-05-12	0
The Lilly Brothers	26635	2022-05-12	0
Cabaret	26636	2022-05-12	0
Cerf_ Mitiska & Jaren	26637	2022-05-12	0
Cranes	26638	2022-05-12	0
Russell Watson / Royal Philharmonic Orchestra / William Hayward	26639	2022-05-12	0
Juaninacka - Zatu	26640	2022-05-12	0
Herbie Mann & Bill Evans	26641	2022-05-12	0
Fat Joe	26642	2022-05-12	0
Fizzle Like A Flood	26643	2022-05-12	0
Chingy	26644	2022-05-12	0
Joe Cocker	26645	2022-05-12	0
Miracle Fortress	26646	2022-05-12	0
Roomful Of Blues	26647	2022-05-12	0
Dan Potthast	26648	2022-05-12	0
Dock Boggs	26649	2022-05-12	0
DJ KAYSLAY featuring 50 Cent	26650	2022-05-12	0
JustMe	26651	2022-05-12	0
Easy Star All-Stars Featuring MC Trouble	26652	2022-05-12	0
The Hidden Cameras	26653	2022-05-12	0
Butane	26654	2022-05-12	0
Yukmouth & Tha Gamblaz	26655	2022-05-12	0
Kill The Client	26656	2022-05-12	0
Starving	26657	2022-05-12	0
Mr. Knightowl_ Kokane_ Mr Shadow	26658	2022-05-12	0
Christian Kjellvander	26659	2022-05-12	0
Omara Portuondo_ Maria Bethânia	26660	2022-05-12	0
Sigue Sigue Sputnik	26661	2022-05-12	0
Akela	26662	2022-05-12	0
Norman Doray	26663	2022-05-12	0
The Foreshadowing	26664	2022-05-12	0
Adina Howard	26665	2022-05-12	0
Ina Müller	26666	2022-05-12	0
Native Deen	26667	2022-05-12	0
Strangefolk	26668	2022-05-12	0
Immaculate Fools	26669	2022-05-12	0
Betty Wand & the M-G-M Studio Orchestra	26670	2022-05-12	0
Ray Conniff & The Ray Conniff Singers	26671	2022-05-12	0
Pierre Vangelis	26672	2022-05-12	0
Redcar	26673	2022-05-12	0
goldenhorse	26674	2022-05-12	0
Betty Davis	26675	2022-05-12	0
Dennis Day	26676	2022-05-12	0
End Of Fashion	26677	2022-05-12	0
Star Off Machine	26678	2022-05-12	0
Prince Jammy	26679	2022-05-12	0
Tha Dogg Pound	26680	2022-05-12	0
Screaming Banshee Aircrew	26681	2022-05-12	0
Bobby Cruz	26682	2022-05-12	0
Sim Redmond Band	26683	2022-05-12	0
Puressence	26684	2022-05-12	0
Ike & Tina Turner	26685	2022-05-12	0
Heaven 17	26686	2022-05-12	0
Orchestra & Coro del Teatro La Fenice di Venezia	26687	2022-05-12	0
Link	26688	2022-05-12	0
David Campbell	26689	2022-05-12	0
Tiny Masters Of Today	26690	2022-05-12	0
Boy Kill Boy	26691	2022-05-12	0
Arise And Ruin	26692	2022-05-12	0
Tina Cousins	26693	2022-05-12	0
Veltto Virtanen	26694	2022-05-12	0
Alchemy	26695	2022-05-12	0
Alan Lomax	26696	2022-05-12	0
EQUATRONIC	26697	2022-05-12	0
Krista Muir	26698	2022-05-12	0
Shelly Manne	26699	2022-05-12	0
The Twins Artcore	26700	2022-05-12	0
Rudy Vallée	26701	2022-05-12	0
Anna Oxygen	26702	2022-05-12	0
Default	26703	2022-05-12	0
John Coltrane / Johnny Hartman	26704	2022-05-12	0
Young Gunz	26705	2022-05-12	0
Captain Matchbox Whoopee Band	26706	2022-05-12	0
Edgar Winter's White Trash	26707	2022-05-12	0
Boukman Eksperyans	26708	2022-05-12	0
Red Nex	26709	2022-05-12	0
George Faith	26710	2022-05-12	0
Tina Charles	26711	2022-05-12	0
Piano Magic	26712	2022-05-12	0
Sian Alice Group	26713	2022-05-12	0
Alain Caron	26714	2022-05-12	0
John Legend	26715	2022-05-12	0
Red Nichols And The Five Pennies	26716	2022-05-12	0
Daddy Yankee	26717	2022-05-12	0
Lu Fang	26718	2022-05-12	0
Myriam Hernández	26719	2022-05-12	0
Xandria	26720	2022-05-12	0
The Starting Line	26721	2022-05-12	0
Kendra Shank_ Larry Willis Quartet	26722	2022-05-12	0
Professor Longhair	26723	2022-05-12	0
Charlie Wilson	26724	2022-05-12	0
Gasoline Heart	26725	2022-05-12	0
Gareth Gates	26726	2022-05-12	0
Cephalgy	26727	2022-05-12	0
Doughboys	26728	2022-05-12	0
Tommy Wright III	26729	2022-05-12	0
Beny Moré	26730	2022-05-12	0
Markus Schulz	26731	2022-05-12	0
Six Reasons to Kill	26732	2022-05-12	0
The Parson Red Heads	26733	2022-05-12	0
TNT	26734	2022-05-12	0
No Tiene La Vaca	26735	2022-05-12	0
Clã	26736	2022-05-12	0
Die Unsichtbaren	26737	2022-05-12	0
Ara	26738	2022-05-12	0
Taint	26739	2022-05-12	0
Merzbow	26740	2022-05-12	0
Eric Schwartz	26741	2022-05-12	0
Chris Farlowe	26742	2022-05-12	0
Glissade	26743	2022-05-12	0
The Grinning Plowman	26744	2022-05-12	0
Lunar Aurora	26745	2022-05-12	0
Zero Boys	26746	2022-05-12	0
Fare Soldi	26747	2022-05-12	0
Spinecar	26748	2022-05-12	0
Sibrydion	26749	2022-05-12	0
Jah Wobble's Invaders Of The Heart	26750	2022-05-12	0
The Ghost of A Thousand	26751	2022-05-12	0
Betty Wright	26752	2022-05-12	0
Self Scientific	26753	2022-05-12	0
The Rapsody / Onyx	26754	2022-05-12	0
Lendakaris Muertos	26755	2022-05-12	0
Paul Westerberg	26756	2022-05-12	0
Junkie XL	26757	2022-05-12	0
Meredith d'Ambrosio	26758	2022-05-12	0
The Shermans	26759	2022-05-12	0
Afrika Bambaataa & Soul Sonic Force	26760	2022-05-12	0
Rosie Ribbons	26761	2022-05-12	0
Traband	26762	2022-05-12	0
Cajus	26763	2022-05-12	0
Deep Nights	26764	2022-05-12	0
The Treacherous Three	26765	2022-05-12	0
Silvio Rodríguez	26766	2022-05-12	0
Fascination	26767	2022-05-12	0
The Prefects	26768	2022-05-12	0
Guce  featuring Jynx	26769	2022-05-12	0
Animals That Swim	26770	2022-05-12	0
Zeromancer	26771	2022-05-12	0
The Mr. T Experience	26772	2022-05-12	0
The Bloody Beetroots	26773	2022-05-12	0
Dirt Nasty	26774	2022-05-12	0
Xerramequ Tiquis Miquis	26775	2022-05-12	0
John  Holm	26776	2022-05-12	0
Milo	26777	2022-05-12	0
Herman Dune	26778	2022-05-12	0
Hoagy Carmichael	26779	2022-05-12	0
Blind Guardian	26780	2022-05-12	0
Ivan	26781	2022-05-12	0
The Slammers Maximum Jive Band	26782	2022-05-12	0
Ruby	26783	2022-05-12	0
Richard Rodgers_ Oscar Hammerstein II	26784	2022-05-12	0
Willie D.	26785	2022-05-12	0
Anita Ward	26786	2022-05-12	0
Frankie J	26787	2022-05-12	0
Pretty Wild	26788	2022-05-12	0
Blue Planet Corporation	26789	2022-05-12	0
Not Advised	26790	2022-05-12	0
The Pope	26791	2022-05-12	0
Aretha Franklin	26792	2022-05-12	0
Homer/Marge/Bart/Lisa/Guard	26793	2022-05-12	0
Plastic Parachute	26794	2022-05-12	0
Buffalo Nickel Band	26795	2022-05-12	0
Emmure	26796	2022-05-12	0
Dynamix II	26797	2022-05-12	0
Rahat Fateh Ali Khan;Shankar Mahadevan;Richa Sharma	26798	2022-05-12	0
Aleks Y La Gente Normal Syntek	26799	2022-05-12	0
Born From Pain	26800	2022-05-12	0
Nick Fiorucci	26801	2022-05-12	0
Steve Oliver	26802	2022-05-12	0
Chayanne	26803	2022-05-12	0
Nashville Pussy	26804	2022-05-12	0
David Carroll & The Migrating Fellows	26805	2022-05-12	0
Luis Aguilar	26806	2022-05-12	0
Pro-Pain	26807	2022-05-12	0
Pablo Moses	26808	2022-05-12	0
Youthmovies	26809	2022-05-12	0
MC Devvo & Shady Piez	26810	2022-05-12	0
Aleksander Denstad With	26811	2022-05-12	0
7 Year Bitch	26812	2022-05-12	0
Malevolent Creation	26813	2022-05-12	0
Resistance 77	26814	2022-05-12	0
Misfits	26815	2022-05-12	0
Judd and Maggie	26816	2022-05-12	0
Peter Bjorn And John	26817	2022-05-12	0
Saint Dog	26818	2022-05-12	0
Stefanie Heinzmann	26819	2022-05-12	0
Acoustic Food	26820	2022-05-12	0
Johnny Fiasco	26821	2022-05-12	0
Javi Reina	26822	2022-05-12	0
Lukas Kasha	26823	2022-05-12	0
Einar Stray	26824	2022-05-12	0
Brain Damage	26825	2022-05-12	0
Zella Mayzell	26826	2022-05-12	0
Linda Ronstadt	26827	2022-05-12	0
Yespiring	26828	2022-05-12	0
Solarized	26829	2022-05-12	0
M-Clan	26830	2022-05-12	0
Holland-Dozier	26831	2022-05-12	0
Erik Linder	26832	2022-05-12	0
Los Campesinos!	26833	2022-05-12	0
Purple City	26834	2022-05-12	0
The Magic Time Travelers	26835	2022-05-12	0
Gary Moore	26836	2022-05-12	0
Das Dritte Ohr	26837	2022-05-12	0
Moonglows	26838	2022-05-12	0
Rashid Hadee	26839	2022-05-12	0
El Combo de las Estrellas - Fernando González	26840	2022-05-12	0
Z.Z. Hill	26841	2022-05-12	0
Eden's Bridge	26842	2022-05-12	0
Jesse Cook	26843	2022-05-12	0
Ken Laszlo	26844	2022-05-12	0
Michael English	26845	2022-05-12	0
Gordon Jenkins	26846	2022-05-12	0
B-Legit	26847	2022-05-12	0
The Breakfast	26848	2022-05-12	0
The New York Dolls	26849	2022-05-12	0
The Tossers	26850	2022-05-12	0
The Tams	26851	2022-05-12	0
Dakota Staton	26852	2022-05-12	0
Ness	26853	2022-05-12	0
Red Garland	26854	2022-05-12	0
Pedro Guerra	26855	2022-05-12	0
Nudozurdo	26856	2022-05-12	0
Alaine	26857	2022-05-12	0
Fields Of The Nephilim	26858	2022-05-12	0
Count Basie	26859	2022-05-12	0
Andrew Peterson	26860	2022-05-12	0
Kymani Marley	26861	2022-05-12	0
Wesley Blake	26862	2022-05-12	0
Cephas & Wiggins	26863	2022-05-12	0
Yo La Tengo	26864	2022-05-12	0
Chaka Demus And Pliers	26865	2022-05-12	0
Cow Cow Davenport	26866	2022-05-12	0
Sundowner	26867	2022-05-12	0
Streetlife Originals	26868	2022-05-12	0
Chris Botti featuring Steven Tyler	26869	2022-05-12	0
Wiley Featuring Chipmunk_ j.m.e And Skepta	26870	2022-05-12	0
Fiji	26871	2022-05-12	0
Mahotella Queens	26872	2022-05-12	0
Frontkick	26873	2022-05-12	0
Dead Hearts	26874	2022-05-12	0
Ricky General / Mega Banton	26875	2022-05-12	0
Witchcraft	26876	2022-05-12	0
Klingonz	26877	2022-05-12	0
Guy Davis	26878	2022-05-12	0
Gorch Fock	26879	2022-05-12	0
William Goldstein	26880	2022-05-12	0
Tyran`Pace	26881	2022-05-12	0
Slaughterhouse	26882	2022-05-12	0
B-Mac	26883	2022-05-12	0
Worlds Apart	26884	2022-05-12	0
QBO	26885	2022-05-12	0
Wake Ooloo	26886	2022-05-12	0
Fritz Wunderlich	26887	2022-05-12	0
Der Tante Renate	26888	2022-05-12	0
Black Rain feat. JoJo	26889	2022-05-12	0
Michael Bolton	26890	2022-05-12	0
Sandi Patty	26891	2022-05-12	0
Gin Blossoms	26892	2022-05-12	0
Sefyu	26893	2022-05-12	0
Mya	26894	2022-05-12	0
Lissy Trullie	26895	2022-05-12	0
Ray Barretto	26896	2022-05-12	0
Makoto Kawabata and Richard Youngs	26897	2022-05-12	0
Thom Hell	26898	2022-05-12	0
The Packway Handle Band	26899	2022-05-12	0
Alex D' Castro	26900	2022-05-12	0
Louis Prima/Keely Smith	26901	2022-05-12	0
Frou Frou	26902	2022-05-12	0
Nick Glennie-Smith	26903	2022-05-12	0
Jr Ewing	26904	2022-05-12	0
Indidginus	26905	2022-05-12	0
Byron Stingily	26906	2022-05-12	0
Mobb Deep	26907	2022-05-12	0
Jossie Esteban & La Patrulla 15	26908	2022-05-12	0
Tides Of Man	26909	2022-05-12	0
Emilie-Claire Barlow	26910	2022-05-12	0
Hinder	26911	2022-05-12	0
Arbouretum	26912	2022-05-12	0
Soul Junk	26913	2022-05-12	0
The Exit Strategy	26914	2022-05-12	0
Eno	26915	2022-05-12	0
Barbara Mandrell	26916	2022-05-12	0
Los Van Van	26917	2022-05-12	0
Kiprich	26918	2022-05-12	0
Suite Crude Revue	26919	2022-05-12	0
The Coke Dares	26920	2022-05-12	0
Lemon D	26921	2022-05-12	0
Noize Creator	26922	2022-05-12	0
John Coltrane Quartet	26923	2022-05-12	0
Jerom	26924	2022-05-12	0
Red Mitchell	26925	2022-05-12	0
Absoluuttinen nollapiste	26926	2022-05-12	0
Far East Ghost	26927	2022-05-12	0
David Dondero	26928	2022-05-12	0
Loggins & Messina	26929	2022-05-12	0
Jamie Richards	26930	2022-05-12	0
La Rumeur	26931	2022-05-12	0
Tempo 38	26932	2022-05-12	0
José Luis Rodríguez	26933	2022-05-12	0
Ginger Rogers_ Fred Astaire	26934	2022-05-12	0
Nautilis	26935	2022-05-12	0
Slash's Snakepit	26936	2022-05-12	0
Filteria	26937	2022-05-12	0
Maura O'connell	26938	2022-05-12	0
Consequence	26939	2022-05-12	0
Gert Vlok Nel	26940	2022-05-12	0
Barron Knights	26941	2022-05-12	0
The Loose Cannons	26942	2022-05-12	0
G-Pal	26943	2022-05-12	0
Midnighters	26944	2022-05-12	0
Chris LeDoux	26945	2022-05-12	0
Alison Hinds	26946	2022-05-12	0
Static-X	26947	2022-05-12	0
Huey "Piano" Smith	26948	2022-05-12	0
Jasper van't Hof HOTLIPS	26949	2022-05-12	0
Fedayi Pacha	26950	2022-05-12	0
Tim Bowman	26951	2022-05-12	0
Julie Doiron	26952	2022-05-12	0
Lindstrøm & Prins Thomas	26953	2022-05-12	0
Dagda	26954	2022-05-12	0
Evangelista	26955	2022-05-12	0
John Larner	26956	2022-05-12	0
Robin Beanland/Dweezil Zappa/Nile Rodgers/Rabbit In The Moon	26957	2022-05-12	0
Parallel Worlds	26958	2022-05-12	0
Loquillo Y Los Intocables	26959	2022-05-12	0
Sandie Shaw	26960	2022-05-12	0
Paul Rogers	26961	2022-05-12	0
Nine Pound Hammer	26962	2022-05-12	0
Foghat	26963	2022-05-12	0
Richard Clayderman	26964	2022-05-12	0
Andrea Bocelli / Christina Aguilera	26965	2022-05-12	0
Mississippi Joe Callicott	26966	2022-05-12	0
Gadget	26967	2022-05-12	0
Maximum Penalty	26968	2022-05-12	0
Mr. President	26969	2022-05-12	0
Stuff Smith	26970	2022-05-12	0
Institute	26971	2022-05-12	0
Michael K.	26972	2022-05-12	0
Virtue	26973	2022-05-12	0
La Kinky Beat	26974	2022-05-12	0
Jay Williams	26975	2022-05-12	0
The Hackberry Ramblers	26976	2022-05-12	0
John McLaughlin	26977	2022-05-12	0
Boo Hewerdine	26978	2022-05-12	0
Neo Cortex	26979	2022-05-12	0
Locust (Mark Van Hoen)	26980	2022-05-12	0
Nat Johnson And The Figureheads	26981	2022-05-12	0
Degrees Of Motion	26982	2022-05-12	0
Chicane	26983	2022-05-12	0
Maelstrom	26984	2022-05-12	0
SYNC24	26985	2022-05-12	0
Boyz II Men	26986	2022-05-12	0
Mandisa	26987	2022-05-12	0
Large Professor feat. Styles P & AZ	26988	2022-05-12	0
Gandalf	26989	2022-05-12	0
FreQ Nasty	26990	2022-05-12	0
Anubis Spire	26991	2022-05-12	0
La Frontera	26992	2022-05-12	0
Aiden	26993	2022-05-12	0
The Skunks	26994	2022-05-12	0
Auto Auto	26995	2022-05-12	0
Lyle Lovett	26996	2022-05-12	0
Steve Howe's Remedy	26997	2022-05-12	0
Sharooz	26998	2022-05-12	0
Terence Blanchard	26999	2022-05-12	0
Escuela de Odio	27000	2022-05-12	0
I Was A Cub Scout	27001	2022-05-12	0
Kevn Kinney	27002	2022-05-12	0
Trobiz	27003	2022-05-12	0
The Gallows	27004	2022-05-12	0
The Strike Boys	27005	2022-05-12	0
Da Mongoloids	27006	2022-05-12	0
Xtranova	27007	2022-05-12	0
Puller	27008	2022-05-12	0
Joe & Antoinette McKenna	27009	2022-05-12	0
The Surfaris	27010	2022-05-12	0
Wooden Shjips	27011	2022-05-12	0
Jimmy Giuffre	27012	2022-05-12	0
Louis Logic	27013	2022-05-12	0
Holger Waernecke	27014	2022-05-12	0
The Blues Band	27015	2022-05-12	0
Lieutenant_ Souliman_ Samm_ Coloquinte_ Le'A'	27016	2022-05-12	0
Freezepop	27017	2022-05-12	0
The White Tie Affair	27018	2022-05-12	0
Aaron Neville	27019	2022-05-12	0
Mar Otra Vez	27020	2022-05-12	0
Daz Dillnger featuring Shelly	27021	2022-05-12	0
Joris Roelofs feat. Aaron Goldberg_ Matt Penman & Ari Hoenig	27022	2022-05-12	0
zebrahead	27023	2022-05-12	0
Amoral	27024	2022-05-12	0
Rita Marley	27025	2022-05-12	0
The Galactic Heroes	27026	2022-05-12	0
Itzhak Perlman / Vladimir Ashkenazy	27027	2022-05-12	0
Patric La Funk	27028	2022-05-12	0
Jenniffer Kae	27029	2022-05-12	0
L.O.X.	27030	2022-05-12	0
Bottom Of The Hudson	27031	2022-05-12	0
Frank Black Francis	27032	2022-05-12	0
Snoop Dogg	27033	2022-05-12	0
Auburn Lull	27034	2022-05-12	0
Funkmaster Flex	27035	2022-05-12	0
Ane Brun	27036	2022-05-12	0
Johnny Burnette Trio	27037	2022-05-12	0
Fuel	27038	2022-05-12	0
Laurindo Almeida / Carlos Barbosa-Lima / Charlie Byrd	27039	2022-05-12	0
Dickie Valentine	27040	2022-05-12	0
Attack	27041	2022-05-12	0
Señor Coconut	27042	2022-05-12	0
Dragonland	27043	2022-05-12	0
Hank Jones_ Mads Vinding_ Billy Hart	27044	2022-05-12	0
Oliver P	27045	2022-05-12	0
Urbanize feat. Mona Cohen	27046	2022-05-12	0
Livewire	27047	2022-05-12	0
Howard Armstrong	27048	2022-05-12	0
Beatfreakz	27049	2022-05-12	0
The Beau Brummels	27050	2022-05-12	0
Stravaganzza	27051	2022-05-12	0
Leela James	27052	2022-05-12	0
Los Tres	27053	2022-05-12	0
Mission Of Burma	27054	2022-05-12	0
Black Noise Feat. Murs	27055	2022-05-12	0
Neva Legal	27056	2022-05-12	0
Sizzla	27057	2022-05-12	0
Demented Are Go	27058	2022-05-12	0
John McDermott	27059	2022-05-12	0
Napoleon	27060	2022-05-12	0
The Infamous Stringdusters	27061	2022-05-12	0
Wooden Stars	27062	2022-05-12	0
Ferd 'Jelly Roll' Morton	27063	2022-05-12	0
Omara Portuondo_ Cachaíto López_ Chucho Valdés	27064	2022-05-12	0
Barbara McNair	27065	2022-05-12	0
Tricky Woo	27066	2022-05-12	0
Shyheim	27067	2022-05-12	0
The Decemberists	27068	2022-05-12	0
The Bloody Beetroots / The Cool Kids	27069	2022-05-12	0
Lazybatusu featuring Karen Jones	27070	2022-05-12	0
Tim Hagans	27071	2022-05-12	0
Suzanna Lubrano	27072	2022-05-12	0
Mártires Del Compás	27073	2022-05-12	0
Carpark North	27074	2022-05-12	0
Carlos Baute	27075	2022-05-12	0
The Never	27076	2022-05-12	0
Discovery	27077	2022-05-12	0
Audiopathik	27078	2022-05-12	0
Don Gibson	27079	2022-05-12	0
Rudresh Mahanthappa	27080	2022-05-12	0
Jimmy McGriff	27081	2022-05-12	0
Surgeon	27082	2022-05-12	0
Les Baton Rouge	27083	2022-05-12	0
Torres Dani és a Veni Styx	27084	2022-05-12	0
J. Holiday	27085	2022-05-12	0
The Fireman	27086	2022-05-12	0
Israel Houghton featuring tobyMac	27087	2022-05-12	0
Pink Mountaintops	27088	2022-05-12	0
Machito	27089	2022-05-12	0
Stakka Bo	27090	2022-05-12	0
Selig	27091	2022-05-12	0
RJ Mischo	27092	2022-05-12	0
Commit Suicide	27093	2022-05-12	0
The Epidemic	27094	2022-05-12	0
Hella	27095	2022-05-12	0
Kenny Barron	27096	2022-05-12	0
Blindman's Sun	27097	2022-05-12	0
Thin Lizzy	27098	2022-05-12	0
Hildegard Knef	27099	2022-05-12	0
Edison Glass	27100	2022-05-12	0
Greek Gypsy Musicians	27101	2022-05-12	0
Section 25	27102	2022-05-12	0
Septic Flesh	27103	2022-05-12	0
Dorothy Norwood	27104	2022-05-12	0
Jon & Vangelis	27105	2022-05-12	0
James McMurtry	27106	2022-05-12	0
Bill Monroe / Ricky Skaggs	27107	2022-05-12	0
Eisblume	27108	2022-05-12	0
Dewey Balfa	27109	2022-05-12	0
Lena & Die Jamba Band	27110	2022-05-12	0
Sentidos Opuestos	27111	2022-05-12	0
Coheed and Cambria	27112	2022-05-12	0
Helena Paparizou	27113	2022-05-12	0
Starflyer 59	27114	2022-05-12	0
Plone	27115	2022-05-12	0
Jada	27116	2022-05-12	0
Our Last Hope Lost Hope	27117	2022-05-12	0
Green Sun	27118	2022-05-12	0
The Chameleons UK	27119	2022-05-12	0
Irma Thomas	27120	2022-05-12	0
Anointed	27121	2022-05-12	0
Nino Bravo	27122	2022-05-12	0
Femme Fatale	27123	2022-05-12	0
DJ Trax	27124	2022-05-12	0
Paffendorf	27125	2022-05-12	0
Starpoint	27126	2022-05-12	0
Jawat	27127	2022-05-12	0
El sueño de Morfeo	27128	2022-05-12	0
Jackie Trent	27129	2022-05-12	0
James	27130	2022-05-12	0
Out of Focus	27131	2022-05-12	0
Pathfinder	27132	2022-05-12	0
Halle_ Eberson_ Sletten & Kjellemyr	27133	2022-05-12	0
No-Neck Blues Band	27134	2022-05-12	0
Guns N' Roses	27135	2022-05-12	0
Sha Na Na	27136	2022-05-12	0
Creed	27137	2022-05-12	0
Sleater-kinney	27138	2022-05-12	0
The Go Betweens	27139	2022-05-12	0
Mean Red Spiders	27140	2022-05-12	0
Roberto Torres	27141	2022-05-12	0
Eddi Reader	27142	2022-05-12	0
David Palmer	27143	2022-05-12	0
Carbon Silicon	27144	2022-05-12	0
Zuul Fx	27145	2022-05-12	0
Too Much Joy	27146	2022-05-12	0
Anaal Nathrakh	27147	2022-05-12	0
Zero 7	27148	2022-05-12	0
Roger Chapman & The Shortlist	27149	2022-05-12	0
Sirius Isness & Painkiller	27150	2022-05-12	0
Estopa	27151	2022-05-12	0
Job For A Cowboy	27152	2022-05-12	0
Wilks	27153	2022-05-12	0
Masterplan	27154	2022-05-12	0
Mad Professor and the Mad Men Band	27155	2022-05-12	0
Tournesol	27156	2022-05-12	0
Zug Izland	27157	2022-05-12	0
Susumu Hirasawa	27158	2022-05-12	0
Juana La Loca	27159	2022-05-12	0
Az & Kotlove pres. Electronic Ascent	27160	2022-05-12	0
Black Dice	27161	2022-05-12	0
El Gran Combo De Puerto Rico	27162	2022-05-12	0
1919	27163	2022-05-12	0
Mr. Knightowl/Slush The Villain/Bokie Lo	27164	2022-05-12	0
Low Motion Disco	27165	2022-05-12	0
Jens Carelius	27166	2022-05-12	0
Tom Petty	27167	2022-05-12	0
Fabrizio Moro	27168	2022-05-12	0
Beanie Sigel	27169	2022-05-12	0
Interlope	27170	2022-05-12	0
Samantha 7	27171	2022-05-12	0
Diva Dee	27172	2022-05-12	0
Her Name Is Calla	27173	2022-05-12	0
Crown City Rockers	27174	2022-05-12	0
Heroes & Zeros	27175	2022-05-12	0
JT Money	27176	2022-05-12	0
Timoria	27177	2022-05-12	0
Christine Baranski;Cleve Asbury;Shaun Amyot;Rick Negron;Taye Diggs	27178	2022-05-12	0
Weeping Tile	27179	2022-05-12	0
Johnny Desmond	27180	2022-05-12	0
Ashton Shepherd	27181	2022-05-12	0
Modwheelmood	27182	2022-05-12	0
Buzzcocks	27183	2022-05-12	0
Pretz	27184	2022-05-12	0
Cheap Trick	27185	2022-05-12	0
Wah!	27186	2022-05-12	0
The Farm	27187	2022-05-12	0
The Horrors	27188	2022-05-12	0
Dream Theater	27189	2022-05-12	0
Curly Top	27190	2022-05-12	0
Guy Clark	27191	2022-05-12	0
Karl Kage	27192	2022-05-12	0
Dj Roby	27193	2022-05-12	0
Future Funk Squad	27194	2022-05-12	0
Square One	27195	2022-05-12	0
Radikal Dub Kolektiv	27196	2022-05-12	0
Proton Kid	27197	2022-05-12	0
The Motels	27198	2022-05-12	0
Auburn	27199	2022-05-12	0
Overcome	27200	2022-05-12	0
Gigi DAgostino	27201	2022-05-12	0
Dinosaur Jr	27202	2022-05-12	0
Blectum from Blechdom	27203	2022-05-12	0
Epica	27204	2022-05-12	0
Liquid People	27205	2022-05-12	0
Death In Venice	27206	2022-05-12	0
Clannad;Anto Drennan;Ian Melrose	27207	2022-05-12	0
Kristian Anttila	27208	2022-05-12	0
Skylark	27209	2022-05-12	0
Jaromir Nohavica	27210	2022-05-12	0
Eagle-Eye Cherry	27211	2022-05-12	0
Mance Lipscomb	27212	2022-05-12	0
Paul Woolford	27213	2022-05-12	0
André Mehmari_ Na Ozzetti	27214	2022-05-12	0
White Wizzard	27215	2022-05-12	0
Deepforces	27216	2022-05-12	0
Christian adam	27217	2022-05-12	0
SKYCLAD	27218	2022-05-12	0
Lakker	27219	2022-05-12	0
Activator	27220	2022-05-12	0
Doctor Butcher	27221	2022-05-12	0
Koffi Olomidé	27222	2022-05-12	0
Franky Kubrick feat. Amaris	27223	2022-05-12	0
Oscar Peterson / Louis Armstrong	27224	2022-05-12	0
Arion (Bach)	27225	2022-05-12	0
The Monroes	27226	2022-05-12	0
Sylvia Martens	27227	2022-05-12	0
Jeremy Oates & The Music Makers	27228	2022-05-12	0
Antaeus	27229	2022-05-12	0
7 Shot Screamers	27230	2022-05-12	0
Fish	27231	2022-05-12	0
White Lion	27232	2022-05-12	0
Sasha Virus	27233	2022-05-12	0
Lesley Gore	27234	2022-05-12	0
Victor Démé	27235	2022-05-12	0
Jason Sean	27236	2022-05-12	0
Kristofer Åström	27237	2022-05-12	0
Glenn Miller	27238	2022-05-12	0
Tan-D	27239	2022-05-12	0
Orchid	27240	2022-05-12	0
CCCP - Fedeli Alla Linea	27241	2022-05-12	0
This Moment In Black History	27242	2022-05-12	0
Niño y pistola	27243	2022-05-12	0
Dawn Tallman	27244	2022-05-12	0
Niño Josele	27245	2022-05-12	0
Joe Brown / The Bruvvers	27246	2022-05-12	0
Velvet Girl	27247	2022-05-12	0
Piebald	27248	2022-05-12	0
Pyrelli	27249	2022-05-12	0
Chrome	27250	2022-05-12	0
Carroll Thompson	27251	2022-05-12	0
Yabby You	27252	2022-05-12	0
Bobby Collins	27253	2022-05-12	0
Barbara Lusch	27254	2022-05-12	0
The Shins	27255	2022-05-12	0
Brad Peterson	27256	2022-05-12	0
Justin Michael	27257	2022-05-12	0
Isobella	27258	2022-05-12	0
Christie Hennessy	27259	2022-05-12	0
Selfmindead	27260	2022-05-12	0
Freddy Weller	27261	2022-05-12	0
Digger & The Pussycats	27262	2022-05-12	0
Billy Sheehan	27263	2022-05-12	0
Dallaz Project	27264	2022-05-12	0
Jazzy B	27265	2022-05-12	0
Havoc	27266	2022-05-12	0
The Glitter Band	27267	2022-05-12	0
Moderatto	27268	2022-05-12	0
Vitamin String Quartet	27269	2022-05-12	0
Amerie	27270	2022-05-12	0
Ismael Rivera	27271	2022-05-12	0
Minilogue	27272	2022-05-12	0
Eva Cassidy	27273	2022-05-12	0
Megadrums	27274	2022-05-12	0
Melodium	27275	2022-05-12	0
DÉSOLÉ	27276	2022-05-12	0
Vicky Emerson	27277	2022-05-12	0
Nish	27278	2022-05-12	0
Incubus	27279	2022-05-12	0
The Shirelles	27280	2022-05-12	0
Enrique Iglesias	27281	2022-05-12	0
David Keno	27282	2022-05-12	0
Easyway	27283	2022-05-12	0
The Collins Kids	27284	2022-05-12	0
The Figgs	27285	2022-05-12	0
Kapasiteettiyksikkö feat. Elastinen	27286	2022-05-12	0
Rogelio Martinez	27287	2022-05-12	0
Winston Curtis	27288	2022-05-12	0
Desert Dwellers	27289	2022-05-12	0
Explicit Samouraï	27290	2022-05-12	0
A Jealousy Issue	27291	2022-05-12	0
Sidney Bechet & His New Orleans Feetwarmers	27292	2022-05-12	0
504 Boyz / Afficial	27293	2022-05-12	0
Majestic	27294	2022-05-12	0
Luke Vibert	27295	2022-05-12	0
Enam	27296	2022-05-12	0
Baby Teeth	27297	2022-05-12	0
Scouting for Girls	27298	2022-05-12	0
Michael Franks	27299	2022-05-12	0
Gibonni	27300	2022-05-12	0
Zakir Hussain	27301	2022-05-12	0
Peter La Farge	27302	2022-05-12	0
No More	27303	2022-05-12	0
Ruben Gonzalez	27304	2022-05-12	0
Lamont Cranston	27305	2022-05-12	0
Lightspeed Champion	27306	2022-05-12	0
Sir Scratch	27307	2022-05-12	0
Mr Flash	27308	2022-05-12	0
OHM	27309	2022-05-12	0
The Wiseguys	27310	2022-05-12	0
Rhino	27311	2022-05-12	0
Alisha's Attic	27312	2022-05-12	0
Moving Ninja	27313	2022-05-12	0
Biffy Clyro	27314	2022-05-12	0
The Cruel Sea	27315	2022-05-12	0
Terminal Sound System	27316	2022-05-12	0
Hungry Lucy	27317	2022-05-12	0
Pete Townshend & Ronnie Lane	27318	2022-05-12	0
Equal 1	27319	2022-05-12	0
Chef	27320	2022-05-12	0
The Moonglows	27321	2022-05-12	0
Atlas Sound	27322	2022-05-12	0
Jim Stärk	27323	2022-05-12	0
Nuclear Assault	27324	2022-05-12	0
Lulu_ Jean Pierre Cassel_ Madeline Bell	27325	2022-05-12	0
Phenomden	27326	2022-05-12	0
Bill Laswell and Tetsu Inoue	27327	2022-05-12	0
Kenny Neal	27328	2022-05-12	0
Scanner with Rolf & Fonky	27329	2022-05-12	0
Fernando Villalona	27330	2022-05-12	0
Kurti Ostbahn	27331	2022-05-12	0
Dale Warland Singers	27332	2022-05-12	0
Erik Berglund	27333	2022-05-12	0
Producer	27334	2022-05-12	0
Manos Pyrovolakis	27335	2022-05-12	0
Tasha	27336	2022-05-12	0
Bad Religion	27337	2022-05-12	0
Shirley Caesar	27338	2022-05-12	0
Fast Distance & Static Blue	27339	2022-05-12	0
Zeena Parkins	27340	2022-05-12	0
David Bennett Cohen	27341	2022-05-12	0
Francois Dubois	27342	2022-05-12	0
Joe D'Urso & Stone Caravan	27343	2022-05-12	0
Kostas Martakis	27344	2022-05-12	0
Joseph Locke	27345	2022-05-12	0
-123min.	27346	2022-05-12	0
Jim Lauderdale/Ralph Stanley & The Clinch Mountain Boys	27347	2022-05-12	0
Iggy & The Stooges	27348	2022-05-12	0
Behind Crimson Eyes	27349	2022-05-12	0
Turn Off The Stars	27350	2022-05-12	0
Haikara	27351	2022-05-12	0
Prince Jammy And Scientist	27352	2022-05-12	0
Landon Pigg	27353	2022-05-12	0
Five Star	27354	2022-05-12	0
Missy Elliott	27355	2022-05-12	0
Gloria Estefan	27356	2022-05-12	0
X is Loaded	27357	2022-05-12	0
Sonny Terry & Brownie McGhee	27358	2022-05-12	0
7L & Esoteric	27359	2022-05-12	0
Arne Zank	27360	2022-05-12	0
Wes Dakus' Rebels	27361	2022-05-12	0
Mike Seeger	27362	2022-05-12	0
Ska Cubano	27363	2022-05-12	0
Norma Winstone_ John Taylor	27364	2022-05-12	0
The Dream Academy	27365	2022-05-12	0
Spunk	27366	2022-05-12	0
Inigo Kennedy	27367	2022-05-12	0
Year Of The Rabbit	27368	2022-05-12	0
Reba McEntire / Nurse	27369	2022-05-12	0
Dave Valentin	27370	2022-05-12	0
5th featuring Cut Throat_ Reso	27371	2022-05-12	0
Neil Young	27372	2022-05-12	0
Seeed	27373	2022-05-12	0
Lird Van Goles	27374	2022-05-12	0
2 Much	27375	2022-05-12	0
Samsaya	27376	2022-05-12	0
Raq	27377	2022-05-12	0
Contour	27378	2022-05-12	0
Texas / Suncycle	27379	2022-05-12	0
20th Century Steel Band	27380	2022-05-12	0
Ni Por Favor Ni Ostias (NPFNO)	27381	2022-05-12	0
Krizz Kaliko featuring Tech N9ne	27382	2022-05-12	0
Vince Guaraldi / Bola Sete	27383	2022-05-12	0
Peter Sellers	27384	2022-05-12	0
XU WEI	27385	2022-05-12	0
Akira Kayosa	27386	2022-05-12	0
GARFIELD	27387	2022-05-12	0
ATFC	27388	2022-05-12	0
The Cloud Room	27389	2022-05-12	0
Mickey Jupp	27390	2022-05-12	0
Johan Skugge	27391	2022-05-12	0
Flop	27392	2022-05-12	0
Ricardo Arjona	27393	2022-05-12	0
Mel Torme	27394	2022-05-12	0
The Right Ons	27395	2022-05-12	0
Annette	27396	2022-05-12	0
Accent	27397	2022-05-12	0
Cristian  Paduraru	27398	2022-05-12	0
Loikaemie	27399	2022-05-12	0
Danny Chan	27400	2022-05-12	0
The Beloved	27401	2022-05-12	0
MT	27402	2022-05-12	0
Siriusmo	27403	2022-05-12	0
María	27404	2022-05-12	0
Vex'd	27405	2022-05-12	0
Sander Kleinenberg	27406	2022-05-12	0
4hero feat. Carina Andersson	27407	2022-05-12	0
Pattern is Movement	27408	2022-05-12	0
Mariza	27409	2022-05-12	0
Lucio Dalla	27410	2022-05-12	0
Zu vs. Mats Gustafsson	27411	2022-05-12	0
Yolanda Adams	27412	2022-05-12	0
DJ Slugo	27413	2022-05-12	0
Norman Blake	27414	2022-05-12	0
The Harvest Ministers	27415	2022-05-12	0
City Center	27416	2022-05-12	0
Phantom Black	27417	2022-05-12	0
Osker	27418	2022-05-12	0
Scarlet's Remains	27419	2022-05-12	0
Goombay Dance Band	27420	2022-05-12	0
Unearthly Trance	27421	2022-05-12	0
Marmaduke Duke	27422	2022-05-12	0
Alexandra Burke	27423	2022-05-12	0
Harbhajan Talwar	27424	2022-05-12	0
Moral Crux	27425	2022-05-12	0
Jürgen von der Lippe	27426	2022-05-12	0
Nut	27427	2022-05-12	0
The Adicts	27428	2022-05-12	0
Grace Jones & Bounty Killer	27429	2022-05-12	0
Maritime	27430	2022-05-12	0
Jhelisa	27431	2022-05-12	0
Elliott The Letter Ostrich	27432	2022-05-12	0
Ian O'Brien	27433	2022-05-12	0
Deborah Coleman	27434	2022-05-12	0
Nick Conolly	27435	2022-05-12	0
Johnny Cash	27436	2022-05-12	0
Nipsey Hussle	27437	2022-05-12	0
Sacred Order	27438	2022-05-12	0
America	27439	2022-05-12	0
Tuatara	27440	2022-05-12	0
Armando feat. Sharvette	27441	2022-05-12	0
Secret Shine	27442	2022-05-12	0
Original Broadway Cast "Rent	27443	2022-05-12	0
Eva Avila	27444	2022-05-12	0
CYNE	27445	2022-05-12	0
Normand Corbeil	27446	2022-05-12	0
Dame Joan Sutherland / Ambrosian Light Opera Chorus / New Philharmonia Orchestra / Richard Bonynge	27447	2022-05-12	0
Ill Biskits	27448	2022-05-12	0
Ligeti Project	27449	2022-05-12	0
Charlie Brown Gets a Valentine	27450	2022-05-12	0
Jean-michel Rotin	27451	2022-05-12	0
Akim	27452	2022-05-12	0
Percy Sledge	27453	2022-05-12	0
Rich O'Toole	27454	2022-05-12	0
The Tallest Man On Earth	27455	2022-05-12	0
U.S.U.R.A.	27456	2022-05-12	0
The Cottars	27457	2022-05-12	0
The Biscuit Brothers_ The Wild Basin Winds	27458	2022-05-12	0
Lee Haslam	27459	2022-05-12	0
Tleilaxu	27460	2022-05-12	0
Ole feat. Paule_ Malte & Philipp	27461	2022-05-12	0
Juanita Hall	27462	2022-05-12	0
The Harmonizing Four	27463	2022-05-12	0
Fear Of Pop	27464	2022-05-12	0
Marcel Kanche / John Greaves	27465	2022-05-12	0
Matthias Heilbronn	27466	2022-05-12	0
Carmen Linares	27467	2022-05-12	0
Styrian Bootboys	27468	2022-05-12	0
Orquesta mondragon	27469	2022-05-12	0
Coco Tea	27470	2022-05-12	0
Akphaezya	27471	2022-05-12	0
Absu	27472	2022-05-12	0
Freur	27473	2022-05-12	0
Ja Rule	27474	2022-05-12	0
Gunfight!	27475	2022-05-12	0
Amy Allison	27476	2022-05-12	0
Jessica Lea Mayfield	27477	2022-05-12	0
Fergie / Will.I.Am	27478	2022-05-12	0
Spice 1 Featuring Too $hort & Ice T	27479	2022-05-12	0
Colt Ford	27480	2022-05-12	0
Ester Drang	27481	2022-05-12	0
Ensiferum	27482	2022-05-12	0
Frank Boeijen Groep	27483	2022-05-12	0
Steve Morse	27484	2022-05-12	0
Zuzana Navarova & KOA	27485	2022-05-12	0
The Outhere Brothers	27486	2022-05-12	0
Mike Dunn presents The MD X-Spress	27487	2022-05-12	0
Jamie Cullum	27488	2022-05-12	0
Metalium	27489	2022-05-12	0
Mando Diao	27490	2022-05-12	0
J Dilla aka Jay Dee feat. Frank-n-Dank	27491	2022-05-12	0
Mark Murphy	27492	2022-05-12	0
Large Professor feat. Mikey D Lotto	27493	2022-05-12	0
Engelbert Humperdink	27494	2022-05-12	0
Anton Barbeau	27495	2022-05-12	0
The Dears	27496	2022-05-12	0
Siniestro Total	27497	2022-05-12	0
Sentridoh	27498	2022-05-12	0
Albatross	27499	2022-05-12	0
Stephen Marley	27500	2022-05-12	0
Zion / Cruz Martinez	27501	2022-05-12	0
Tupelo Honey	27502	2022-05-12	0
Tom Waits & Kronos Quartet	27503	2022-05-12	0
Loudy	27504	2022-05-12	0
Die Sekte	27505	2022-05-12	0
Eddie	27506	2022-05-12	0
Hell Rell	27507	2022-05-12	0
The Alkaholiks	27508	2022-05-12	0
Greg Kobe	27509	2022-05-12	0
P.G. Six	27510	2022-05-12	0
Go:Audio	27511	2022-05-12	0
Ledernacken	27512	2022-05-12	0
Ilona Knopfler	27513	2022-05-12	0
Broken Bones	27514	2022-05-12	0
Trevor Loveys	27515	2022-05-12	0
Zeca Pagodinho	27516	2022-05-12	0
NG3	27517	2022-05-12	0
The Academy Is...	27518	2022-05-12	0
Chico Hamilton	27519	2022-05-12	0
Zez Confrey	27520	2022-05-12	0
Daz Dillinger & Kurupt Young Gotti	27521	2022-05-12	0
Crashdiet	27522	2022-05-12	0
Orquesta América	27523	2022-05-12	0
Nightrage	27524	2022-05-12	0
Richard Hagopian	27525	2022-05-12	0
Kid Andersen	27526	2022-05-12	0
Big Muff	27527	2022-05-12	0
Merilee Rush	27528	2022-05-12	0
Big John Patton	27529	2022-05-12	0
Ray Johnson Band	27530	2022-05-12	0
Hazel Dean	27531	2022-05-12	0
Jon Redfern	27532	2022-05-12	0
Webstar	27533	2022-05-12	0
Michèle Arnaud	27534	2022-05-12	0
Mark Ronson featuring Santo Gold	27535	2022-05-12	0
Wang Wen	27536	2022-05-12	0
The Destroyer	27537	2022-05-12	0
Åge Aleksandersen/Line Sofie Aleksandersen	27538	2022-05-12	0
Tishamingo	27539	2022-05-12	0
Carnival Of Souls	27540	2022-05-12	0
Sat	27541	2022-05-12	0
Am I Blood	27542	2022-05-12	0
T Rextasy	27543	2022-05-12	0
David and the High Spirit	27544	2022-05-12	0
Natural	27545	2022-05-12	0
Totimoshi	27546	2022-05-12	0
Labi Siffre	27547	2022-05-12	0
10cc	27548	2022-05-12	0
Claudia Acuna	27549	2022-05-12	0
Sporto Kantès	27550	2022-05-12	0
Shannon McNally	27551	2022-05-12	0
John Dahlbäck	27552	2022-05-12	0
A Girl Called Eddy	27553	2022-05-12	0
Jenna Drey	27554	2022-05-12	0
The Philadelphia Orchestra	27555	2022-05-12	0
Adoniran Barbosa	27556	2022-05-12	0
Daedelus featuring TTC	27557	2022-05-12	0
Peace Division	27558	2022-05-12	0
Raja	27559	2022-05-12	0
Liza Minnelli	27560	2022-05-12	0
Spencer & Hill	27561	2022-05-12	0
The Gants	27562	2022-05-12	0
The Grease Band	27563	2022-05-12	0
MC Paul Barman	27564	2022-05-12	0
Ali & Gipp / Big Rube	27565	2022-05-12	0
Molemen	27566	2022-05-12	0
Phil Lesh and Friends	27567	2022-05-12	0
Tristan Garner_ Crystal Waters	27568	2022-05-12	0
Twinkle Twinkle Little Rock Star	27569	2022-05-12	0
Take It Back!	27570	2022-05-12	0
Venice is Sinking	27571	2022-05-12	0
Tim Hardin	27572	2022-05-12	0
Chipmunk / N-Dubz	27573	2022-05-12	0
The Faders	27574	2022-05-12	0
The Rainbow Orchestra	27575	2022-05-12	0
Maikel De La Riva	27576	2022-05-12	0
Impulse Manslaughter	27577	2022-05-12	0
JJ Flores & Steve Smooth	27578	2022-05-12	0
Jolie Holland	27579	2022-05-12	0
Watashi Wa	27580	2022-05-12	0
Cordrazine	27581	2022-05-12	0
Katie Noonan and the Captains	27582	2022-05-12	0
Bernie Worrell	27583	2022-05-12	0
Under Byen	27584	2022-05-12	0
The MacHines	27585	2022-05-12	0
Soul Embraced	27586	2022-05-12	0
Men of Unitus	27587	2022-05-12	0
The Xcerts/The Blueskies	27588	2022-05-12	0
KMC Feat. Dhany	27589	2022-05-12	0
Ernie Watts	27590	2022-05-12	0
Keel	27591	2022-05-12	0
Dario Zenker	27592	2022-05-12	0
Not Waving But Drowning	27593	2022-05-12	0
Honkytonk Homeslice	27594	2022-05-12	0
Timbaland & Magoo	27595	2022-05-12	0
Lene Lovich	27596	2022-05-12	0
The Out_Circuit	27597	2022-05-12	0
Pedro Maffia	27598	2022-05-12	0
Jochen Miller	27599	2022-05-12	0
Maki Ohguro	27600	2022-05-12	0
Canteca de macao	27601	2022-05-12	0
Mettle Music featuring Sandi Thom	27602	2022-05-12	0
Orange Blue	27603	2022-05-12	0
Carlos Jimenez_ J Elvira_ Oliversam	27604	2022-05-12	0
Diego Hostettler	27605	2022-05-12	0
Johnny "Guitar" Watson	27606	2022-05-12	0
Into It. Over It.	27607	2022-05-12	0
Bob Crosby	27608	2022-05-12	0
I:Cube	27609	2022-05-12	0
Young Gunz / Beanie Sigel	27610	2022-05-12	0
Yellowman	27611	2022-05-12	0
Brandy duet with Monica	27612	2022-05-12	0
Sugar Creek	27613	2022-05-12	0
Diego Verdaguer	27614	2022-05-12	0
Jah Shaka & Mad Professor	27615	2022-05-12	0
Daby Balde	27616	2022-05-12	0
We Are The World	27617	2022-05-12	0
The Hugh Dillon Redemption Choir	27618	2022-05-12	0
Mino Reitano	27619	2022-05-12	0
NightWaves	27620	2022-05-12	0
Praxis	27621	2022-05-12	0
Leningrad Cowboys	27622	2022-05-12	0
Gorillaz	27623	2022-05-12	0
From The Ashes	27624	2022-05-12	0
Kirk Franklin & The Family	27625	2022-05-12	0
Neil Norman	27626	2022-05-12	0
Whatever It Takes	27627	2022-05-12	0
Pure Prairie League	27628	2022-05-12	0
Lack Of Afro	27629	2022-05-12	0
Chilled By Nature	27630	2022-05-12	0
Anthony Braxton	27631	2022-05-12	0
DaySleepers	27632	2022-05-12	0
The Production Club	27633	2022-05-12	0
Jeff Rona	27634	2022-05-12	0
Belouis Some	27635	2022-05-12	0
Lucky 7	27636	2022-05-12	0
Manian feat. aila	27637	2022-05-12	0
Kosmo Koslowski	27638	2022-05-12	0
Will Ferrell / Neil Diamond	27639	2022-05-12	0
Subsky	27640	2022-05-12	0
Luciano Berio	27641	2022-05-12	0
Marasma	27642	2022-05-12	0
Cynic	27643	2022-05-12	0
Fiorella Mannoia	27644	2022-05-12	0
David Gilmour	27645	2022-05-12	0
Mass Movement Of The Moth	27646	2022-05-12	0
THE THREE DEGREES	27647	2022-05-12	0
Allan O'Marshall	27648	2022-05-12	0
MORBLUS - Funky Blues Band	27649	2022-05-12	0
The Presence	27650	2022-05-12	0
Strangeways	27651	2022-05-12	0
Swami	27652	2022-05-12	0
Dan Curtin	27653	2022-05-12	0
Bullet For My Valentine	27654	2022-05-12	0
Hate Eternal	27655	2022-05-12	0
Barbara Lea	27656	2022-05-12	0
Streetlife	27657	2022-05-12	0
DJ Antention	27658	2022-05-12	0
U-Piter	27659	2022-05-12	0
Emotion Code	27660	2022-05-12	0
PuppetGeneration	27661	2022-05-12	0
Rekka Katakiri	27662	2022-05-12	0
Monty	27663	2022-05-12	0
The Mystic Moods Orchestra	27664	2022-05-12	0
N-Trance	27665	2022-05-12	0
Najwa Karam	27666	2022-05-12	0
Martine McCutcheon	27667	2022-05-12	0
Robert Johnson	27668	2022-05-12	0
Painkiller	27669	2022-05-12	0
Mohamed Lamine	27670	2022-05-12	0
Common Enemy	27671	2022-05-12	0
Platero Y Tu	27672	2022-05-12	0
Folk Implosion	27673	2022-05-12	0
The Aluminum Group	27674	2022-05-12	0
Karl Jenkins;Caitrin Finch	27675	2022-05-12	0
Roser	27676	2022-05-12	0
Minimalistix	27677	2022-05-12	0
Charlie Jones	27678	2022-05-12	0
Rusty Draper	27679	2022-05-12	0
Renegade Hit Makers	27680	2022-05-12	0
Shirley Murdock	27681	2022-05-12	0
Stephan Micus	27682	2022-05-12	0
Zweitfrau	27683	2022-05-12	0
Spineshank	27684	2022-05-12	0
Willy Porter	27685	2022-05-12	0
Friedel Hensch & die Cyprys	27686	2022-05-12	0
Axxis	27687	2022-05-12	0
Rapider Than Horsepower	27688	2022-05-12	0
Javier Solis	27689	2022-05-12	0
Manna	27690	2022-05-12	0
Kate Walsh	27691	2022-05-12	0
Ravenryde	27692	2022-05-12	0
Crookers feat. Kardinal Offishall & Carla-Marie	27693	2022-05-12	0
AIDS Wolf VS Athletic Automaton	27694	2022-05-12	0
Hape Kerkeling	27695	2022-05-12	0
Davy Van Eynde feat. Fara	27696	2022-05-12	0
Judy Trejo	27697	2022-05-12	0
Groovecatcher	27698	2022-05-12	0
Texas Terri Bomb	27699	2022-05-12	0
The Major	27700	2022-05-12	0
Jackson Browne	27701	2022-05-12	0
C & C Music Factory	27702	2022-05-12	0
Étienne Daho	27703	2022-05-12	0
Bikini Kill	27704	2022-05-12	0
Los Prisioneros	27705	2022-05-12	0
Where Angels Fall	27706	2022-05-12	0
Mantovani	27707	2022-05-12	0
ROBERT MILES Feat. KATHY SLEDGE	27708	2022-05-12	0
CC Cowboys	27709	2022-05-12	0
Dilated Peoples	27710	2022-05-12	0
Angelo dei Teppisti dei Sogni	27711	2022-05-12	0
Ara Ketu	27712	2022-05-12	0
Solefald	27713	2022-05-12	0
The Peter Brötzmann Octet	27714	2022-05-12	0
MC Basstard	27715	2022-05-12	0
Miguel Mateus	27716	2022-05-12	0
Jad Fair	27717	2022-05-12	0
Super-Wolf	27718	2022-05-12	0
Adam Richmond	27719	2022-05-12	0
Mama Cass	27720	2022-05-12	0
31Knots	27721	2022-05-12	0
Tex Beneke And His Orchestra	27722	2022-05-12	0
Fabio & Glitter Klinik	27723	2022-05-12	0
Guaco	27724	2022-05-12	0
Shabaam Sahdeeq & DJ Revolution	27725	2022-05-12	0
Paul Simon	27726	2022-05-12	0
Two Fingers	27727	2022-05-12	0
Rory Gallagher	27728	2022-05-12	0
Daedelus	27729	2022-05-12	0
Michel Korb	27730	2022-05-12	0
Tiësto	27731	2022-05-12	0
Caleb's Cosmosis	27732	2022-05-12	0
L.T.D.	27733	2022-05-12	0
Grzegorz Turnau	27734	2022-05-12	0
Ryan Star	27735	2022-05-12	0
Six Ft Ditch	27736	2022-05-12	0
Lotte Lenya & Cast	27737	2022-05-12	0
Boom Boom Satellites	27738	2022-05-12	0
Donny Hathaway	27739	2022-05-12	0
Emmerson Nogueira	27740	2022-05-12	0
The Sequence	27741	2022-05-12	0
Mano Solo	27742	2022-05-12	0
Spirea X	27743	2022-05-12	0
The Lovejoys	27744	2022-05-12	0
The Forces Of Evil	27745	2022-05-12	0
The Honor System	27746	2022-05-12	0
Kate & Anna McGarrigle	27747	2022-05-12	0
Charming	27748	2022-05-12	0
Neal McCoy	27749	2022-05-12	0
Himsa	27750	2022-05-12	0
Reik	27751	2022-05-12	0
Django Reinhardt & Stephane Grappelli	27752	2022-05-12	0
Throw Me The Statue	27753	2022-05-12	0
Dataworx	27754	2022-05-12	0
Grupo Revelação	27755	2022-05-12	0
Flee the Seen	27756	2022-05-12	0
The Charlie Byrd Trio	27757	2022-05-12	0
Antony Costa	27758	2022-05-12	0
Mr. Shadow_ Señor Sombra_ El Chivo	27759	2022-05-12	0
Fabiana Cantilo	27760	2022-05-12	0
Champion Jack Dupree	27761	2022-05-12	0
Michael Schwarz	27762	2022-05-12	0
Ambitious Lovers	27763	2022-05-12	0
Baader Meinhof	27764	2022-05-12	0
The Bakerton Group	27765	2022-05-12	0
Saigon_ Inspectah Deck & Bekay	27766	2022-05-12	0
Black Diamond Heavies	27767	2022-05-12	0
Mariana	27768	2022-05-12	0
Killa Kamillionz	27769	2022-05-12	0
Neljä Ruusua	27770	2022-05-12	0
Granfaloon Bus	27771	2022-05-12	0
Luz Divina	27772	2022-05-12	0
HIGHKO	27773	2022-05-12	0
Gang Starr Featuring K-CI Jojo	27774	2022-05-12	0
Connie Francis	27775	2022-05-12	0
Trigon	27776	2022-05-12	0
Koro	27777	2022-05-12	0
Fast Cars	27778	2022-05-12	0
Sleeping With Sirens	27779	2022-05-12	0
Unni Wilhelmsen	27780	2022-05-12	0
Vasco Rossi	27781	2022-05-12	0
Swan Lake	27783	2022-05-12	0
Michael Giacchino	27784	2022-05-12	0
Nitin Sawhney_ Anthony Gormley	27785	2022-05-12	0
Pressure	27786	2022-05-12	0
Mauro Bisi	27787	2022-05-12	0
Bernard Butler	27788	2022-05-12	0
Rob Symeonn Featuring Willow Wilson	27789	2022-05-12	0
Vier zu Eins	27790	2022-05-12	0
Hope Sandoval and the Warm Inventions	27791	2022-05-12	0
Velvetine	27792	2022-05-12	0
Showbread	27793	2022-05-12	0
C-Mon	27794	2022-05-12	0
Faunts	27795	2022-05-12	0
Sporto Kantes	27796	2022-05-12	0
Herman Brood & His Wild Romance	27797	2022-05-12	0
Charlie Drake	27798	2022-05-12	0
Tongue N Cheek	27799	2022-05-12	0
Lisa Lashes & Bk featuring Lisa Lashes	27800	2022-05-12	0
Renato Borghetti	27801	2022-05-12	0
Johnny Hodges and Hist Orchestra	27802	2022-05-12	0
Zydeco Hurricanes	27803	2022-05-12	0
Jacob Sisters	27804	2022-05-12	0
Jacques Renault	27805	2022-05-12	0
Paul Brown	27806	2022-05-12	0
Archon Satani	27807	2022-05-12	0
Vendetta	27808	2022-05-12	0
Tony Rohr & Tim Xavier	27809	2022-05-12	0
Stefani	27810	2022-05-12	0
The Real McKenzies	27811	2022-05-12	0
Van Zant	27812	2022-05-12	0
Kevin Blechdom	27813	2022-05-12	0
Steve Birch	27814	2022-05-12	0
Yamboo	27815	2022-05-12	0
Jack Bruce	27816	2022-05-12	0
Stefanie Bennett	27817	2022-05-12	0
The Tex Mex Experience	27818	2022-05-12	0
The Mojos	27819	2022-05-12	0
Amaran's Plight	27820	2022-05-12	0
Severed Savior	27821	2022-05-12	0
Mathematik	27822	2022-05-12	0
Ugly Kid Joe	27823	2022-05-12	0
Peter Kater	27824	2022-05-12	0
Eddie Boyd	27825	2022-05-12	0
Golfclvb	27826	2022-05-12	0
Hot Little Rocket	27827	2022-05-12	0
George Clinton and Parliament	27828	2022-05-12	0
Musab	27829	2022-05-12	0
James Hardway	27830	2022-05-12	0
DJ Jazzy Jeff	27831	2022-05-12	0
Elton Motello	27832	2022-05-12	0
Hue And Cry	27833	2022-05-12	0
Divinyls	27834	2022-05-12	0
Bally Jagpal	27835	2022-05-12	0
Orange Bicycle	27836	2022-05-12	0
Eyedea & Abilities	27837	2022-05-12	0
A Balladeer	27838	2022-05-12	0
Lili Kraus	27839	2022-05-12	0
Stereo Total	27840	2022-05-12	0
Jay-Z / Beyoncé	27841	2022-05-12	0
Confederate Railroad	27842	2022-05-12	0
Panteón Rococó	27843	2022-05-12	0
Yahel	27844	2022-05-12	0
Xavier Quijas Yxayotl	27845	2022-05-12	0
Virgin Black	27846	2022-05-12	0
Ace of Base	27847	2022-05-12	0
Maysa	27848	2022-05-12	0
CHANICE	27849	2022-05-12	0
Bug/Rootsman/Daddy Freddy/DJ Rupture	27850	2022-05-12	0
Richard Chartier	27851	2022-05-12	0
Greg Billings Band	27852	2022-05-12	0
Ben Ricour	27853	2022-05-12	0
Shootyz Groove	27854	2022-05-12	0
Born To Lose	27855	2022-05-12	0
Koyi K Utho	27856	2022-05-12	0
The Special AKA	27857	2022-05-12	0
Zero System	27858	2022-05-12	0
The Lost Patrol	27859	2022-05-12	0
Jackie Greene	27860	2022-05-12	0
David & The Citizens	27861	2022-05-12	0
Julie Andrews	27862	2022-05-12	0
Noblesse Oblige	27863	2022-05-12	0
Soko Friedhof	27864	2022-05-12	0
Eric Dolphy / Booker Little	27865	2022-05-12	0
Donell Jones	27866	2022-05-12	0
Hassan Annouri	27867	2022-05-12	0
Junior Byles	27868	2022-05-12	0
Dubee aka Sugawolf	27869	2022-05-12	0
DJ KAYSLAY featuring Memphis Bleek_ Sauce Money and The Game	27870	2022-05-12	0
Skid Row	27871	2022-05-12	0
DJ Sakin vs. weimaR	27872	2022-05-12	0
Arthur Conley	27873	2022-05-12	0
91 Suite	27874	2022-05-12	0
DJ Yoda	27875	2022-05-12	0
Ed Ames	27876	2022-05-12	0
Music Junkies	27877	2022-05-12	0
Mr. Mister	27878	2022-05-12	0
David Guetta - Joachim Garraud - Chris Willis	27879	2022-05-12	0
Dol Ammad	27880	2022-05-12	0
Carol Channing;Eileen Brennan;Sondra Lee;Shepard Coleman	27881	2022-05-12	0
The Locust	27882	2022-05-12	0
Pearly Gates	27883	2022-05-12	0
Wednesday 13	27884	2022-05-12	0
O'Donel Levy	27885	2022-05-12	0
Los Hermanos Zuleta	27886	2022-05-12	0
Kid Dynamite	27887	2022-05-12	0
The Disco Boys feat. Midge Ure	27888	2022-05-12	0
Sixsense	27889	2022-05-12	0
The Pigeon Detectives	27890	2022-05-12	0
Polar	27891	2022-05-12	0
Standgericht	27892	2022-05-12	0
Cecil Taylor_ Jazz Composer's Orchestra_ Michael Mantler	27893	2022-05-12	0
Huey Lewis And The News	27894	2022-05-12	0
Anson Funderburgh and The Rockets	27895	2022-05-12	0
Tindersticks / Anne Magnusson	27896	2022-05-12	0
Spacetime Continuum	27897	2022-05-12	0
We Are The Arsenal	27898	2022-05-12	0
Christina Milian	27899	2022-05-12	0
Craig Ferguson	27900	2022-05-12	0
Big Shanty	27901	2022-05-12	0
Gloria Loring	27902	2022-05-12	0
Normaal	27903	2022-05-12	0
Dado Moroni_ M.Moriconi_ S.Bagnoli	27904	2022-05-12	0
Swinging Steaks	27905	2022-05-12	0
K.Maro	27906	2022-05-12	0
Yung Ralph	27907	2022-05-12	0
Lea Salonga	27908	2022-05-12	0
Klaus Lage	27909	2022-05-12	0
Get Busy Committee	27910	2022-05-12	0
David Lindley	27911	2022-05-12	0
Smitty	27912	2022-05-12	0
DSP	27913	2022-05-12	0
Quincy Jones & Dinah Washington	27914	2022-05-12	0
The Drifters	27915	2022-05-12	0
Mademoiselle K.	27916	2022-05-12	0
Violet Indiana	27917	2022-05-12	0
Tenth Planet	27918	2022-05-12	0
X-Press 2	27919	2022-05-12	0
Anna Oxa	27920	2022-05-12	0
Ahmet Sisman	27921	2022-05-12	0
Selena Leo	27922	2022-05-12	0
Raul Mezcolanza and Bob D	27923	2022-05-12	0
Sidewalk Prophets	27924	2022-05-12	0
CJ Stone	27925	2022-05-12	0
Don Francisco	27926	2022-05-12	0
Peter White	27927	2022-05-12	0
Nelson Riddle	27928	2022-05-12	0
Joris Voorn	27929	2022-05-12	0
Michelle Branch	27930	2022-05-12	0
Spike Milligan	27931	2022-05-12	0
Alexander V.Mogilco	27932	2022-05-12	0
Def Harmonic	27933	2022-05-12	0
Finger & Kadel	27934	2022-05-12	0
L'âme Immortelle	27935	2022-05-12	0
Duck Baker	27936	2022-05-12	0
Neko Case	27937	2022-05-12	0
Miguel Puente	27938	2022-05-12	0
Anguish Force	27939	2022-05-12	0
Kerry Leigh and Expresso Lane	27940	2022-05-12	0
Don Dokken	27941	2022-05-12	0
Lexi	27942	2022-05-12	0
Magic Sound Fabric	27943	2022-05-12	0
Dulce Liquido	27944	2022-05-12	0
56 Hope Road	27945	2022-05-12	0
Jeff Lorber	27946	2022-05-12	0
Decoded Feedback	27947	2022-05-12	0
Franz Joseph Haydn	27948	2022-05-12	0
9th Wonder	27949	2022-05-12	0
Sharron Kraus	27950	2022-05-12	0
Pnau	27951	2022-05-12	0
Living Things	27952	2022-05-12	0
Dominoe	27953	2022-05-12	0
The Ghost Of Lemora	27954	2022-05-12	0
Amampondo	27955	2022-05-12	0
Brasilian Tropical Orchestra	27956	2022-05-12	0
Merzbow Vs Nordvargr	27957	2022-05-12	0
Murder Inc.	27958	2022-05-12	0
Sue Keller	27959	2022-05-12	0
Last Rough Cause	27960	2022-05-12	0
Ryan Auffenberg	27961	2022-05-12	0
Iron Maiden	27962	2022-05-12	0
The Besties	27963	2022-05-12	0
The Cooper Temple Clause	27964	2022-05-12	0
The Dramatics	27965	2022-05-12	0
Burden Of A Day	27966	2022-05-12	0
Shanadoo	27967	2022-05-12	0
Martha Wainwright	27968	2022-05-12	0
The Felice Brothers	27969	2022-05-12	0
Paul Trainer	27970	2022-05-12	0
Stetsasonic	27971	2022-05-12	0
Paulinho Da Viola	27972	2022-05-12	0
Leo Ku	27973	2022-05-12	0
Yeti	27974	2022-05-12	0
Grown Ups	27975	2022-05-12	0
Perry Como	27976	2022-05-12	0
Johann Köhnich	27977	2022-05-12	0
Elvis Costello & The Imposters	27978	2022-05-12	0
Kiave	27979	2022-05-12	0
Jedi Mind Tricks	27980	2022-05-12	0
Masse_ Laurel	27981	2022-05-12	0
Cybervixen	27982	2022-05-12	0
The Samuel Jackson Five	27983	2022-05-12	0
Thee Zu	27984	2022-05-12	0
Ten Volt Shock	27985	2022-05-12	0
These United States	27986	2022-05-12	0
Boyzone	27987	2022-05-12	0
GUSTAV MCLOUD	27988	2022-05-12	0
Eazy E	27989	2022-05-12	0
Alison Moyet	27990	2022-05-12	0
Kirinji	27991	2022-05-12	0
The Fall-Outs	27992	2022-05-12	0
Charles Brown with Johnny Otis featuring Shuggie Otis	27993	2022-05-12	0
Cutthroats 9	27994	2022-05-12	0
Die Roten Rosen	27995	2022-05-12	0
Python	27996	2022-05-12	0
Elva Hsiao	27997	2022-05-12	0
Gazebo	27998	2022-05-12	0
Knut Værnes & Terje Gewelt	27999	2022-05-12	0
Robert Pete Williams	28000	2022-05-12	0
SonicC	28001	2022-05-12	0
Brendan Perry	28002	2022-05-12	0
Aurélien Merle	28003	2022-05-12	0
Jeff Beck / The Immediate All-Stars	28004	2022-05-12	0
EM1	28005	2022-05-12	0
The Cutting Edge	28006	2022-05-12	0
Margaret Smith	28007	2022-05-12	0
Vicious featuring Wochee	28008	2022-05-12	0
Eminem / Various Artists	28009	2022-05-12	0
Derek Howell	28010	2022-05-12	0
Anthony Cruz	28011	2022-05-12	0
Dive	28012	2022-05-12	0
London Community Gospel Choir	28013	2022-05-12	0
DJ Laz	28014	2022-05-12	0
Dave Loggins	28015	2022-05-12	0
Kleerup	28016	2022-05-12	0
Marc Perrone	28017	2022-05-12	0
Thomas Denver Jonsson	28018	2022-05-12	0
Anna Eriksson	28019	2022-05-12	0
Towa Carson/Mats Olssons Orkester	28020	2022-05-12	0
The Jancee Pornick Casino	28021	2022-05-12	0
Sonora Matancera	28022	2022-05-12	0
Gartnerlosjen	28023	2022-05-12	0
bathory	28024	2022-05-12	0
Jessica Andersson	28025	2022-05-12	0
Gasolin'	28026	2022-05-12	0
Moly	28027	2022-05-12	0
Rose Moore	28028	2022-05-12	0
All Natural Lemon And Lime Flavors	28029	2022-05-12	0
The Bomboras	28030	2022-05-12	0
Slepcy	28031	2022-05-12	0
CoCo Lee	28032	2022-05-12	0
The Run	28033	2022-05-12	0
Namnambulu	28034	2022-05-12	0
Komytea	28035	2022-05-12	0
Keb' Mo'	28036	2022-05-12	0
Ghetto & Gangsta	28037	2022-05-12	0
Daylight Torn	28038	2022-05-12	0
Ok Cobra	28039	2022-05-12	0
Big Joe Duskin	28040	2022-05-12	0
Richard Wahnfried	28041	2022-05-12	0
The Beat Farmers	28042	2022-05-12	0
The Lyndsay Diaries	28043	2022-05-12	0
The Watts Prophets	28044	2022-05-12	0
James Newton Howard	28045	2022-05-12	0
Steppah Huntah	28046	2022-05-12	0
Cecilia Bartoli / Orchestra La Scintilla / Adam Fischer	28047	2022-05-12	0
Busted	28048	2022-05-12	0
Original Love	28049	2022-05-12	0
Pienvedeja piedzivojumi	28050	2022-05-12	0
Tony	28051	2022-05-12	0
Les Heureux Perdus	28052	2022-05-12	0
King Britt & Tim Motzer	28053	2022-05-12	0
Altenberg Trio Wien	28054	2022-05-12	0
Joan Osborne	28055	2022-05-12	0
DJ Wally	28056	2022-05-12	0
Billy Bob Thornton	28057	2022-05-12	0
Tenacious D	28058	2022-05-12	0
Joe Bataan	28059	2022-05-12	0
Mark Masri	28060	2022-05-12	0
Depth Charge	28061	2022-05-12	0
Klément Julienne	28062	2022-05-12	0
Luther "Guitar Jr" Johnson	28063	2022-05-12	0
Tiromancino	28064	2022-05-12	0
Sgt. Bilko's Krazy Combo	28065	2022-05-12	0
Germano Mathias	28066	2022-05-12	0
The Diableros	28067	2022-05-12	0
TC Matic	28068	2022-05-12	0
Modestia Aparte	28069	2022-05-12	0
Peggy Seeger	28070	2022-05-12	0
Murray Head	28071	2022-05-12	0
Carnal Forge	28072	2022-05-12	0
Klee	28073	2022-05-12	0
Gabriel Yared	28074	2022-05-12	0
Jeffrey Lewis & The Junkyard	28075	2022-05-12	0
Public Enemy Featuring Paris	28076	2022-05-12	0
Peggy Zina	28077	2022-05-12	0
Orpheus	28078	2022-05-12	0
East West Blast Test	28079	2022-05-12	0
The Souljazz Orchestra	28080	2022-05-12	0
Mekkanikka	28081	2022-05-12	0
Feline	28082	2022-05-12	0
Patti Page	28083	2022-05-12	0
Chick Webb & His Orchestra	28084	2022-05-12	0
Kix	28085	2022-05-12	0
Jimbo Ross	28086	2022-05-12	0
Vybz Kartel	28087	2022-05-12	0
Mack 10	28088	2022-05-12	0
Arve Henriksen & Elling Vanberg	28089	2022-05-12	0
The Sedan Vault	28090	2022-05-12	0
Eric Baule	28091	2022-05-12	0
L'SKADRILLE	28092	2022-05-12	0
Marco Paulo	28093	2022-05-12	0
Planet Funk	28094	2022-05-12	0
Samian	28095	2022-05-12	0
DJ Yanny	28096	2022-05-12	0
Voorhees	28097	2022-05-12	0
Detritus	28098	2022-05-12	0
Go Drowsy	28099	2022-05-12	0
The Jacksons	28100	2022-05-12	0
Gottfried Böttger / Joe Pentzlin	28101	2022-05-12	0
Leroy Carr	28102	2022-05-12	0
These Are Powers	28103	2022-05-12	0
Let's Get It	28104	2022-05-12	0
Hybrid Leisureland	28105	2022-05-12	0
Nancy Wilson	28106	2022-05-12	0
Hawthorne Heights	28107	2022-05-12	0
kalapana	28108	2022-05-12	0
Big Sandy and his Fly-Rite Boys	28109	2022-05-12	0
Guerilla Black feat. Alex Thomas and Vonda Hope-Easton	28110	2022-05-12	0
Palodine	28111	2022-05-12	0
Cella Dwellas	28112	2022-05-12	0
King Tubby	28113	2022-05-12	0
2 Skinnee J's	28114	2022-05-12	0
Grupo X	28115	2022-05-12	0
Radio Slave	28116	2022-05-12	0
Blonde On Blonde	28117	2022-05-12	0
Landing	28118	2022-05-12	0
Brotha Lynch Hung	28119	2022-05-12	0
Caural	28120	2022-05-12	0
Acid Flux	28121	2022-05-12	0
Aly-Us	28122	2022-05-12	0
Flux Pavilion	28123	2022-05-12	0
Glen Ricks	28124	2022-05-12	0
The Partridge Family	28125	2022-05-12	0
Mario Frangoulis	28126	2022-05-12	0
Heresy	28127	2022-05-12	0
Cool Hipnoise	28128	2022-05-12	0
Tommy Emmanuel	28129	2022-05-12	0
Inner City	28130	2022-05-12	0
Spacebox	28131	2022-05-12	0
Craving Lucy	28132	2022-05-12	0
Goloka	28133	2022-05-12	0
Waylon Jennings & Jessi Colter	28134	2022-05-12	0
Marco Demark feat. Peter Millwood	28135	2022-05-12	0
Thee Maddkatt Courtship III	28136	2022-05-12	0
Vicente Fernandez	28137	2022-05-12	0
Rainbow	28138	2022-05-12	0
Assemblage 23	28139	2022-05-12	0
Denison Witmer	28140	2022-05-12	0
Explosions In The Sky	28141	2022-05-12	0
André Minvielle	28142	2022-05-12	0
Unité 2 Feu	28143	2022-05-12	0
Willy Mason	28144	2022-05-12	0
Cressida	28145	2022-05-12	0
Falete	28146	2022-05-12	0
The Hotknives	28147	2022-05-12	0
Scott Dunbar	28148	2022-05-12	0
Barry Blue	28149	2022-05-12	0
Don Choa Featuring Zaho	28150	2022-05-12	0
Sydney Youngblood	28151	2022-05-12	0
The Rurals	28152	2022-05-12	0
Frijid Pink	28153	2022-05-12	0
Patti LuPone;Howard McGillin;Rex Everhart;Steve Steiner;Edward Strauss	28154	2022-05-12	0
Devotchka	28155	2022-05-12	0
The Flying Burrito Brothers	28156	2022-05-12	0
Ed Rush	28157	2022-05-12	0
Snapcase	28158	2022-05-12	0
Die Arbeitslosen Bauarbeiter	28159	2022-05-12	0
Bugs Henderson	28160	2022-05-12	0
Otha Turner and the Rising Star Fife & Drum Band	28161	2022-05-12	0
Monrose	28162	2022-05-12	0
The Lancashire Hotpots	28163	2022-05-12	0
Publo Hunny	28164	2022-05-12	0
Claude Gray	28165	2022-05-12	0
Pat Kelly	28166	2022-05-12	0
Sinéad Lohan	28167	2022-05-12	0
Nena Daconte	28168	2022-05-12	0
Howard Shore	28169	2022-05-12	0
Lamont Dozier	28170	2022-05-12	0
Paragons	28171	2022-05-12	0
Dragons Of Zynth	28172	2022-05-12	0
Future Of Forestry	28173	2022-05-12	0
Revolverheld	28174	2022-05-12	0
El Koala	28175	2022-05-12	0
Portable	28176	2022-05-12	0
Above The Golden State	28177	2022-05-12	0
Divo	28178	2022-05-12	0
Kob	28179	2022-05-12	0
DJ Cheb I Sabbah	28180	2022-05-12	0
Naia	28181	2022-05-12	0
Roshan	28182	2022-05-12	0
Julio Iglesias duet with Willie Nelson	28183	2022-05-12	0
Steve Forbert	28184	2022-05-12	0
Smoke Or Fire	28185	2022-05-12	0
Basia	28186	2022-05-12	0
Tom Ellis	28187	2022-05-12	0
Christophe Willem	28188	2022-05-12	0
Pursuit Of Happiness	28189	2022-05-12	0
Energy	28190	2022-05-12	0
Roger Williams	28191	2022-05-12	0
Mario Frangoulis feat. Jeff Leyton	28192	2022-05-12	0
Tony Jackson	28193	2022-05-12	0
Elliott Sharp	28194	2022-05-12	0
Condemned 84	28195	2022-05-12	0
Jose Amnesia Feat. Jennifer Rene	28196	2022-05-12	0
Winston Wright / Larry McDonald	28197	2022-05-12	0
Kristine W	28198	2022-05-12	0
Kaoma	28199	2022-05-12	0
Mario Calegari	28200	2022-05-12	0
Eduardo Araujo	28201	2022-05-12	0
Gloria Gaynor	28202	2022-05-12	0
The Latin Kings	28203	2022-05-12	0
Chico Cesar	28204	2022-05-12	0
Great Lake Swimmers	28205	2022-05-12	0
Calvin Harris	28206	2022-05-12	0
La Taverne Du Lac	28207	2022-05-12	0
Sapo	28208	2022-05-12	0
Frank Morgan & T. Bone Wolk	28209	2022-05-12	0
Shameboy	28210	2022-05-12	0
Hound Dog Taylor and The Houserockers	28211	2022-05-12	0
Northern Kings	28212	2022-05-12	0
Little Willie Littlefield	28213	2022-05-12	0
King Tubby & Soul Syndicate	28214	2022-05-12	0
La Tradicion Del Norte	28215	2022-05-12	0
Dirty Faces	28216	2022-05-12	0
Blackfield	28217	2022-05-12	0
John Mellencamp	28218	2022-05-12	0
Natlife	28219	2022-05-12	0
Jose Julian	28220	2022-05-12	0
Vince Gill	28221	2022-05-12	0
Eddie Sender	28222	2022-05-12	0
The Nixons	28223	2022-05-12	0
David Byrne & Fatboy Slim	28224	2022-05-12	0
Teenagers In Tokyo	28225	2022-05-12	0
B-Tight_ Tony D_ G-Hot_ Fler_ Sido_ Alpa Gun	28226	2022-05-12	0
Grover Washington Jr.	28227	2022-05-12	0
Jason Collett	28228	2022-05-12	0
Suicide Silence	28229	2022-05-12	0
Cub Country	28230	2022-05-12	0
Plastic Operator	28231	2022-05-12	0
Bipolar Bear	28232	2022-05-12	0
Roy Drusky	28233	2022-05-12	0
Papas Da Língua	28234	2022-05-12	0
Maria Muldaur	28235	2022-05-12	0
Gideon Smith and the Dixie Damned	28236	2022-05-12	0
TURNING POINT	28237	2022-05-12	0
Ramon Orlando	28238	2022-05-12	0
GZA/Genius	28239	2022-05-12	0
Mikhail Pletnev	28240	2022-05-12	0
Pulley	28241	2022-05-12	0
Stille Volk	28242	2022-05-12	0
Billy Joe Royal	28243	2022-05-12	0
Kagerou	28244	2022-05-12	0
Passion	28245	2022-05-12	0
The Bobby McGees	28246	2022-05-12	0
Pepe Romero	28247	2022-05-12	0
Tenishia	28248	2022-05-12	0
Jochen Distelmeyer	28249	2022-05-12	0
Giorgio Gaber	28250	2022-05-12	0
Jope Ruonansuu	28251	2022-05-12	0
Megaptera	28252	2022-05-12	0
Susannah McCorkle	28253	2022-05-12	0
Helen Merrill	28254	2022-05-12	0
Marvelous 3	28255	2022-05-12	0
MISERY INDEX	28256	2022-05-12	0
David Carretta	28257	2022-05-12	0
For Absent Friends	28258	2022-05-12	0
Claude-Michel Schönberg	28259	2022-05-12	0
Molly Hatchet	28260	2022-05-12	0
Julie Feeney	28261	2022-05-12	0
Michael Dietmayr	28262	2022-05-12	0
Kenny "Dope" Gonzalez	28263	2022-05-12	0
Into The Abyss	28264	2022-05-12	0
Jinx	28265	2022-05-12	0
Scars	28266	2022-05-12	0
Ensemble Project Ars Nova	28267	2022-05-12	0
Jessy	28268	2022-05-12	0
Stan Freberg	28269	2022-05-12	0
Perez Prado	28270	2022-05-12	0
Foundation Hope	28271	2022-05-12	0
WINTERS BANE	28272	2022-05-12	0
Rajna Spasovska	28273	2022-05-12	0
Keri Noble	28274	2022-05-12	0
Tim Wilson	28275	2022-05-12	0
Dean Evenson	28276	2022-05-12	0
Shitmat	28277	2022-05-12	0
Laika & The Cosmonauts	28278	2022-05-12	0
The Katinas	28279	2022-05-12	0
Eddie 'Cleanhead' Vinson	28280	2022-05-12	0
Norell & Napoli	28281	2022-05-12	0
Le Mans	28282	2022-05-12	0
Hector Couto	28283	2022-05-12	0
Oforia	28284	2022-05-12	0
Joey Negro and the Sunburst Band	28285	2022-05-12	0
Mike Dunn	28286	2022-05-12	0
Black Mighty Orchestra	28287	2022-05-12	0
The Charmers	28288	2022-05-12	0
Phillips_ Craig And Dean	28289	2022-05-12	0
Mr. Airplane Man	28290	2022-05-12	0
Deion Sanders	28291	2022-05-12	0
Seal	28292	2022-05-12	0
The Norman Luboff Choir	28293	2022-05-12	0
Mexican Institute of Sound	28294	2022-05-12	0
Wyclef Jean featuring Ayesha and Papa Don	28295	2022-05-12	0
Slim Whitman	28296	2022-05-12	0
X-Raided	28297	2022-05-12	0
Maceo Parker	28298	2022-05-12	0
Death by Sadie	28299	2022-05-12	0
Philippe Risoli	28300	2022-05-12	0
Francesco Guccini	28301	2022-05-12	0
Caviar	28302	2022-05-12	0
Ron Trent	28303	2022-05-12	0
Cujorius One	28304	2022-05-12	0
Dynamite Boy	28305	2022-05-12	0
Seamus Egan	28306	2022-05-12	0
Sergio Dalma	28307	2022-05-12	0
Patrick Swayze Featuring Wendy Fraser	28308	2022-05-12	0
Echo & The Bunnymen	28309	2022-05-12	0
The Peepshows	28310	2022-05-12	0
The Dead Weather	28311	2022-05-12	0
Nuclear Ramjet	28312	2022-05-12	0
Hawksley Workman	28313	2022-05-12	0
The Honorary Title	28314	2022-05-12	0
American Primitive	28315	2022-05-12	0
Michelle Weeks	28316	2022-05-12	0
My Dying Bride	28317	2022-05-12	0
Serpentine	28318	2022-05-12	0
Maggie Holland	28319	2022-05-12	0
Belladonnakillz	28320	2022-05-12	0
Karaoke - Ameritz	28321	2022-05-12	0
Max Richter	28322	2022-05-12	0
Jacques Dutronc	28323	2022-05-12	0
Rajery	28324	2022-05-12	0
Kostas Paleologou	28325	2022-05-12	0
Hopewell	28326	2022-05-12	0
Sexton Blake	28327	2022-05-12	0
Lucerin Blue	28328	2022-05-12	0
Jimmie Widener	28329	2022-05-12	0
Miguel Bosé	28330	2022-05-12	0
Nash The Slash	28331	2022-05-12	0
Shawn Colvin	28332	2022-05-12	0
Mädness	28333	2022-05-12	0
Wednesday 13's Frankenstein Drag Queens From Planet 13	28334	2022-05-12	0
The Silos	28335	2022-05-12	0
The Hoax	28336	2022-05-12	0
Bad Habit	28337	2022-05-12	0
Breez Evahflowin and Dirt E. Dutch	28338	2022-05-12	0
Three Crosses	28339	2022-05-12	0
There For Tomorrow	28340	2022-05-12	0
Nicholas Gunn	28341	2022-05-12	0
Michèle Bernard	28342	2022-05-12	0
Disturbing Tha Peace	28343	2022-05-12	0
The Delta Rock Duo	28344	2022-05-12	0
Tranzident & Peter Dubs	28345	2022-05-12	0
The Swan Silvertones	28346	2022-05-12	0
The Copyrights	28347	2022-05-12	0
Alex Smoke	28348	2022-05-12	0
Giant Sand	28349	2022-05-12	0
Habeas Corpus	28350	2022-05-12	0
Deville_ Willy	28351	2022-05-12	0
Sarazino	28352	2022-05-12	0
Old Harp Singers of Eastern Tennessee	28353	2022-05-12	0
Tom Brosseau	28354	2022-05-12	0
Oxford Collapse	28355	2022-05-12	0
Wayne Wonder	28356	2022-05-12	0
1000names	28357	2022-05-12	0
Der Blaue Reiter	28358	2022-05-12	0
Ustad Nusrat Fateh Ali Khan	28359	2022-05-12	0
The Icicle Works	28360	2022-05-12	0
Jäger 90	28361	2022-05-12	0
Hindu Love Gods	28362	2022-05-12	0
Sciflyer	28363	2022-05-12	0
e.s.t. Esbjörn Svensson Trio	28364	2022-05-12	0
Bling Dawg & Mr. Notch	28365	2022-05-12	0
Polecat Boogie Revival	28366	2022-05-12	0
Husalah and B-Luv	28367	2022-05-12	0
Juice Leskinen Slam	28368	2022-05-12	0
Senser	28369	2022-05-12	0
The Limp Twins	28370	2022-05-12	0
Instant Wilkie	28371	2022-05-12	0
Locke	28372	2022-05-12	0
Dave Brubeck / Paul Desmond / Dave Van Kriedt	28373	2022-05-12	0
Gripin	28374	2022-05-12	0
Dungeon Family	28375	2022-05-12	0
Lucecita Benitez	28376	2022-05-12	0
Marv Johnson	28377	2022-05-12	0
Ray Ennis/The Blue Jeans	28378	2022-05-12	0
Spacekees	28379	2022-05-12	0
Lynyrd Skynyrd	28380	2022-05-12	0
Sendos Fuera	28381	2022-05-12	0
Redman ft. Kfam & Keith Murray	28382	2022-05-12	0
The Xcerts	28383	2022-05-12	0
Howard McGhee	28384	2022-05-12	0
Last Exit	28385	2022-05-12	0
Cachao	28386	2022-05-12	0
Beanflipper	28387	2022-05-12	0
The Incurables	28388	2022-05-12	0
Ulytau	28389	2022-05-12	0
Pinmonkey	28390	2022-05-12	0
Roommate	28391	2022-05-12	0
D-Code_ Ben Herman	28392	2022-05-12	0
Discipline	28393	2022-05-12	0
Reflector	28394	2022-05-12	0
Disco Inferno	28395	2022-05-12	0
Max Pezzali	28396	2022-05-12	0
Laurindo Almeida	28397	2022-05-12	0
Divididos	28398	2022-05-12	0
Super Furry Animals	28399	2022-05-12	0
Bing Crosby & Frank Sinatra	28400	2022-05-12	0
Bob Sinclar feat. Gary Pine & Dollarman	28401	2022-05-12	0
David Campbell;Steven Tyler	28402	2022-05-12	0
Bezerra Da Silva	28403	2022-05-12	0
Los Angeles Azules	28404	2022-05-12	0
Tommy Fresh	28405	2022-05-12	0
Alcatrazz	28406	2022-05-12	0
Joy Williams	28407	2022-05-12	0
Chapter XJ	28408	2022-05-12	0
Charlie Byrd	28409	2022-05-12	0
Deacon Street	28410	2022-05-12	0
The Clancy Brothers & Tommy Makem	28411	2022-05-12	0
Weekend Players	28412	2022-05-12	0
Mabel Mercer	28413	2022-05-12	0
Spk	28414	2022-05-12	0
EC	28415	2022-05-12	0
Missill	28416	2022-05-12	0
Ismaël Lo	28417	2022-05-12	0
Nonplace Urban Field	28418	2022-05-12	0
Robert Blake	28419	2022-05-12	0
Shur I Kan	28420	2022-05-12	0
The Move	28421	2022-05-12	0
House of Large Sizes	28422	2022-05-12	0
Charlie Cruz	28423	2022-05-12	0
Wayne Hancock	28424	2022-05-12	0
Common Rotation	28425	2022-05-12	0
Number One Cup	28426	2022-05-12	0
Adam Schmitt	28427	2022-05-12	0
Cherry's	28428	2022-05-12	0
José Cid	28429	2022-05-12	0
Roberto Vecchioni	28430	2022-05-12	0
Judge Dread	28431	2022-05-12	0
Ninos Con Bombas	28432	2022-05-12	0
Thomas Penton & Kotoswitch feat. Sam Stizer	28433	2022-05-12	0
Leonard Bernstein;New York Philharmonic	28434	2022-05-12	0
Juan D'Oultremont	28435	2022-05-12	0
UDG	28436	2022-05-12	0
London Symphony Orchestra	28437	2022-05-12	0
DJ Connections	28438	2022-05-12	0
Carl Michael Von Hausswolff	28439	2022-05-12	0
Streetwize	28440	2022-05-12	0
Gene Chandler	28441	2022-05-12	0
Lorenzo	28442	2022-05-12	0
Daphne Loves Derby	28443	2022-05-12	0
Angel City	28444	2022-05-12	0
Skunk Anansie	28445	2022-05-12	0
Klaus Weiss Trio	28446	2022-05-12	0
Talk Talk	28447	2022-05-12	0
Alkaline Trio	28448	2022-05-12	0
Konami Kukeiha Club	28449	2022-05-12	0
Ben's Brother	28450	2022-05-12	0
Spacehog	28451	2022-05-12	0
New York Philharmonic_ Leopold Stokowski	28452	2022-05-12	0
DJ Clue	28453	2022-05-12	0
John Delafose	28454	2022-05-12	0
Elmore James	28455	2022-05-12	0
Sanctuary	28456	2022-05-12	0
James Carr	28457	2022-05-12	0
Witchfynde	28458	2022-05-12	0
Paul Smith	28459	2022-05-12	0
Head of Femur	28460	2022-05-12	0
Everybody Was in the French Resistance...Now!	28461	2022-05-12	0
Delays	28462	2022-05-12	0
The Fitness	28463	2022-05-12	0
Robert Pollard	28464	2022-05-12	0
Cool Jerks	28465	2022-05-12	0
50 Cent ft. Young Buck	28466	2022-05-12	0
Your Song Is Good	28467	2022-05-12	0
Ray Price	28468	2022-05-12	0
Stephan Bodzin	28469	2022-05-12	0
The 4 of us	28470	2022-05-12	0
Massari	28471	2022-05-12	0
Les Claypool	28472	2022-05-12	0
Henry Kaiser	28473	2022-05-12	0
Flo Rida	28474	2022-05-12	0
Squad Five-0	28475	2022-05-12	0
Aislers Set	28476	2022-05-12	0
Âme Strong	28477	2022-05-12	0
Chain Gang Parolees	28478	2022-05-12	0
YUP	28479	2022-05-12	0
Halle/Hughes	28480	2022-05-12	0
Boat Beam	28481	2022-05-12	0
50 Foot Wave	28482	2022-05-12	0
Fobia	28483	2022-05-12	0
Bigbang	28484	2022-05-12	0
Public Enemy	28485	2022-05-12	0
WILL B	28486	2022-05-12	0
The Wombats	28487	2022-05-12	0
Linval Thompson	28488	2022-05-12	0
Penguin Café Orchestra	28489	2022-05-12	0
Unseen Terror	28490	2022-05-12	0
Writing On the Wall	28491	2022-05-12	0
THE JAKPOT	28492	2022-05-12	0
Ras Michael	28493	2022-05-12	0
Les Trompettes Du Boute-Selle	28494	2022-05-12	0
DJ Hell	28495	2022-05-12	0
Shaggy	28496	2022-05-12	0
Slam	28497	2022-05-12	0
Horst Jankowski	28498	2022-05-12	0
Oak	28499	2022-05-12	0
Useless I.D.	28500	2022-05-12	0
Fertile Ground	28501	2022-05-12	0
Harold Budd And Brian Eno	28502	2022-05-12	0
Lil' Son Jackson	28503	2022-05-12	0
B.B. Seaton	28504	2022-05-12	0
Valeria	28505	2022-05-12	0
The Higsons	28506	2022-05-12	0
The Old Romantic Killer Band	28507	2022-05-12	0
Michael Bublé	28508	2022-05-12	0
Fred Wesley & The J.B.'s	28509	2022-05-12	0
Saint Rush	28510	2022-05-12	0
Glorious Bankrobbers	28511	2022-05-12	0
Elkie Brooks with The Royal Philharmonic Orchestra	28512	2022-05-12	0
Doug Ploss	28513	2022-05-12	0
Mark Kozelek	28514	2022-05-12	0
Field Music	28515	2022-05-12	0
Mr. Capone-E	28516	2022-05-12	0
Tito Rodriguez	28517	2022-05-12	0
J. Karjalainen	28518	2022-05-12	0
Blaze	28519	2022-05-12	0
Vibracathedral Orchestra	28520	2022-05-12	0
FOP (Forms Of Plasticity)	28521	2022-05-12	0
Ana Gabriel	28522	2022-05-12	0
Claudette Soares	28523	2022-05-12	0
Thomas Fehlmann	28524	2022-05-12	0
Organic Grooves	28525	2022-05-12	0
Gary Morris	28526	2022-05-12	0
General Levy	28527	2022-05-12	0
Fortitude	28528	2022-05-12	0
Zev Feldman & Andy Statman	28529	2022-05-12	0
Phil Chang	28530	2022-05-12	0
WWE: Hawkins & Ryder (Disciple)	28531	2022-05-12	0
Alan Cavé	28532	2022-05-12	0
Hardline	28533	2022-05-12	0
Playboy Tre	28534	2022-05-12	0
Jelly Roll Morton and His Red Hot Peppers	28535	2022-05-12	0
Mylo	28536	2022-05-12	0
Benny Bailey / Max Greger Jr. / Max Greger & Orchester	28537	2022-05-12	0
The Purple Hearts	28538	2022-05-12	0
Queen + Paul Rodgers	28539	2022-05-12	0
Absolute	28540	2022-05-12	0
Declaime	28541	2022-05-12	0
Arnold Jarvis	28542	2022-05-12	0
Los Socios Del Ritmo	28543	2022-05-12	0
Chris Kowanko	28544	2022-05-12	0
Mark Hollis	28545	2022-05-12	0
Peter Schilling & Boom-Bastic	28546	2022-05-12	0
Wax	28547	2022-05-12	0
Duran Duran Duran	28548	2022-05-12	0
Olaf Schubert	28549	2022-05-12	0
The El Dorados	28550	2022-05-12	0
Nicholas Hooper	28551	2022-05-12	0
Mark Bacino	28552	2022-05-12	0
Pollyanna	28553	2022-05-12	0
Keith Whitley	28554	2022-05-12	0
Fresh Moods	28555	2022-05-12	0
Ricardo Montaner	28556	2022-05-12	0
Desiderii Marginis	28557	2022-05-12	0
Warner Bros. Studio Orchestra / Erich Wolfgang Korngold	28558	2022-05-12	0
Richard Dinsdale	28559	2022-05-12	0
Surgery	28560	2022-05-12	0
The Autumns	28561	2022-05-12	0
Stephani Krise	28562	2022-05-12	0
Phillips_ Craig & Dean	28563	2022-05-12	0
sin with sebastian	28564	2022-05-12	0
Diane Arkenstone	28565	2022-05-12	0
Scottish Chamber Orchestra/Alexander Janiczek	28566	2022-05-12	0
Sterling	28567	2022-05-12	0
Abstract Vision	28568	2022-05-12	0
Cadacross	28569	2022-05-12	0
Johnny Dowd	28570	2022-05-12	0
I Am Robot and Proud	28571	2022-05-12	0
BAL-SAGOTH	28572	2022-05-12	0
Steven Brown	28573	2022-05-12	0
Superchumbo	28574	2022-05-12	0
Ska-P	28575	2022-05-12	0
The Flatliners	28576	2022-05-12	0
The Cassandra Complex	28577	2022-05-12	0
Matt Bianco	28578	2022-05-12	0
Trust Obey	28579	2022-05-12	0
Tamar Giladi	28580	2022-05-12	0
Section 5	28581	2022-05-12	0
Oliver Twizt	28582	2022-05-12	0
It Bites	28583	2022-05-12	0
Mysterious Movement	28584	2022-05-12	0
Panzer Princess	28585	2022-05-12	0
Jim Jones	28586	2022-05-12	0
Devin Townsend Project	28587	2022-05-12	0
The Rings	28588	2022-05-12	0
Dogma Crew	28589	2022-05-12	0
Michael Mantler_ Don Preston	28590	2022-05-12	0
Mr. Anonymous	28591	2022-05-12	0
Kenny Burrell	28592	2022-05-12	0
Siw Malmkvist	28593	2022-05-12	0
Quidam	28594	2022-05-12	0
Julius Katchen	28595	2022-05-12	0
Pebbles	28596	2022-05-12	0
Big Kahuna and the Copa Cat Pack	28597	2022-05-12	0
Clouds Forming Crowns	28598	2022-05-12	0
Ron Hagen & Pascal M	28599	2022-05-12	0
The Audition	28600	2022-05-12	0
The Freaks Union	28601	2022-05-12	0
Nelly / Brian McKnight / Ali / City Spud	28602	2022-05-12	0
Jane Russell	28603	2022-05-12	0
David Zinman	28604	2022-05-12	0
Otis Spann	28605	2022-05-12	0
Don Cornell & Hugo Winterhalter Orchestra	28606	2022-05-12	0
Bülent Ceylan	28607	2022-05-12	0
Tony Sheridan	28608	2022-05-12	0
E.C. Scott	28609	2022-05-12	0
Bob Seger & The Silver Bullet Band	28610	2022-05-12	0
Tukan	28611	2022-05-12	0
Gay Dad	28612	2022-05-12	0
Liam Lynch	28613	2022-05-12	0
Joe Firstman	28614	2022-05-12	0
The Loud Family	28615	2022-05-12	0
B2K	28616	2022-05-12	0
Jonn Serrie	28617	2022-05-12	0
Bluvertigo	28618	2022-05-12	0
Birchville Cat Motel	28619	2022-05-12	0
Grit Boys	28620	2022-05-12	0
Camille Saint-Saëns	28621	2022-05-12	0
The Red Paintings	28622	2022-05-12	0
Zva 12-28 Band	28623	2022-05-12	0
D. Black	28624	2022-05-12	0
DJ Sandy	28625	2022-05-12	0
Mistah F.A.B.	28626	2022-05-12	0
Fountains Of Wayne	28627	2022-05-12	0
Greenslade	28628	2022-05-12	0
Pretty Purdie	28629	2022-05-12	0
Cryptic Slaughter	28630	2022-05-12	0
Roma 79	28631	2022-05-12	0
Against Me!	28632	2022-05-12	0
Five Finger Death Punch	28633	2022-05-12	0
Alexander Hacke	28634	2022-05-12	0
Ann Bell Fell	28635	2022-05-12	0
The Mother Truckers	28636	2022-05-12	0
Verse	28637	2022-05-12	0
Angela Johnson featuring Monet	28638	2022-05-12	0
Fermented Reptile	28639	2022-05-12	0
Ampere	28640	2022-05-12	0
The Blow Monkeys	28641	2022-05-12	0
Dax Riggs	28642	2022-05-12	0
Tanya Stephens	28643	2022-05-12	0
Falling Cycle	28644	2022-05-12	0
Hope Sandoval & The Warm Inventions	28645	2022-05-12	0
Stix Featuring Fee	28646	2022-05-12	0
Soulive / Reggie Watts	28647	2022-05-12	0
Gary Walker / The Carnabeats	28648	2022-05-12	0
Derribos Arias	28649	2022-05-12	0
The Gaslight Anthem	28650	2022-05-12	0
SIMM	28651	2022-05-12	0
Mr.Phillips	28652	2022-05-12	0
Edelweiss	28653	2022-05-12	0
Avancada	28654	2022-05-12	0
Larry Tee	28655	2022-05-12	0
Quentin Harris	28656	2022-05-12	0
Nic Chagall	28657	2022-05-12	0
Her Majesty's Finest	28658	2022-05-12	0
Bic Runga	28659	2022-05-12	0
Paul Oakenfold	28660	2022-05-12	0
Styles P	28661	2022-05-12	0
Daniel Wang	28662	2022-05-12	0
The Robins aka The Coasters	28663	2022-05-12	0
Kraan	28664	2022-05-12	0
Ronnie Milsap	28665	2022-05-12	0
The Cardigans	28666	2022-05-12	0
Dimension Latina	28667	2022-05-12	0
The Amalgamation Of Soundz	28668	2022-05-12	0
Thee Headcoatees	28669	2022-05-12	0
A Tribe Called Quest	28670	2022-05-12	0
Emmanuel Horvilleur	28671	2022-05-12	0
Johnny Ace	28672	2022-05-12	0
The Focus Group	28673	2022-05-12	0
Pennywise	28674	2022-05-12	0
Big Famili	28675	2022-05-12	0
Rumble Pack	28676	2022-05-12	0
Honeydogs	28677	2022-05-12	0
Riley Reinhold	28678	2022-05-12	0
Barfly	28679	2022-05-12	0
Textures	28680	2022-05-12	0
Doug Folkins with Ken Hamm	28681	2022-05-12	0
Lazard feat. Muzzy G.	28682	2022-05-12	0
Crystals	28683	2022-05-12	0
Karmah	28684	2022-05-12	0
Daylight Dies	28685	2022-05-12	0
Timmy Vegas & Bad Lay-Dee	28686	2022-05-12	0
Commander Tom vs. Oliver Cats	28687	2022-05-12	0
Joan Sebastian	28688	2022-05-12	0
Landscape Body Machine	28689	2022-05-12	0
Lamb Of God	28690	2022-05-12	0
Jerry Cantrell	28691	2022-05-12	0
Lenny/Carl/Homer/Disco Stu/Selma/Steve Buscemi/Turk #1/Turk #2	28692	2022-05-12	0
Steve Miller Band	28693	2022-05-12	0
Andru Donalds	28694	2022-05-12	0
Captain Hollywood Project	28695	2022-05-12	0
The Jacka_ Rydah J. Klyde_ & Fed-X (ft. RobLo)	28696	2022-05-12	0
The New Deal	28697	2022-05-12	0
The Wideboys ft. Clare Evers	28698	2022-05-12	0
OQTO	28699	2022-05-12	0
Jimmy Jones	28700	2022-05-12	0
Redman	28701	2022-05-12	0
Russell Morris	28702	2022-05-12	0
Duncan James / Mylene Klass	28703	2022-05-12	0
Motorcitysoul	28704	2022-05-12	0
Quenga	28705	2022-05-12	0
The 69 Eyes	28706	2022-05-12	0
Roscoe	28707	2022-05-12	0
Buck-O-Nine	28708	2022-05-12	0
Yuko Kanzaki	28709	2022-05-12	0
Royal Liverpool Philharmonic Orchestra/Malcolm Stewart/Vernon Handley	28710	2022-05-12	0
HTRK	28711	2022-05-12	0
Seven Nations	28712	2022-05-12	0
Fully Loaded	28713	2022-05-12	0
Time Again	28714	2022-05-12	0
So!	28715	2022-05-12	0
Mika Urbaniak	28716	2022-05-12	0
Ed McCurdy	28717	2022-05-12	0
Lisa Mitchell	28718	2022-05-12	0
Highpersonic Whomen	28719	2022-05-12	0
Steve Lawrence	28720	2022-05-12	0
Digit All Love	28721	2022-05-12	0
Il pan del diavolo	28722	2022-05-12	0
Two Ton Boa	28723	2022-05-12	0
La Rue Kétanou	28724	2022-05-12	0
Special D	28725	2022-05-12	0
Katatonia	28726	2022-05-12	0
Ready For The World	28727	2022-05-12	0
Holger Biege	28728	2022-05-12	0
Ram Squad	28729	2022-05-12	0
Stereo De Luxe	28730	2022-05-12	0
Joy Enriquez	28731	2022-05-12	0
Little Brother Montgomery	28732	2022-05-12	0
Ram Zet	28733	2022-05-12	0
The Lounge Lizards	28734	2022-05-12	0
Lupen Crook and The Murderbirds	28735	2022-05-12	0
Faramarz Aslani	28736	2022-05-12	0
Steur	28737	2022-05-12	0
Carlene Carter	28738	2022-05-12	0
Hydro	28739	2022-05-12	0
Adam Arcuragi	28740	2022-05-12	0
Katie Melua	28741	2022-05-12	0
Liluca	28742	2022-05-12	0
Anoushka Shankar and Karsh Kale	28743	2022-05-12	0
The Lone Ranger	28744	2022-05-12	0
Joshua Bell;John Williams	28745	2022-05-12	0
Malacka és a Tahó	28746	2022-05-12	0
Terry Brock	28747	2022-05-12	0
Iambia	28748	2022-05-12	0
Shanghai Lily Dublin	28749	2022-05-12	0
Brandon Heath	28750	2022-05-12	0
Seeds	28751	2022-05-12	0
Frankie Laine	28752	2022-05-12	0
Traste Lindéns Kvintett	28753	2022-05-12	0
Jack Jones	28754	2022-05-12	0
The Men They Couldn't Hang	28755	2022-05-12	0
Winfried Jürgen	28756	2022-05-12	0
Greg Cerrone	28757	2022-05-12	0
Big Moe	28758	2022-05-12	0
Sportsguitar	28759	2022-05-12	0
Le Peuple de L'Herbe	28760	2022-05-12	0
Charles Earland / Boogaloo Joe Jones	28761	2022-05-12	0
Tom Burris	28762	2022-05-12	0
Nik Kershaw	28763	2022-05-12	0
Ann Wilson / Nancy Wilson	28764	2022-05-12	0
Mildred Bailey	28765	2022-05-12	0
New Monsoon	28766	2022-05-12	0
Acker Bilk	28767	2022-05-12	0
Les Georges Leningrad	28768	2022-05-12	0
Vardis	28769	2022-05-12	0
From The Carnival Of Horrors	28770	2022-05-12	0
Maps	28771	2022-05-12	0
Theodor Bastard	28772	2022-05-12	0
amelie-les-crayons	28773	2022-05-12	0
Steven Seagal	28774	2022-05-12	0
Rick Astley	28775	2022-05-12	0
Dan Reed Network	28776	2022-05-12	0
Russell G & Maxi Valvona	28777	2022-05-12	0
Geneva	28778	2022-05-12	0
Hladno Pivo	28779	2022-05-12	0
Magnolia Electric Co.	28780	2022-05-12	0
Another Sunny Day	28781	2022-05-12	0
Sinine	28782	2022-05-12	0
Eileen Farrell;Martha Lipton;William Warfield;The Mormon Tabernacle Choir;Eugene Ormandy	28783	2022-05-12	0
On A Pale Horse	28784	2022-05-12	0
Sesto Sento	28785	2022-05-12	0
Bertrand Betsch	28786	2022-05-12	0
David Fonseca	28787	2022-05-12	0
Tim Barry	28788	2022-05-12	0
Rival Schools	28789	2022-05-12	0
marr	28790	2022-05-12	0
Purple Schulz Und Die Neue Heimat	28791	2022-05-12	0
White Kaps	28792	2022-05-12	0
Rui Reininho	28793	2022-05-12	0
David McCallum	28794	2022-05-12	0
Third Degree	28795	2022-05-12	0
OutKast Featuring Sleepy Brown	28796	2022-05-12	0
Sever Your Ties	28797	2022-05-12	0
The Duskfall	28798	2022-05-12	0
Wayne Watson	28799	2022-05-12	0
Lisa Ekdahl	28800	2022-05-12	0
Clyde McPhatter	28801	2022-05-12	0
N.E.T.	28802	2022-05-12	0
Partenaire Particulier	28803	2022-05-12	0
Scandinavian Music Group	28804	2022-05-12	0
Vibronics	28805	2022-05-12	0
Spaccanapoli	28806	2022-05-12	0
Pata Negra	28807	2022-05-12	0
Philippe Bestion	28808	2022-05-12	0
David Cassidy	28809	2022-05-12	0
Eric Marienthal	28810	2022-05-12	0
Ambient Music Therapy	28811	2022-05-12	0
Marvin Gaye	28812	2022-05-12	0
Jamie Lidell	28813	2022-05-12	0
Chi-Lites	28814	2022-05-12	0
The Carter Family	28815	2022-05-12	0
La Bien Querida	28816	2022-05-12	0
Efterklang	28817	2022-05-12	0
Indigo Children	28818	2022-05-12	0
Speedmarket Avenue	28819	2022-05-12	0
Openair	28820	2022-05-12	0
Stone Temple Pilots	28821	2022-05-12	0
Dj Lewis	28822	2022-05-12	0
Calvin Krime	28823	2022-05-12	0
Eralio Gill	28824	2022-05-12	0
Motormark	28825	2022-05-12	0
The Detergents	28826	2022-05-12	0
What We Feel	28827	2022-05-12	0
Gran Coquivacoa	28828	2022-05-12	0
Susan Schubert	28829	2022-05-12	0
Plastik Funk feat. Lyck	28830	2022-05-12	0
The Mahotella Queens	28831	2022-05-12	0
Amulet	28832	2022-05-12	0
Playin' 4 The City	28833	2022-05-12	0
Fatboy Slim vs. Funkagenda	28834	2022-05-12	0
Big Tymers / Tateeze / Boo And Gotti	28835	2022-05-12	0
Giorgos Veros	28836	2022-05-12	0
The Krayolas	28837	2022-05-12	0
Arcangel	28838	2022-05-12	0
Play	28839	2022-05-12	0
SIGNAL AOUT 42	28840	2022-05-12	0
Toby Keith	28841	2022-05-12	0
The Syn	28842	2022-05-12	0
Lovestern Galaktika Project	28843	2022-05-12	0
The Mystery Trend	28844	2022-05-12	0
Tomcraft feat. Tommie Sunshine	28845	2022-05-12	0
Lustans Lakejer	28846	2022-05-12	0
Israel Philharmonic Orchestra;Zubin Mehta;Midori	28847	2022-05-12	0
Palmas N Raven	28848	2022-05-12	0
Les Hurlements D'leo	28849	2022-05-12	0
DJ Wady_ Junatik	28850	2022-05-12	0
Jilted John	28851	2022-05-12	0
Rosie Flores	28852	2022-05-12	0
E-Type / Nana Hedin	28853	2022-05-12	0
Dyango	28854	2022-05-12	0
Extrawelt	28855	2022-05-12	0
Louis Prima with Orchestra	28856	2022-05-12	0
The-Dream	28857	2022-05-12	0
Raphi	28858	2022-05-12	0
Sportfreunde	28859	2022-05-12	0
Das Ich	28860	2022-05-12	0
Ryan Adams	28861	2022-05-12	0
The Five Satins	28862	2022-05-12	0
Jocelyn Brown	28863	2022-05-12	0
Pix	28864	2022-05-12	0
Higamos Hogamos	28865	2022-05-12	0
Earl Van Dyke	28866	2022-05-12	0
Princess Pang	28867	2022-05-12	0
Ana Popovic	28868	2022-05-12	0
Sonny Rollins Quartet	28869	2022-05-12	0
Boyz N Da Hood	28870	2022-05-12	0
MC Ren	28871	2022-05-12	0
Hot Wire	28872	2022-05-12	0
Local Natives	28873	2022-05-12	0
Down To Earth	28874	2022-05-12	0
Big Yoga Muffin	28875	2022-05-12	0
Gladys Knight & The Pips	28876	2022-05-12	0
Chico César	28877	2022-05-12	0
Kraftwelt	28878	2022-05-12	0
The Pebbles	28879	2022-05-12	0
Infinito 2017	28880	2022-05-12	0
Klovner I Kamp	28881	2022-05-12	0
Charly Greane	28882	2022-05-12	0
Peter Frampton	28883	2022-05-12	0
The Neon Judgement	28884	2022-05-12	0
Jeannot Sossou	28885	2022-05-12	0
Joe Nichols	28886	2022-05-12	0
Elio E Le Storie Tese	28887	2022-05-12	0
Benjamin Biolay	28888	2022-05-12	0
Nice & Wild	28889	2022-05-12	0
Swamp Dogg	28890	2022-05-12	0
Solveig Slettahjell	28891	2022-05-12	0
The Hundred In The Hands	28892	2022-05-12	0
Till Von Sein	28893	2022-05-12	0
Deep Forest;Angela McClusky	28894	2022-05-12	0
Rachael Lampa	28895	2022-05-12	0
Watkin Tudor Jones	28896	2022-05-12	0
Quit Your Dayjob	28897	2022-05-12	0
Timbalada	28898	2022-05-12	0
Modulate	28899	2022-05-12	0
Jud Newcomb	28900	2022-05-12	0
Marcus Worgull	28901	2022-05-12	0
Ikonika	28902	2022-05-12	0
Patrik Berglund	28903	2022-05-12	0
Zuzana Smatanova	28904	2022-05-12	0
Spark Is A Diamond	28905	2022-05-12	0
Peggy Sue	28906	2022-05-12	0
Format:B	28907	2022-05-12	0
Paffendorf vs. The Real Booty Babes	28908	2022-05-12	0
Climie Fisher	28909	2022-05-12	0
Grave Digger	28910	2022-05-12	0
Constar	28911	2022-05-12	0
SONATA ARCTICA	28912	2022-05-12	0
Jonathan Martin	28913	2022-05-12	0
Scissor Sisters	28914	2022-05-12	0
Brooklyn Bounce	28915	2022-05-12	0
Alice In Videoland	28916	2022-05-12	0
Adelaide Ferreira	28917	2022-05-12	0
Doyle Bramhall	28918	2022-05-12	0
Sir Larsie I	28919	2022-05-12	0
The Greencards	28920	2022-05-12	0
Chiddy Bang	28921	2022-05-12	0
Frank Reyes	28922	2022-05-12	0
Pliers	28923	2022-05-12	0
Blues Lee	28924	2022-05-12	0
Inoki	28925	2022-05-12	0
Capital Inicial	28926	2022-05-12	0
Johnny Crawford	28927	2022-05-12	0
Enemy You	28928	2022-05-12	0
Daniel Darc	28929	2022-05-12	0
John Dahlback	28930	2022-05-12	0
Sun Yan-Zi	28931	2022-05-12	0
Drastic	28932	2022-05-12	0
David Jordan	28933	2022-05-12	0
Ritchie Family	28934	2022-05-12	0
Danny Kaye	28935	2022-05-12	0
Archie Bleyer	28936	2022-05-12	0
Audion	28937	2022-05-12	0
Deborah Harry	28938	2022-05-12	0
Lords Of The Underground	28939	2022-05-12	0
Papa Wemba	28940	2022-05-12	0
James LaBrie	28941	2022-05-12	0
Hall Of Fame	28942	2022-05-12	0
P'taah	28943	2022-05-12	0
Steve Vai	28944	2022-05-12	0
Roberto Carlos	28945	2022-05-12	0
Imagine	28946	2022-05-12	0
Telepathic Butterflies	28947	2022-05-12	0
Los Chichos	28948	2022-05-12	0
The Specials & Friends	28949	2022-05-12	0
Televise	28950	2022-05-12	0
Alexander 'Skip' Spence	28951	2022-05-12	0
Dodgy	28952	2022-05-12	0
Michael Landau	28953	2022-05-12	0
Mesajah	28954	2022-05-12	0
Foreign Force	28955	2022-05-12	0
Al Bano And Romina Power	28956	2022-05-12	0
John Stevens	28957	2022-05-12	0
Solarscape	28958	2022-05-12	0
Belt	28959	2022-05-12	0
The Woggles	28960	2022-05-12	0
Obk	28961	2022-05-12	0
Arsenium	28962	2022-05-12	0
Mellow Mark	28963	2022-05-12	0
Tullycraft	28964	2022-05-12	0
Camouflage	28965	2022-05-12	0
Sonny fodera	28966	2022-05-12	0
Pouyah	28967	2022-05-12	0
South Central Cartel	28968	2022-05-12	0
The Sick and Indigent Song Club	28969	2022-05-12	0
Diablo	28970	2022-05-12	0
The Killers	28971	2022-05-12	0
London Mozart Players_ Harry Blech	28972	2022-05-12	0
Vishwa Mohan Bhatt	28973	2022-05-12	0
Illapu	28974	2022-05-12	0
El Thule	28975	2022-05-12	0
Merchant	28976	2022-05-12	0
Myrick "Freeze" Guillory	28977	2022-05-12	0
Young Buck & D-Tay	28978	2022-05-12	0
Blowsight	28979	2022-05-12	0
Leki	28980	2022-05-12	0
Powerwolf	28981	2022-05-12	0
Pikku G	28982	2022-05-12	0
XYZ	28983	2022-05-12	0
Dylan Mondegreen	28984	2022-05-12	0
The Real Tuesday Weld	28985	2022-05-12	0
The Hospitals	28986	2022-05-12	0
Texta	28987	2022-05-12	0
Hef	28988	2022-05-12	0
B-Legit featuring Too $hort	28989	2022-05-12	0
Adorned Brood	28990	2022-05-12	0
Infinitum	28991	2022-05-12	0
Poe	28992	2022-05-12	0
Fireside	28993	2022-05-12	0
Kool & The Gang	28994	2022-05-12	0
Dan Zanes	28995	2022-05-12	0
Cassidy	28996	2022-05-12	0
Miss TK & The Revenge	28997	2022-05-12	0
Aloha From Hell	28998	2022-05-12	0
Zs	28999	2022-05-12	0
Erik Darling	29000	2022-05-12	0
Chris Standring	29001	2022-05-12	0
Luke Terry	29002	2022-05-12	0
Little Roy	29003	2022-05-12	0
Little Pieces	29004	2022-05-12	0
Kiko & Shara	29005	2022-05-12	0
The Cajun Playboys	29006	2022-05-12	0
Mouthful of Bees	29007	2022-05-12	0
Duran Duran	29008	2022-05-12	0
T-Nutty	29009	2022-05-12	0
Nadine Renee	29010	2022-05-12	0
The Gynecologists	29011	2022-05-12	0
Lonnie Mack	29012	2022-05-12	0
J. Peter Robinson	29013	2022-05-12	0
City And Colour	29014	2022-05-12	0
Mei Chi Chiang	29015	2022-05-12	0
Heston	29016	2022-05-12	0
Army of the Pharoahs	29017	2022-05-12	0
Dimitri From Paris	29018	2022-05-12	0
Alamo Race Track	29019	2022-05-12	0
Tribal Tech	29020	2022-05-12	0
Kråkesølv	29021	2022-05-12	0
Port O'Brien	29022	2022-05-12	0
Sólo Los Solo	29023	2022-05-12	0
Gary Maguire	29024	2022-05-12	0
Gunhild Seim & Time Jungle	29025	2022-05-12	0
Hank Jones_ Ilya Lushtak	29026	2022-05-12	0
Brian Bromberg	29027	2022-05-12	0
Edward Bear	29028	2022-05-12	0
Thomas Jefferson Slave Apartments	29029	2022-05-12	0
Patto	29030	2022-05-12	0
Half Foot Outside	29031	2022-05-12	0
D-Shot (ft. Kevin Gartner)	29032	2022-05-12	0
New Model Army	29033	2022-05-12	0
Karmakanic	29034	2022-05-12	0
Mclusky	29035	2022-05-12	0
Farley 'Jackmaster' Funk	29036	2022-05-12	0
Marty Balin	29037	2022-05-12	0
Carina	29038	2022-05-12	0
Bee	29039	2022-05-12	0
Michael Moog	29040	2022-05-12	0
Osamu Kitajima	29041	2022-05-12	0
Archie Shepp Quartet	29042	2022-05-12	0
Bob Carlisle;Vestal Goodman	29043	2022-05-12	0
Harlan T. Bobo	29044	2022-05-12	0
X-Perience	29045	2022-05-12	0
Bela Fleck And The Flecktones	29046	2022-05-12	0
Panjabi MC	29047	2022-05-12	0
Further Seems Forever	29048	2022-05-12	0
Centro-matic	29049	2022-05-12	0
Damien Rice	29050	2022-05-12	0
Yndi Halda	29051	2022-05-12	0
Wordsworth	29052	2022-05-12	0
Craig's Brother	29053	2022-05-12	0
Tippa Irie / Peter Hunnigale	29054	2022-05-12	0
Gavin Herlihy	29055	2022-05-12	0
Sportsday Megaphone	29056	2022-05-12	0
Cleveland Orchestra_ George Szell	29057	2022-05-12	0
Ruins	29058	2022-05-12	0
Wild Billy Childish And The Blackhands	29059	2022-05-12	0
Lisac Josipa	29060	2022-05-12	0
Watermelon Slim	29061	2022-05-12	0
Leverage	29062	2022-05-12	0
Don Ho	29063	2022-05-12	0
El Chojin	29064	2022-05-12	0
Playdough	29065	2022-05-12	0
Rosetta	29066	2022-05-12	0
Fausto	29067	2022-05-12	0
Johnny Osbourne	29068	2022-05-12	0
Ivan Della Mea	29069	2022-05-12	0
Dan Siegel	29070	2022-05-12	0
Detroit Grand Pubahs featuring Dynamix II	29071	2022-05-12	0
Clifford Brown	29072	2022-05-12	0
Jesse Winchester	29073	2022-05-12	0
Lullaby For The Working Class	29074	2022-05-12	0
Bon Scott With Fraternity	29075	2022-05-12	0
Legendary Shack*Shakers	29076	2022-05-12	0
Volcano Choir	29077	2022-05-12	0
Pauline Croze	29078	2022-05-12	0
Dj Kamel	29079	2022-05-12	0
Gurdas Mann	29080	2022-05-12	0
Gato Perez	29081	2022-05-12	0
Justin Sane	29082	2022-05-12	0
Ed Bruce	29083	2022-05-12	0
Marciano	29084	2022-05-12	0
Ron Basejam	29085	2022-05-12	0
Maze	29086	2022-05-12	0
Benjy Davis Project	29087	2022-05-12	0
A Traitor Like Judas	29088	2022-05-12	0
Angela Johnson featuring Tricia Angus	29089	2022-05-12	0
Amanda Jenssen	29090	2022-05-12	0
Helen Reddy	29091	2022-05-12	0
Liliana Herrero	29092	2022-05-12	0
D'Nash	29093	2022-05-12	0
The American Analog Set	29094	2022-05-12	0
Albert Hammond Jr	29095	2022-05-12	0
Tomas Andersson Wij	29096	2022-05-12	0
Hi-Tek	29097	2022-05-12	0
Her Whisper	29098	2022-05-12	0
The Lesters	29099	2022-05-12	0
The Dirty Dozen Brass Band	29100	2022-05-12	0
Lenny Mac Dowell	29101	2022-05-12	0
Charlie Palmieri	29102	2022-05-12	0
Alif Tree	29103	2022-05-12	0
Juliette Lewis	29104	2022-05-12	0
Noe Venable Trio	29105	2022-05-12	0
Blue Rodeo	29106	2022-05-12	0
Nick Chacona	29107	2022-05-12	0
Sam and Dave	29108	2022-05-12	0
Speedball	29109	2022-05-12	0
Sound Of Stereo	29110	2022-05-12	0
Kermit Ruffins	29111	2022-05-12	0
Mantic Ritual	29112	2022-05-12	0
Jolly Music	29113	2022-05-12	0
Frank Martiniq	29114	2022-05-12	0
The Innocence Mission	29115	2022-05-12	0
Mike Stern	29116	2022-05-12	0
Zombina & The Skeletones	29117	2022-05-12	0
Lost Witness	29118	2022-05-12	0
Olav Brekke & Sideshow Jøgge	29119	2022-05-12	0
Carmen Lundy	29120	2022-05-12	0
Panurge	29121	2022-05-12	0
Alexandre Da Costa	29122	2022-05-12	0
Gruppo Sportivo	29123	2022-05-12	0
Animal Collective	29124	2022-05-12	0
Blockhead	29125	2022-05-12	0
M.I.	29126	2022-05-12	0
Billy Vera	29127	2022-05-12	0
George Cochrane	29128	2022-05-12	0
Bobby Capo	29129	2022-05-12	0
Autoramas	29130	2022-05-12	0
Headhunters	29131	2022-05-12	0
Gorilla Zoe featuring Block & Big Gee	29132	2022-05-12	0
Elgar Howarth/Nash Ensemble	29133	2022-05-12	0
Dena DeRose	29134	2022-05-12	0
V/A - Liberation Records	29135	2022-05-12	0
Los Gatos Negros	29136	2022-05-12	0
Summer Hymns	29137	2022-05-12	0
Siouxsie And The Banshees	29138	2022-05-12	0
McGuinness Flint	29139	2022-05-12	0
Coldworker	29140	2022-05-12	0
DeGarmo & Key	29141	2022-05-12	0
Obie Bermudez	29142	2022-05-12	0
Counterfit	29143	2022-05-12	0
Tagada Jones	29144	2022-05-12	0
Skyedance	29145	2022-05-12	0
Ferraby Lionheart	29146	2022-05-12	0
Miguel Aceves Mejia	29147	2022-05-12	0
Five Fingers of Funk	29148	2022-05-12	0
Reel People Feat. Angela Johnson	29149	2022-05-12	0
PSD Tha Drivah	29150	2022-05-12	0
Doctor Explosion	29151	2022-05-12	0
Saybia	29152	2022-05-12	0
Corenell feat. Ann Bailey	29153	2022-05-12	0
Five Way Friday	29154	2022-05-12	0
Federation featuring Undaflow	29155	2022-05-12	0
Skullflower	29156	2022-05-12	0
Slymongoose	29157	2022-05-12	0
Luke Haines	29158	2022-05-12	0
Angela Dimitriou	29159	2022-05-12	0
Jimmy Eat World	29160	2022-05-12	0
Okkervil River	29161	2022-05-12	0
Johnny Burnette And The Rock n Roll Trio	29162	2022-05-12	0
The Equals	29163	2022-05-12	0
Lords Of Altamont	29164	2022-05-12	0
Kingsmen	29165	2022-05-12	0
Setrise feat. Bas Van Platen	29166	2022-05-12	0
Bobo Moreno	29167	2022-05-12	0
Pinch	29168	2022-05-12	0
Natalie	29169	2022-05-12	0
Z. Z. Hill	29170	2022-05-12	0
I Got You On Tape	29171	2022-05-12	0
Superego	29172	2022-05-12	0
Roberto Silva	29173	2022-05-12	0
ElSandro	29174	2022-05-12	0
Melanie Thornton	29175	2022-05-12	0
Skyforger	29176	2022-05-12	0
Jon Kennedy	29177	2022-05-12	0
Moleculez	29178	2022-05-12	0
Bulletproof	29179	2022-05-12	0
Dave Hollister	29180	2022-05-12	0
datA	29181	2022-05-12	0
Karen Dalton	29182	2022-05-12	0
Sheena Ringo	29183	2022-05-12	0
Chris Carrier	29184	2022-05-12	0
Klaus Doldinger	29185	2022-05-12	0
Björn Skifs	29186	2022-05-12	0
Dima Bilan	29187	2022-05-12	0
Sebastien Tellier	29188	2022-05-12	0
Vesta	29189	2022-05-12	0
Tyler Messick	29190	2022-05-12	0
Wyclef Jean	29191	2022-05-12	0
Steve Helms	29192	2022-05-12	0
Machete y Cana	29193	2022-05-12	0
Charlottefield	29194	2022-05-12	0
Jannes	29195	2022-05-12	0
We Are Balboa	29196	2022-05-12	0
Dulce	29197	2022-05-12	0
Apricot Rail	29198	2022-05-12	0
Paul Glazby	29199	2022-05-12	0
Gil Semedo	29200	2022-05-12	0
Mafia K'1 Fry	29201	2022-05-12	0
Ole Erling	29202	2022-05-12	0
As Hope Dies	29203	2022-05-12	0
Question Mark & The Mysterians	29204	2022-05-12	0
Soesja Citroen	29205	2022-05-12	0
Cunninlynguists	29206	2022-05-12	0
Jeff Golub	29207	2022-05-12	0
Germs	29208	2022-05-12	0
Voivod	29209	2022-05-12	0
Edda Mûvek	29210	2022-05-12	0
Cab Drivers	29211	2022-05-12	0
25 Ta Life	29212	2022-05-12	0
Eric Dolphy	29213	2022-05-12	0
Wendo Kolosoy	29214	2022-05-12	0
Lori Meyers	29215	2022-05-12	0
Alex North_ Jerry Goldsmith_ The National Philharmonic Orchestra	29216	2022-05-12	0
Paperboys	29217	2022-05-12	0
Daturah	29218	2022-05-12	0
Bloody Social	29219	2022-05-12	0
Leadbelly	29220	2022-05-12	0
Roy Hargrove	29221	2022-05-12	0
Ruck Rover	29222	2022-05-12	0
Stephanie Smith	29223	2022-05-12	0
Venetian Snares	29224	2022-05-12	0
Todor Kolev	29225	2022-05-12	0
OIO AI	29226	2022-05-12	0
Israel Philharmonic Orchestra;Zubin Mehta	29227	2022-05-12	0
the bird and the bee	29228	2022-05-12	0
Fighting Jacks	29229	2022-05-12	0
Venke Knutson	29230	2022-05-12	0
Kora! Kora! Kora!	29231	2022-05-12	0
Dubble D	29232	2022-05-12	0
Remedios Amaya	29233	2022-05-12	0
Single File	29234	2022-05-12	0
The Cortinas	29235	2022-05-12	0
El Chico Con La Espina En El Costado	29236	2022-05-12	0
Asha Bhosle_ Manna Dey_ Lata Mangeshkar_ Mohd. Rafi	29237	2022-05-12	0
Kotaro Oshio	29238	2022-05-12	0
Véronique Sanson	29239	2022-05-12	0
Pat Metheny	29240	2022-05-12	0
Carl Craig / Moritz Oswald	29241	2022-05-12	0
The Delfonics	29242	2022-05-12	0
Peter Schilling	29243	2022-05-12	0
Nelson Rangell	29244	2022-05-12	0
Bill Justis	29245	2022-05-12	0
Django Asül	29246	2022-05-12	0
Laaz Rockit	29247	2022-05-12	0
RAUNCHY	29248	2022-05-12	0
Jamie Finlay	29249	2022-05-12	0
Rasco and The Cali Agents	29250	2022-05-12	0
Memory Cassette	29251	2022-05-12	0
Mala Rodriguez	29252	2022-05-12	0
Bunji Garlin Feat. Allure	29253	2022-05-12	0
Spinvis	29254	2022-05-12	0
Pete G	29255	2022-05-12	0
Francisco Nixon	29256	2022-05-12	0
Skinless	29257	2022-05-12	0
Dee Dee Sharp	29258	2022-05-12	0
Desireless_ Mic-éco	29259	2022-05-12	0
Hussein Fatal	29260	2022-05-12	0
S.O.D.	29261	2022-05-12	0
MC Breed	29262	2022-05-12	0
The Bristols	29263	2022-05-12	0
Lil' Band O' Gold	29264	2022-05-12	0
Solarstone	29265	2022-05-12	0
Chynaman	29266	2022-05-12	0
Oscar Brand	29267	2022-05-12	0
David Summers	29268	2022-05-12	0
Robert Nickson feat. Elsa Hill	29269	2022-05-12	0
Elsa Garcia	29270	2022-05-12	0
Transistor Rodeo	29271	2022-05-12	0
Thanksgiving	29272	2022-05-12	0
Novel 23	29273	2022-05-12	0
Marvin Pontiac	29274	2022-05-12	0
Subz & Matik	29275	2022-05-12	0
Zoo Brasil	29276	2022-05-12	0
Kyte	29277	2022-05-12	0
Clã E Sérgio Godinho	29278	2022-05-12	0
White Heart	29279	2022-05-12	0
Within Y	29280	2022-05-12	0
Aria	29281	2022-05-12	0
Helen Boulding	29282	2022-05-12	0
Foy	29283	2022-05-12	0
Daniel Portman	29284	2022-05-12	0
Macka Diamond	29285	2022-05-12	0
Music from the World of Osho	29286	2022-05-12	0
Circle Research	29287	2022-05-12	0
Bishop Perry Tillis	29288	2022-05-12	0
Taboo	29289	2022-05-12	0
Los Ángeles	29290	2022-05-12	0
Hundred Reasons	29291	2022-05-12	0
Andy Conrad?	29292	2022-05-12	0
Jus Allah	29293	2022-05-12	0
Martin Jondo	29294	2022-05-12	0
Trainwreck Riders	29295	2022-05-12	0
Stimulator	29296	2022-05-12	0
Mono.	29297	2022-05-12	0
Bracken	29298	2022-05-12	0
Earl Gaines	29299	2022-05-12	0
Dr Rubberfunk feat. Sitzka	29300	2022-05-12	0
The Scare	29301	2022-05-12	0
Juliet Annerino	29302	2022-05-12	0
Chris Cagle	29303	2022-05-12	0
Monk Hughes & The Outer Realm	29304	2022-05-12	0
Cheikh Lo	29305	2022-05-12	0
The Depreciation Guild	29306	2022-05-12	0
Almighty Defenders	29307	2022-05-12	0
Cheb Nasro	29308	2022-05-12	0
John Carpenter_ Alan Howarth	29309	2022-05-12	0
King Britt	29310	2022-05-12	0
Britt Nicole	29311	2022-05-12	0
Drexel	29312	2022-05-12	0
Hendrik Meurkens	29313	2022-05-12	0
Cuban Link	29314	2022-05-12	0
Les Innocents	29315	2022-05-12	0
Testament	29316	2022-05-12	0
Ben Selvin	29317	2022-05-12	0
Head Automatica	29318	2022-05-12	0
Misty In Roots	29319	2022-05-12	0
Christos Kedras	29320	2022-05-12	0
Lyrics Born	29321	2022-05-12	0
The Kooks	29322	2022-05-12	0
Desaster	29323	2022-05-12	0
Hot Chelle Rae	29324	2022-05-12	0
Fleshies	29325	2022-05-12	0
Neal Schon	29326	2022-05-12	0
Alex Masi	29327	2022-05-12	0
A Fuego	29328	2022-05-12	0
Stereolab	29329	2022-05-12	0
Chuck Jackson	29330	2022-05-12	0
Steve Coleman & Five Elements	29331	2022-05-12	0
Anbessa	29332	2022-05-12	0
The King Sisters	29333	2022-05-12	0
Michael Hedges	29334	2022-05-12	0
Scorpio	29335	2022-05-12	0
The Incredible String Band	29336	2022-05-12	0
Ari Borovoy	29337	2022-05-12	0
Kamera	29338	2022-05-12	0
Albin Myers	29339	2022-05-12	0
Pull In Emergency	29340	2022-05-12	0
In Benny We Trust	29341	2022-05-12	0
Johnny Hodges	29342	2022-05-12	0
John Wolfington	29343	2022-05-12	0
R.I.O feat. Virus Syndicate	29344	2022-05-12	0
Viktoria Tolstoy	29345	2022-05-12	0
Fernandes	29346	2022-05-12	0
Deepak Chopra and Adam Plack	29347	2022-05-12	0
Tessie Hill	29348	2022-05-12	0
Organized Konfusion	29349	2022-05-12	0
Simon Bookish	29350	2022-05-12	0
Anthony Shakir	29351	2022-05-12	0
Victor Jara	29352	2022-05-12	0
Mikael Stavöstrand & Franco Cinelli	29353	2022-05-12	0
The Mai 68's	29354	2022-05-12	0
The Orb	29355	2022-05-12	0
Fallen From the Sky	29356	2022-05-12	0
Fi-Asko	29357	2022-05-12	0
Anoushka Shankar	29358	2022-05-12	0
Big Sugar	29359	2022-05-12	0
Björn Afzelius	29360	2022-05-12	0
Marinas	29361	2022-05-12	0
Port-Royal	29362	2022-05-12	0
Beau Williams	29363	2022-05-12	0
Nights Like These	29364	2022-05-12	0
David Allan Coe	29365	2022-05-12	0
Ra	29366	2022-05-12	0
Liléa narrative	29367	2022-05-12	0
Lush	29368	2022-05-12	0
Drake / Lil Wayne / Young Jeezy	29369	2022-05-12	0
The Fascinators	29370	2022-05-12	0
Leeroy Stagger	29371	2022-05-12	0
Jon Cutler featuring E-Man	29372	2022-05-12	0
Zeni Geva	29373	2022-05-12	0
Akala	29374	2022-05-12	0
All My Faith Lost...	29375	2022-05-12	0
Origin	29376	2022-05-12	0
New London Fire	29377	2022-05-12	0
Sophie Sugar	29378	2022-05-12	0
Helen Shapiro	29379	2022-05-12	0
Reach 454	29380	2022-05-12	0
Sun & Soul Shades_ Theresa Burnette_ Fed Conti	29381	2022-05-12	0
Blue Ketchuppp	29382	2022-05-12	0
The Monotones	29383	2022-05-12	0
Kidda	29384	2022-05-12	0
Frankie Valli And The Four Seasons	29385	2022-05-12	0
Meshuggah	29386	2022-05-12	0
The Wave Pictures	29387	2022-05-12	0
Dorian	29388	2022-05-12	0
The Heart Attacks	29389	2022-05-12	0
Bobbi Humphrey	29390	2022-05-12	0
Benny Spellman	29391	2022-05-12	0
The Bachelors	29392	2022-05-12	0
Jonathan Edwards	29393	2022-05-12	0
Hadouk Trio	29394	2022-05-12	0
The Harvard Lampoon Comedians	29395	2022-05-12	0
Burt Bacharach	29396	2022-05-12	0
Green Lantern	29397	2022-05-12	0
GreenAppleQuickStep	29398	2022-05-12	0
León Gieco	29399	2022-05-12	0
Tiye Phoenix	29400	2022-05-12	0
Yab Yum vs Electrypnose	29401	2022-05-12	0
Florian Meindl	29402	2022-05-12	0
L'Aroye	29403	2022-05-12	0
Philippe Rochard	29404	2022-05-12	0
Grandaddy Souf	29405	2022-05-12	0
Shel Silverstein	29406	2022-05-12	0
Lukas Greenberg	29407	2022-05-12	0
Panik	29408	2022-05-12	0
Various Production	29409	2022-05-12	0
Sonic Subjunkies	29410	2022-05-12	0
Alexandra Burke Feat. Ne-Yo	29411	2022-05-12	0
Anne Gabriel	29412	2022-05-12	0
VS	29413	2022-05-12	0
Widescreen Mode	29414	2022-05-12	0
Tiny Tin Lady	29415	2022-05-12	0
Riverboat Gamblers	29416	2022-05-12	0
Small Faces	29417	2022-05-12	0
The Hombres	29418	2022-05-12	0
S.O.A.P.	29419	2022-05-12	0
Cielo	29420	2022-05-12	0
Frank Proffitt	29421	2022-05-12	0
Stray Dog	29422	2022-05-12	0
[sub]NOVA	29423	2022-05-12	0
Jonas Fjeld & Chatham County Line	29424	2022-05-12	0
Adonis	29425	2022-05-12	0
Morandi	29426	2022-05-12	0
Illya Kuryaki And The Valderramas	29427	2022-05-12	0
Kid Harpoon	29428	2022-05-12	0
KJ Sawka	29429	2022-05-12	0
WC / Dr. Stank / Lady T / Deville	29430	2022-05-12	0
Lovehatehero	29431	2022-05-12	0
Gazpacho	29432	2022-05-12	0
G. Love & Special Sauce	29433	2022-05-12	0
Shayna Steele	29434	2022-05-12	0
Love Of Lesbian	29435	2022-05-12	0
Joan Jett & The Blackhearts	29436	2022-05-12	0
Chingo Bling w/ICE	29437	2022-05-12	0
Sleepytime Lullabies	29438	2022-05-12	0
Krystal Meyers	29439	2022-05-12	0
BLM	29440	2022-05-12	0
Vandera	29441	2022-05-12	0
Junior Vasquez	29442	2022-05-12	0
Alisia	29443	2022-05-12	0
Ras & Slaughter	29444	2022-05-12	0
Bomba Estéreo	29445	2022-05-12	0
Indicant	29446	2022-05-12	0
P.M. Sampson	29447	2022-05-12	0
Tim Exile	29448	2022-05-12	0
Sick Sense Cru	29449	2022-05-12	0
María Dolores Pradera / Amaya Uranga	29450	2022-05-12	0
Dj Boss	29451	2022-05-12	0
Cold Blue	29452	2022-05-12	0
Booker T.	29453	2022-05-12	0
Carly Simon	29454	2022-05-12	0
Rhett Akins	29455	2022-05-12	0
Pierpoljak / Rappa Roberts	29456	2022-05-12	0
Dal Gren	29457	2022-05-12	0
Once Tiros	29458	2022-05-12	0
Juliane Werding	29459	2022-05-12	0
Cal Smith	29460	2022-05-12	0
Sent By Ravens	29461	2022-05-12	0
La Buena Vida	29462	2022-05-12	0
The Spencer Davis Group	29463	2022-05-12	0
Amelia Curran	29464	2022-05-12	0
Tarmac	29465	2022-05-12	0
Beyoncé	29466	2022-05-12	0
Armand Van Helden	29467	2022-05-12	0
From Good Homes	29468	2022-05-12	0
Creamy	29469	2022-05-12	0
Anis	29470	2022-05-12	0
The Berlin Project	29471	2022-05-12	0
Ex Models	29472	2022-05-12	0
Zeilensprung	29473	2022-05-12	0
Susan Gritton / Gabrieli Players / Paul McCreesh	29474	2022-05-12	0
Daniel Landa	29475	2022-05-12	0
Ramses Shaffy	29476	2022-05-12	0
Airwave featuring Coka	29477	2022-05-12	0
Rivers Cuomo	29478	2022-05-12	0
Golden Gate Jubilee Quartet	29479	2022-05-12	0
KMD	29480	2022-05-12	0
Evert Taube	29481	2022-05-12	0
Arch Enemy	29482	2022-05-12	0
UNKLE Feat. Gavin Clark	29483	2022-05-12	0
Rainhard Fendrich	29484	2022-05-12	0
Michael Bloomfield	29485	2022-05-12	0
Alvin Cash	29486	2022-05-12	0
Avant / Charlie Wilson	29487	2022-05-12	0
isis	29488	2022-05-12	0
Loudness	29489	2022-05-12	0
Jeff Beck Group	29490	2022-05-12	0
BlackHawk	29491	2022-05-12	0
Gene Pitney	29492	2022-05-12	0
Eko Fresh feat. Bushido	29493	2022-05-12	0
Jonatha Brooke	29494	2022-05-12	0
Nicolay featuring Kay_ Liz Vaughn	29495	2022-05-12	0
Cagan Nazlioglu	29496	2022-05-12	0
Le Rat Luciano	29497	2022-05-12	0
Screaming Mechanical Brain	29498	2022-05-12	0
The Stems	29499	2022-05-12	0
Art Blakey & Clifford Brown	29500	2022-05-12	0
Electronica	29501	2022-05-12	0
Two Tone Club	29502	2022-05-12	0
Junkie	29503	2022-05-12	0
Ann Hampton Callaway	29504	2022-05-12	0
Doni i Momchil	29505	2022-05-12	0
Alan Licht	29506	2022-05-12	0
Johnny Dodds Black Bottom Stompers	29507	2022-05-12	0
Nichol's	29508	2022-05-12	0
Those Who Lie Beneath	29509	2022-05-12	0
Edith Wilson & Lena Wilson	29510	2022-05-12	0
Robert Shaw	29511	2022-05-12	0
Rachel Sweet	29512	2022-05-12	0
Irini Merkouri	29513	2022-05-12	0
The Caroloregians	29514	2022-05-12	0
Markus Krunegård	29515	2022-05-12	0
Derek Martin	29516	2022-05-12	0
Threats	29517	2022-05-12	0
Ulver	29518	2022-05-12	0
Alan Silvestri	29519	2022-05-12	0
The Dirty Skirts	29520	2022-05-12	0
Andy H	29521	2022-05-12	0
Lagarto Amarillo	29522	2022-05-12	0
Antoine Clamaran & Mario Ochoa ft Lulu Hughes	29523	2022-05-12	0
Doc & Merle Watson	29524	2022-05-12	0
Estatuas De Sol	29525	2022-05-12	0
Fleshtones	29526	2022-05-12	0
Bloodhound Gang	29527	2022-05-12	0
Joe Stump	29528	2022-05-12	0
Rapsoul	29529	2022-05-12	0
Steve Hillage	29530	2022-05-12	0
Cathy Davey	29531	2022-05-12	0
Alf Robertson	29532	2022-05-12	0
Sonsonete	29533	2022-05-12	0
Jason Falkner	29534	2022-05-12	0
Los Alegres De Terán	29535	2022-05-12	0
Maurice Jarre	29536	2022-05-12	0
Terminal 11	29537	2022-05-12	0
Marion Williams	29538	2022-05-12	0
Despistaos	29539	2022-05-12	0
Glow	29540	2022-05-12	0
Camaron De La Isla	29541	2022-05-12	0
Jack Frost & The Circle Jerks	29542	2022-05-12	0
Diomedes Diaz	29543	2022-05-12	0
Break	29544	2022-05-12	0
Limahl	29545	2022-05-12	0
Laurel & Hardy	29546	2022-05-12	0
Jimmie Lunceford	29547	2022-05-12	0
New American Shame	29548	2022-05-12	0
Elvira	29549	2022-05-12	0
LTN	29550	2022-05-12	0
June Carter Cash;Homer & Jethro	29551	2022-05-12	0
Heavens to Betsy	29552	2022-05-12	0
Lupen Crook	29553	2022-05-12	0
Shubha Mudgal	29554	2022-05-12	0
Lick	29555	2022-05-12	0
Abschlach	29556	2022-05-12	0
Michael Masley	29557	2022-05-12	0
Isobel Campbell	29558	2022-05-12	0
Brick	29559	2022-05-12	0
Damone	29560	2022-05-12	0
Inger Marie Gundersen	29561	2022-05-12	0
Lafayette Afro Rock Band	29562	2022-05-12	0
Goldie Feat. Krs One	29563	2022-05-12	0
Shalamar	29564	2022-05-12	0
Jeff Finlin	29565	2022-05-12	0
Stealers Wheel	29566	2022-05-12	0
Sarbel	29567	2022-05-12	0
Chilled Jazz Masters	29568	2022-05-12	0
Yves Murasca	29569	2022-05-12	0
Pérez Prado	29570	2022-05-12	0
The Ackleys	29571	2022-05-12	0
Lowgold	29572	2022-05-12	0
Assassin	29573	2022-05-12	0
Rust	29574	2022-05-12	0
Baba Bulleh Shah	29575	2022-05-12	0
My Sad Captains	29576	2022-05-12	0
Deborah Cox	29577	2022-05-12	0
Jessica Fletchers	29578	2022-05-12	0
Fabrice Lig	29579	2022-05-12	0
Cities	29580	2022-05-12	0
The Union Underground	29581	2022-05-12	0
Los Metalicoz	29582	2022-05-12	0
Maxus	29583	2022-05-12	0
Black Flag	29584	2022-05-12	0
Gnawa Diffusion	29585	2022-05-12	0
Spizzenergi	29586	2022-05-12	0
Brainstorm	29587	2022-05-12	0
Ike_ Tina Turner	29588	2022-05-12	0
The Lullaby Orchestra	29589	2022-05-12	0
Omara Portuondo	29590	2022-05-12	0
The Clean	29591	2022-05-12	0
Maurane	29592	2022-05-12	0
Kukan Dub Lagan	29593	2022-05-12	0
Rev. James Cleveland and the Northern & Southern California Choirs of the G.M.W.A.	29594	2022-05-12	0
Leggo Beast	29595	2022-05-12	0
Enno Bunger	29596	2022-05-12	0
Paolo Mojo	29597	2022-05-12	0
Grammatics	29598	2022-05-12	0
Ephen Rian	29599	2022-05-12	0
Gene Harris And The Three Sounds	29600	2022-05-12	0
Ghetto Street Fighter	29601	2022-05-12	0
Marc Miroir	29602	2022-05-12	0
Collection d'Arnell Andréa	29603	2022-05-12	0
Hess Is More	29604	2022-05-12	0
Miguel Bose	29605	2022-05-12	0
Samuel Flynn Scott	29606	2022-05-12	0
The Les Humphries Singers	29607	2022-05-12	0
Lester Sterling	29608	2022-05-12	0
Tania Maria / Viva Brazil Quartet	29609	2022-05-12	0
Lynda	29610	2022-05-12	0
Peret	29611	2022-05-12	0
Keith Martin	29612	2022-05-12	0
Korea	29613	2022-05-12	0
Presence	29614	2022-05-12	0
Menno de Jong	29615	2022-05-12	0
Brian Harden	29616	2022-05-12	0
Marie Modiano	29617	2022-05-12	0
La 5A Estacion	29618	2022-05-12	0
Elecktra	29619	2022-05-12	0
Calexico	29620	2022-05-12	0
Rakim	29621	2022-05-12	0
Shaka Shamba	29622	2022-05-12	0
Los Tipitos	29623	2022-05-12	0
Joe Heaney	29624	2022-05-12	0
Sound Choice Karaoke	29625	2022-05-12	0
Kim Burrell	29626	2022-05-12	0
The Whip	29627	2022-05-12	0
Freddie Jackson	29628	2022-05-12	0
The Flying Lizards	29629	2022-05-12	0
Moe Bandy	29630	2022-05-12	0
Alecs Marta	29631	2022-05-12	0
Robin Williams	29632	2022-05-12	0
Dog Day	29633	2022-05-12	0
A/C Project	29634	2022-05-12	0
Marco Masini	29635	2022-05-12	0
Miguel Angel Muñoz	29636	2022-05-12	0
Tomas	29637	2022-05-12	0
SISTERS	29638	2022-05-12	0
Lisa Loeb & Nine Stories	29639	2022-05-12	0
Miss Money	29640	2022-05-12	0
DON JOHNSON BIG BAND	29641	2022-05-12	0
Sidsel Endresen	29642	2022-05-12	0
Optiganally Yours	29643	2022-05-12	0
Jason Forrest	29644	2022-05-12	0
Elon	29645	2022-05-12	0
Erin Boheme	29646	2022-05-12	0
Rosalie Allen	29647	2022-05-12	0
Travis Tritt	29648	2022-05-12	0
We Were the States	29649	2022-05-12	0
Mamelo Sound System	29650	2022-05-12	0
Soulphiction	29651	2022-05-12	0
Aeon	29652	2022-05-12	0
KEROSENE CLUB	29653	2022-05-12	0
The Mother Hips	29654	2022-05-12	0
RIP SLYME	29655	2022-05-12	0
This is a Process of a Still Life	29656	2022-05-12	0
Academy of St Martin-in-the-Fields/Sir Neville Marriner	29657	2022-05-12	0
Chocolate Weasel	29658	2022-05-12	0
Melissa McClelland	29659	2022-05-12	0
Antonis Remos	29660	2022-05-12	0
Walter Egan	29661	2022-05-12	0
The Odd Couple	29662	2022-05-12	0
Norma Waterson	29663	2022-05-12	0
Hometaping	29664	2022-05-12	0
Essie Jain	29665	2022-05-12	0
Natural Elements	29666	2022-05-12	0
Warren Hill	29667	2022-05-12	0
Nasty Savage	29668	2022-05-12	0
Peter Yarrow	29669	2022-05-12	0
Mad Sin	29670	2022-05-12	0
ANJA GARBAREK	29671	2022-05-12	0
Roger Voudouris	29672	2022-05-12	0
Dennis Brown	29673	2022-05-12	0
Safri Duo / Clark Anderson	29674	2022-05-12	0
Ras Moses & Ricky Rudy	29675	2022-05-12	0
Peter Bradley Adams	29676	2022-05-12	0
Lalah Hathaway	29677	2022-05-12	0
Chosen Few	29678	2022-05-12	0
Darrell Banks	29679	2022-05-12	0
Little Porkchop	29680	2022-05-12	0
prince ALI	29681	2022-05-12	0
Paul Ritch	29682	2022-05-12	0
Universal Congress Of	29683	2022-05-12	0
Tesla	29684	2022-05-12	0
Dawn Of Ashes	29685	2022-05-12	0
David Axelrod	29686	2022-05-12	0
Loretta Lynn	29687	2022-05-12	0
Four Day Hombre	29688	2022-05-12	0
DJ Ogi	29689	2022-05-12	0
Judas Priest	29690	2022-05-12	0
Julia Fordham	29691	2022-05-12	0
Matinalsystem	29692	2022-05-12	0
Philip Glass Ensemble	29693	2022-05-12	0
Ray Wylie Hubbard	29694	2022-05-12	0
Fes-te Fotre	29695	2022-05-12	0
Welton Irie	29696	2022-05-12	0
Sneaker Pimps	29697	2022-05-12	0
Hydrogyn	29698	2022-05-12	0
Danzig	29699	2022-05-12	0
Nightnoise	29700	2022-05-12	0
mewithoutYou	29701	2022-05-12	0
Anti-Pasti	29702	2022-05-12	0
gaza kim & lisa hype	29703	2022-05-12	0
James Cotton	29704	2022-05-12	0
Alaska Y Dinarama	29705	2022-05-12	0
David & High Spirit	29706	2022-05-12	0
The Sensational Alex Harvey Band	29707	2022-05-12	0
Cross Stitched Eyes	29708	2022-05-12	0
Mindless Faith	29709	2022-05-12	0
Silver Mt. Zion	29710	2022-05-12	0
CSO	29711	2022-05-12	0
A Small Good Thing	29712	2022-05-12	0
The Johns	29713	2022-05-12	0
Pied Pipers	29714	2022-05-12	0
Tracy Chapman	29715	2022-05-12	0
Mason Vs Princess Superstar	29716	2022-05-12	0
James Brown	29717	2022-05-12	0
FREAK NASTY PRESENTS / PIKASSO	29718	2022-05-12	0
Ramon Ayala Y Sus Bravos Del Norte	29719	2022-05-12	0
Jaka	29720	2022-05-12	0
The Emperor Machine	29721	2022-05-12	0
Steve Hammond	29722	2022-05-12	0
Melanie	29723	2022-05-12	0
Nneka	29724	2022-05-12	0
Johnny Nash	29725	2022-05-12	0
Gabriel Batz	29726	2022-05-12	0
World Inferno Friendship Society	29727	2022-05-12	0
Tangled Thoughts	29728	2022-05-12	0
Marygold	29729	2022-05-12	0
Sixwire	29730	2022-05-12	0
Bochum Welt	29731	2022-05-12	0
Hunters & Collectors	29732	2022-05-12	0
Edit Select	29733	2022-05-12	0
David Lyme	29734	2022-05-12	0
Boy Omega	29735	2022-05-12	0
Cañaman	29736	2022-05-12	0
Slade	29737	2022-05-12	0
Marc Korn vs. DJ The Bass	29738	2022-05-12	0
2 Bit Pie	29739	2022-05-12	0
Domu	29740	2022-05-12	0
The Jimi Hendrix Experience	29741	2022-05-12	0
Dolly Dots	29742	2022-05-12	0
Speedfreak	29743	2022-05-12	0
DJ Deadbeat	29744	2022-05-12	0
MyChildren MyBride	29745	2022-05-12	0
Jeff Talmadge	29746	2022-05-12	0
CRUX & Brooklyn Zoo vs. Human Resource	29747	2022-05-12	0
Epitaph	29748	2022-05-12	0
The Silly Pillows	29749	2022-05-12	0
Riccardo Muti;Orchestra del Teatro alla Scala;Coro del Teatro alla Scala	29750	2022-05-12	0
Asmus Tietchens	29751	2022-05-12	0
Jobriath	29752	2022-05-12	0
Uriel	29753	2022-05-12	0
Mellowdrone	29754	2022-05-12	0
Grupo Mania	29755	2022-05-12	0
Hubert Colau	29756	2022-05-12	0
THREE YEARS HIDING	29757	2022-05-12	0
The Killerest Expression	29758	2022-05-12	0
Calaita	29759	2022-05-12	0
Nils Petter Molvaer	29760	2022-05-12	0
Los Solitarios	29761	2022-05-12	0
Kasms	29762	2022-05-12	0
Atahualpa Yupanqui	29763	2022-05-12	0
Sissy Goodhouse	29764	2022-05-12	0
Budget Girls	29765	2022-05-12	0
Slaughter And The Dogs	29766	2022-05-12	0
Allo_ Darlin'	29767	2022-05-12	0
Plantlife	29768	2022-05-12	0
Stafraenn Hakon	29769	2022-05-12	0
Grade 8	29770	2022-05-12	0
Laszlo Hortobagyi	29771	2022-05-12	0
Disney Studio Chorus/Donald Novis	29772	2022-05-12	0
Ruby Isle	29773	2022-05-12	0
Afel Bocoum	29774	2022-05-12	0
Matthews Southern Comfort	29775	2022-05-12	0
Mubali & Arahat aka Arabali	29776	2022-05-12	0
Ron Kenoly	29777	2022-05-12	0
Audio Lotion	29778	2022-05-12	0
Baroness	29779	2022-05-12	0
Knee Deep	29780	2022-05-12	0
Sandy Marton	29781	2022-05-12	0
Eastmountainsouth	29782	2022-05-12	0
Red Pony Clock	29783	2022-05-12	0
Lil Wyte	29784	2022-05-12	0
Sea Wolf	29785	2022-05-12	0
Big Daddy Kane	29786	2022-05-12	0
Luka Bloom	29787	2022-05-12	0
David Lynch	29788	2022-05-12	0
OTT	29789	2022-05-12	0
Classic Case	29790	2022-05-12	0
Tony Martin	29791	2022-05-12	0
Jen Chapin	29792	2022-05-12	0
Cause For Alarm	29793	2022-05-12	0
Ron Kavana	29794	2022-05-12	0
Dread Zeppelin	29795	2022-05-12	0
Suncatcher	29796	2022-05-12	0
Sofa	29797	2022-05-12	0
Durutti Column The	29798	2022-05-12	0
Don Carlos	29799	2022-05-12	0
Loudermilk	29800	2022-05-12	0
Braille	29801	2022-05-12	0
Hortense Ellis	29802	2022-05-12	0
U.K. Subs	29803	2022-05-12	0
Johnny Winter	29804	2022-05-12	0
The Andrews Sisters	29805	2022-05-12	0
Monastir	29806	2022-05-12	0
Greg Osby	29807	2022-05-12	0
Waltari	29808	2022-05-12	0
Mateo & Matos Ft. Dirty Turk	29809	2022-05-12	0
Charlie Spand	29810	2022-05-12	0
Florence & The Machine	29811	2022-05-12	0
Spezializtz	29812	2022-05-12	0
Alcôve	29813	2022-05-12	0
Right Said Fred	29814	2022-05-12	0
Zac Harmon	29815	2022-05-12	0
Medication	29816	2022-05-12	0
Georgie Fame & The Blue Flames	29817	2022-05-12	0
Dakoda Motor Company	29818	2022-05-12	0
Dar Williams	29819	2022-05-12	0
V-ro	29820	2022-05-12	0
Reyli Barba	29821	2022-05-12	0
Warren Cooper	29822	2022-05-12	0
Sav Killz	29823	2022-05-12	0
Dave Eggar	29824	2022-05-12	0
Necrophiliac	29825	2022-05-12	0
Pierre Perret	29826	2022-05-12	0
Thick As Blood	29827	2022-05-12	0
River City Rebels	29828	2022-05-12	0
The Bodysnatchers	29829	2022-05-12	0
Orchestre Symphonique de Montréal / Charles Dutoit	29830	2022-05-12	0
All Good Funk Alliance (feat. Swamburger&Alexandrah	29831	2022-05-12	0
Feeltz & Leo feat. Aneym	29832	2022-05-12	0
Flatfoot 56	29833	2022-05-12	0
Handsome Devil	29834	2022-05-12	0
Baracuda	29835	2022-05-12	0
Willie Colon	29836	2022-05-12	0
DJ Vadim	29837	2022-05-12	0
Hector Martignon	29838	2022-05-12	0
Tame One	29839	2022-05-12	0
Alfredo Sadel	29840	2022-05-12	0
Unsung Zeros	29841	2022-05-12	0
Debbie Davies_ Chris Layton & Tommy Shannon	29842	2022-05-12	0
Barry Künzel	29843	2022-05-12	0
Strung Out	29844	2022-05-12	0
White Skull	29845	2022-05-12	0
Soundscape	29846	2022-05-12	0
Jose Padilla	29847	2022-05-12	0
Ronald Reagan	29848	2022-05-12	0
Lori Carson	29849	2022-05-12	0
Martin Briley	29850	2022-05-12	0
Kids Like Us	29851	2022-05-12	0
DJ Squeeky	29852	2022-05-12	0
Sergio Denis	29853	2022-05-12	0
Forensics	29854	2022-05-12	0
The Mercury Project	29855	2022-05-12	0
SANSHIRO	29856	2022-05-12	0
John O'Callaghan	29857	2022-05-12	0
The Nightjars	29858	2022-05-12	0
Mike Parker	29859	2022-05-12	0
Mindlag project	29860	2022-05-12	0
Allez Allez	29861	2022-05-12	0
Sapphire	29862	2022-05-12	0
Maria Taylor	29863	2022-05-12	0
Confucius	29864	2022-05-12	0
Ride	29865	2022-05-12	0
Bukka White	29866	2022-05-12	0
Fernando Ubiergo	29867	2022-05-12	0
Wanderlust	29868	2022-05-12	0
Botz And Flydrums	29869	2022-05-12	0
Raw Artistic Soul	29870	2022-05-12	0
Shurik'n	29871	2022-05-12	0
Supreme Majesty	29872	2022-05-12	0
Jerome Isma-ae	29873	2022-05-12	0
Bill Perry	29874	2022-05-12	0
Peer Gynt	29875	2022-05-12	0
Die Doraus Und Die Marinas	29876	2022-05-12	0
Chandeen	29877	2022-05-12	0
The Intruders	29878	2022-05-12	0
Stefano Battaglia_ Giovanni Maier_ Michele Rabbia	29879	2022-05-12	0
Mount Eerie	29880	2022-05-12	0
Prince & The Revolution	29881	2022-05-12	0
Blackbyrds	29882	2022-05-12	0
Rhian Sheehan	29883	2022-05-12	0
Sine Star Project	29884	2022-05-12	0
Spooky Tooth	29885	2022-05-12	0
Halestorm	29886	2022-05-12	0
Luis Y Julian	29887	2022-05-12	0
Darqwan	29888	2022-05-12	0
Acoustic Alchemy	29889	2022-05-12	0
The Mercy Cage	29890	2022-05-12	0
Patrick Park	29891	2022-05-12	0
Chichi Peralta	29892	2022-05-12	0
Los Fancy Free	29893	2022-05-12	0
Atlantic Drift	29894	2022-05-12	0
Andreas Ammer / FM Einheit	29895	2022-05-12	0
The Fortunes	29896	2022-05-12	0
Amalia Mendoza	29897	2022-05-12	0
Gilgamesh	29898	2022-05-12	0
Willie Nelson and Leon Russell	29899	2022-05-12	0
Juice Newton	29900	2022-05-12	0
Eden Maine	29901	2022-05-12	0
Barbara Dickson	29902	2022-05-12	0
Slim Thug	29903	2022-05-12	0
The Thrown Ups	29904	2022-05-12	0
Commercial Club Crew	29905	2022-05-12	0
getAmped	29906	2022-05-12	0
New Riders of The Purple Sage	29907	2022-05-12	0
Chris Brokaw	29908	2022-05-12	0
Casper & The Cookies	29909	2022-05-12	0
Martha Tilston	29910	2022-05-12	0
Wonderland Avenue	29911	2022-05-12	0
C-Murder	29912	2022-05-12	0
Earl Bostic	29913	2022-05-12	0
Johnny Pearson	29914	2022-05-12	0
Toots & The Maytals	29915	2022-05-12	0
Maria Bamford	29916	2022-05-12	0
McFly	29917	2022-05-12	0
God Dethroned	29918	2022-05-12	0
Yo-Yo Ma;Pittsburgh Symphony Orchestra;Lorin Maazel	29919	2022-05-12	0
Norah Jones	29920	2022-05-12	0
The Accüsed	29921	2022-05-12	0
James Moody	29922	2022-05-12	0
Marc Shaiman	29923	2022-05-12	0
Tingsek / Svante Lodén	29924	2022-05-12	0
The Infinity Project	29925	2022-05-12	0
Polyrhythm Addicts	29926	2022-05-12	0
The Horns Of Happiness	29927	2022-05-12	0
Gypsy Pistoleros	29928	2022-05-12	0
Turin Brakes	29929	2022-05-12	0
The Pointer Sisters	29930	2022-05-12	0
Jacques Burtin	29931	2022-05-12	0
Peaches	29932	2022-05-12	0
Humble Pie	29933	2022-05-12	0
The Three Suns	29934	2022-05-12	0
Marracash	29935	2022-05-12	0
Divinefire	29936	2022-05-12	0
Rock Hard Power Spray	29937	2022-05-12	0
Maelstrom Inc.	29938	2022-05-12	0
PUNGENT STENCH	29939	2022-05-12	0
Norman Brown	29940	2022-05-12	0
Marion Meadows	29941	2022-05-12	0
Arcade Fire	29942	2022-05-12	0
Destruments	29943	2022-05-12	0
Panzer AG	29944	2022-05-12	0
Ginuwine	29945	2022-05-12	0
Big Sty	29946	2022-05-12	0
Trim ft. Slayer & Nico Lindsey	29947	2022-05-12	0
The Faintest Ideas	29948	2022-05-12	0
Martin Solveig_ Rumi	29949	2022-05-12	0
The Enid	29950	2022-05-12	0
Jorge Ferreira	29951	2022-05-12	0
Vieja Trova Santiaguera	29952	2022-05-12	0
Wang Fei	29953	2022-05-12	0
Rondò Veneziano	29954	2022-05-12	0
General Surgery	29955	2022-05-12	0
Three-6 Mafia	29956	2022-05-12	0
Inchtabokatables	29957	2022-05-12	0
Mobius Band	29958	2022-05-12	0
Styles Of Beyond	29959	2022-05-12	0
Silent Stream Of Godless Elegy	29960	2022-05-12	0
Superlitio	29961	2022-05-12	0
Alcazar	29962	2022-05-12	0
Betchadupa	29963	2022-05-12	0
Silverio	29964	2022-05-12	0
Lucky Soul	29965	2022-05-12	0
Source Of Tide	29966	2022-05-12	0
John Amen	29967	2022-05-12	0
Ray Charles / The Count Basie Orchestra	29968	2022-05-12	0
Jon Hassell	29969	2022-05-12	0
Large Professor	29970	2022-05-12	0
Junior Kelly	29971	2022-05-12	0
Agoria	29972	2022-05-12	0
Andrews Sisters & Glenn Miller	29973	2022-05-12	0
Suspekt / Kælderposen	29974	2022-05-12	0
4LYN	29975	2022-05-12	0
Johnny Mathis	29976	2022-05-12	0
Françoise Hardy - Alain Delon	29977	2022-05-12	0
Sukhwinder Singh / Sapna Avasthi / Sandeep Chowta / Jolly Mukherjee	29978	2022-05-12	0
Spyro Gyra	29979	2022-05-12	0
London After Midnight	29980	2022-05-12	0
L C	29981	2022-05-12	0
Dana Glover	29982	2022-05-12	0
Aboriginal Dreamtime	29983	2022-05-12	0
Carole King	29984	2022-05-12	0
Need New Body	29985	2022-05-12	0
Wu-Syndicate	29986	2022-05-12	0
Anti-Nowhere League	29987	2022-05-12	0
Neal Morse	29988	2022-05-12	0
Donny McCaslin	29989	2022-05-12	0
Albert Préjean	29990	2022-05-12	0
The Sklar Bros.	29991	2022-05-12	0
MJ Hibbett & the Validators	29992	2022-05-12	0
Raihan	29993	2022-05-12	0
The Cool Kids	29994	2022-05-12	0
Philip Glass Ensemble;Michael Reisman	29995	2022-05-12	0
Doug Dillard	29996	2022-05-12	0
Like Woah!	29997	2022-05-12	0
36 Crazyfists	29998	2022-05-12	0
Jaco Abel	29999	2022-05-12	0
Klezmer Conservatory Band	30000	2022-05-12	0
Fourth Floor Collapse	30001	2022-05-12	0
Orpheus Chamber Orchestra	30002	2022-05-12	0
Julie Andrews_ Rex Harrison & Broadway Cast	30003	2022-05-12	0
Brooke Valentine feat. Lil Jon_ Da Brat_ Remy Ma & Miss B	30004	2022-05-12	0
Young Cash	30005	2022-05-12	0
Sidecars	30006	2022-05-12	0
Estados Alterados	30007	2022-05-12	0
Emerson Hart	30008	2022-05-12	0
Fritz Wunderlich / Die Spilar Schrammeln	30009	2022-05-12	0
Robert Babicz	30010	2022-05-12	0
The Chrome Cranks	30011	2022-05-12	0
Buddy Johnson	30012	2022-05-12	0
Douglas Spotted Eagle	30013	2022-05-12	0
Morgan Heritage	30014	2022-05-12	0
The Frank And Walters	30015	2022-05-12	0
Wayman Tisdale	30016	2022-05-12	0
Nothing But Oregano	30017	2022-05-12	0
Pattern J	30018	2022-05-12	0
Rhythm King And Her Friends	30019	2022-05-12	0
Two Dollar Bash	30020	2022-05-12	0
Tech N9ne	30021	2022-05-12	0
Contraband	30022	2022-05-12	0
Miranda Lee Richards	30023	2022-05-12	0
John Parish	30024	2022-05-12	0
The Vara-Tones	30025	2022-05-12	0
Ace Troubleshooter	30026	2022-05-12	0
Fatso Jetson	30027	2022-05-12	0
Louis Chedid	30028	2022-05-12	0
Craig Safan	30029	2022-05-12	0
Amberian Dawn	30030	2022-05-12	0
Tim Rogers	30031	2022-05-12	0
Jamie Scott & The Town	30032	2022-05-12	0
Hognose	30033	2022-05-12	0
Teitur	30034	2022-05-12	0
Population Reduction	30035	2022-05-12	0
Pridebowl	30036	2022-05-12	0
La Monja Enana	30037	2022-05-12	0
Government Issue	30038	2022-05-12	0
James P Johnson	30039	2022-05-12	0
Readymade	30040	2022-05-12	0
J. Tillman	30041	2022-05-12	0
Funeral	30042	2022-05-12	0
Mischa Maisky/Martha Argerich	30043	2022-05-12	0
Bruce Broughton	30044	2022-05-12	0
Pedro Luís e a Parede	30045	2022-05-12	0
Danni Carlos	30046	2022-05-12	0
Monica Naranjo	30047	2022-05-12	0
General Magic	30048	2022-05-12	0
The Crystal Ark	30049	2022-05-12	0
Grief	30050	2022-05-12	0
The Itals	30051	2022-05-12	0
Stephan Bodzin vs. Marc Romboy	30052	2022-05-12	0
The Refreshments	30053	2022-05-12	0
dDamage	30054	2022-05-12	0
Muzzaik	30055	2022-05-12	0
Ozomatli	30056	2022-05-12	0
Jacknife Lee	30057	2022-05-12	0
Aqua Bassino	30058	2022-05-12	0
Steven Wright	30059	2022-05-12	0
Terry Scott	30060	2022-05-12	0
Cali	30061	2022-05-12	0
Kid British	30062	2022-05-12	0
Going Home	30063	2022-05-12	0
Rentrer En Soi	30064	2022-05-12	0
Paul Desmond	30065	2022-05-12	0
Jennifer Clarke	30066	2022-05-12	0
Fanton Mojah	30067	2022-05-12	0
Lowe	30068	2022-05-12	0
Chico Y Chica	30069	2022-05-12	0
Les amis au Pakistan	30070	2022-05-12	0
Moiseyev Dance Company	30071	2022-05-12	0
Tuesdays	30072	2022-05-12	0
Norma Jean	30073	2022-05-12	0
Exposé	30074	2022-05-12	0
Serengeti	30075	2022-05-12	0
The Sons Of Champlin	30076	2022-05-12	0
Jute Gyte	30077	2022-05-12	0
The Mirage	30078	2022-05-12	0
Measha Brueggergosman / Justus Zeyen	30079	2022-05-12	0
The Gothic Archies	30080	2022-05-12	0
Shigeru Umebayashi	30081	2022-05-12	0
Jack Ingram	30082	2022-05-12	0
Santamaria	30083	2022-05-12	0
Chokai	30084	2022-05-12	0
K.T. Oslin	30085	2022-05-12	0
Serú Girán	30086	2022-05-12	0
Jean Ferrat	30087	2022-05-12	0
Victimas Del Doctor Cerebro	30088	2022-05-12	0
Obscure Disorder	30089	2022-05-12	0
The Heart Throbs	30090	2022-05-12	0
Wim Mertens	30091	2022-05-12	0
Birdman & Lil Wayne	30092	2022-05-12	0
Ashley Best	30093	2022-05-12	0
King Curtis	30094	2022-05-12	0
Suprême NTM	30095	2022-05-12	0
Perpetual Loop	30096	2022-05-12	0
Carol Sloane	30097	2022-05-12	0
Joie de vivre	30098	2022-05-12	0
Moses Wiggins	30099	2022-05-12	0
Fiction Factory	30100	2022-05-12	0
The Kingston Trio	30101	2022-05-12	0
Lizzy Borden	30102	2022-05-12	0
Joseph Spence	30103	2022-05-12	0
Chetes	30104	2022-05-12	0
Doug Sahm and the Texas Mavericks	30105	2022-05-12	0
Rod Bernard	30106	2022-05-12	0
Pee Wee King	30107	2022-05-12	0
Tito Puente & His Orchestra	30108	2022-05-12	0
Torfrock	30109	2022-05-12	0
Gianluca Lo Presti	30110	2022-05-12	0
Adrian Sherwood	30111	2022-05-12	0
Left Lane Cruiser	30112	2022-05-12	0
La Pulqueria	30113	2022-05-12	0
Grupo Niche	30114	2022-05-12	0
Necromantia	30115	2022-05-12	0
Dazzling Killmen	30116	2022-05-12	0
Exploited	30117	2022-05-12	0
Air Miami	30118	2022-05-12	0
Barry Biggs	30119	2022-05-12	0
Mel Tillis	30120	2022-05-12	0
Erin O'Donnell	30121	2022-05-12	0
Remy Ma / Keyshia Cole	30122	2022-05-12	0
The Wolfe Tones	30123	2022-05-12	0
Hellsongs	30124	2022-05-12	0
Mohammad Reza Shajarian	30125	2022-05-12	0
Rebecka Törnqvist	30126	2022-05-12	0
Orchestre Poly-Rythmo de Cotonou	30127	2022-05-12	0
Aux 88	30128	2022-05-12	0
Bacio di Tosca	30129	2022-05-12	0
Jeffrey & Jack Lewis	30130	2022-05-12	0
Vicious Rumours	30131	2022-05-12	0
Carmen Rizzo	30132	2022-05-12	0
Chris Wall	30133	2022-05-12	0
Bernadette Lawrence	30134	2022-05-12	0
Maxi Priest	30135	2022-05-12	0
Don Grusin	30136	2022-05-12	0
Yuri Yunakov Ensemble	30137	2022-05-12	0
Metal Mike's Painmuseum	30138	2022-05-12	0
Back Off Cupids	30139	2022-05-12	0
The Frozen Autumn	30140	2022-05-12	0
Silent Jazz Ensemble	30141	2022-05-12	0
Sev Statik	30142	2022-05-12	0
Priscilla Renea	30143	2022-05-12	0
Treponem Pal	30144	2022-05-12	0
Studio 99 + Guests	30145	2022-05-12	0
Fudge Tunnel	30146	2022-05-12	0
Don Medardo y Sus Players	30147	2022-05-12	0
Musiq	30148	2022-05-12	0
mandala	30149	2022-05-12	0
Thaione Davis	30150	2022-05-12	0
Mux Mool	30151	2022-05-12	0
OC	30152	2022-05-12	0
Big Dipper	30153	2022-05-12	0
ARMS AND SLEEPERS	30154	2022-05-12	0
Marta Toro	30155	2022-05-12	0
Ralph Tresvant	30156	2022-05-12	0
Hot Chip	30157	2022-05-12	0
Lil Wayne / T-Pain	30158	2022-05-12	0
C & C Music Factory Feat. Freedom Williams	30159	2022-05-12	0
Hotel Persona	30160	2022-05-12	0
No Sports	30161	2022-05-12	0
Christos Fourkis	30162	2022-05-12	0
The Coral	30163	2022-05-12	0
Black Grass	30164	2022-05-12	0
9th Cloud	30165	2022-05-12	0
Robert Natus	30166	2022-05-12	0
Jahn Teigen	30167	2022-05-12	0
Asie Payton	30168	2022-05-12	0
Leslie Mandoki	30169	2022-05-12	0
Sharon Van Etten	30170	2022-05-12	0
The First Class	30171	2022-05-12	0
Oscar G	30172	2022-05-12	0
Krafty Kuts	30173	2022-05-12	0
Bobby Womack	30174	2022-05-12	0
Rammstein	30175	2022-05-12	0
Trance Generators	30176	2022-05-12	0
The Smashing Pumpkins	30177	2022-05-12	0
Imiskoubria featuring Fani Avramidou	30178	2022-05-12	0
Paquita La Del Barrio	30179	2022-05-12	0
Ruth Notman	30180	2022-05-12	0
Nick Moss & The Flip Tops	30181	2022-05-12	0
Todd Snider	30182	2022-05-12	0
Grand Puba	30183	2022-05-12	0
Carlo Siliotto	30184	2022-05-12	0
Girls Under Glass feat. Peter Spilles	30185	2022-05-12	0
New York Philharmonic;Leonard Bernstein;Isaac Stern	30186	2022-05-12	0
Mickie Krause	30187	2022-05-12	0
Michel Fugain	30188	2022-05-12	0
Mark Farina	30189	2022-05-12	0
Dottie Rambo/The Crabb Family	30190	2022-05-12	0
Caroline Loeb	30191	2022-05-12	0
The Henry Clay People	30192	2022-05-12	0
Charlie Robison	30193	2022-05-12	0
Michael Schenker	30194	2022-05-12	0
Lax Alex Contrax	30195	2022-05-12	0
Booka Shade	30196	2022-05-12	0
Spiritus Mortis	30197	2022-05-12	0
Rickie Lee Jones	30198	2022-05-12	0
Sleep Station	30199	2022-05-12	0
Gianmaria Testa	30200	2022-05-12	0
Oakhurst	30201	2022-05-12	0
Epic Hero	30202	2022-05-12	0
Hello Stranger	30203	2022-05-12	0
The Griswolds	30204	2022-05-12	0
Foster	30205	2022-05-12	0
Cubik & Origami	30206	2022-05-12	0
Melody Club	30207	2022-05-12	0
La Cosa Nostra	30208	2022-05-12	0
Juan Carmona	30209	2022-05-12	0
Steven Russell	30210	2022-05-12	0
King Diamond	30211	2022-05-12	0
1200 Micrograms	30212	2022-05-12	0
Dexter Freebish	30213	2022-05-12	0
Headliners	30214	2022-05-12	0
Weinland	30215	2022-05-12	0
Jeanie C. Riley	30216	2022-05-12	0
Jonah33	30217	2022-05-12	0
Fabio XB	30218	2022-05-12	0
Jango	30219	2022-05-12	0
Psi vojaci	30220	2022-05-12	0
Erin McCarley	30221	2022-05-12	0
JLS	30222	2022-05-12	0
Dean Martin	30223	2022-05-12	0
Saafir	30224	2022-05-12	0
The Mayflies USA	30225	2022-05-12	0
Bill Black's Combo	30226	2022-05-12	0
Butt Trumpet	30227	2022-05-12	0
Juan Varea	30228	2022-05-12	0
Hapshash & The Coloured Coat	30229	2022-05-12	0
Christian Lais	30230	2022-05-12	0
Helen Love	30231	2022-05-12	0
Jungle Brothers	30232	2022-05-12	0
Wilma Lee Cooper	30233	2022-05-12	0
Malefaction	30234	2022-05-12	0
Dream Traveler	30235	2022-05-12	0
Great Northern	30236	2022-05-12	0
Nini Camps	30237	2022-05-12	0
Sascha Funke	30238	2022-05-12	0
Bounty Killer	30239	2022-05-12	0
Run Level Zero	30240	2022-05-12	0
Böhse Onkelz	30241	2022-05-12	0
Lino Borges	30242	2022-05-12	0
Louk & Joe-E	30243	2022-05-12	0
Bullet Lavolta	30244	2022-05-12	0
Slim Dusty	30245	2022-05-12	0
The Helio Sequence	30246	2022-05-12	0
Ice	30247	2022-05-12	0
Lee Ranaldo_ William Hooker_ Jim O' Rourke_ Gianni Gebbia	30248	2022-05-12	0
Ella Fitzgerald / Oscar Peterson	30249	2022-05-12	0
Pantanito	30250	2022-05-12	0
Beep Beep	30251	2022-05-12	0
Indira Radic	30252	2022-05-12	0
Wolfgang Amadeus Mozart	30253	2022-05-12	0
The Emotions	30254	2022-05-12	0
AMO	30255	2022-05-12	0
Crazy Girl	30256	2022-05-12	0
Tha Dogg Pound featuring Foxy Brown	30257	2022-05-12	0
Broder Daniel	30258	2022-05-12	0
Sugar Ray	30259	2022-05-12	0
Lalleshwari (Katie Jane Garside)	30260	2022-05-12	0
LEE 'SCRATCH' PERRY & THE DUB SYNDICATE	30261	2022-05-12	0
TTC	30262	2022-05-12	0
Revolution United	30263	2022-05-12	0
I'm From Barcelona	30264	2022-05-12	0
Cargo	30265	2022-05-12	0
Tommy Dorsey	30266	2022-05-12	0
Marvin Hamlisch_ Alan Bergman_ Marilyn Bergman	30267	2022-05-12	0
Sass Jordan	30268	2022-05-12	0
Whitesnake	30269	2022-05-12	0
Taylor Hawkins & The Coattail Riders	30270	2022-05-12	0
Monoroom	30271	2022-05-12	0
Shakura S'Aida	30272	2022-05-12	0
Stroke 9	30273	2022-05-12	0
Robin Guthrie and Harold Budd	30274	2022-05-12	0
The Last Days Of Jesus	30275	2022-05-12	0
Dobby Dobson	30276	2022-05-12	0
Willie Heath Neal	30277	2022-05-12	0
Ossian	30278	2022-05-12	0
Nicolay	30279	2022-05-12	0
Meaghan Smith	30280	2022-05-12	0
Les Anges de la Nuit	30281	2022-05-12	0
Keith Washington	30282	2022-05-12	0
Cariña	30283	2022-05-12	0
Roberta Flack and Peabo Bryson	30284	2022-05-12	0
Reuben Wilson	30285	2022-05-12	0
Box Car Racer	30286	2022-05-12	0
Moral Decay	30287	2022-05-12	0
James P. Johnson	30288	2022-05-12	0
Zukanican	30289	2022-05-12	0
Fulanito	30290	2022-05-12	0
The Seed	30291	2022-05-12	0
Hevia	30292	2022-05-12	0
Atria	30293	2022-05-12	0
Vitor Hublot	30294	2022-05-12	0
Dinu Lipatti/Concertgebouworkest/Eduard van Beinum	30295	2022-05-12	0
Monday Michiru	30296	2022-05-12	0
Radioactive Man	30297	2022-05-12	0
MJ Cole featuring Digga	30298	2022-05-12	0
Randy Friess	30299	2022-05-12	0
Trisha Yearwood	30300	2022-05-12	0
Helen Baylor	30301	2022-05-12	0
Lach	30302	2022-05-12	0
Nicolai Dunger	30303	2022-05-12	0
Janie Fricke	30304	2022-05-12	0
Jamal	30305	2022-05-12	0
Newcleus	30306	2022-05-12	0
Michael Palmer	30307	2022-05-12	0
The Charles Mingus Group	30308	2022-05-12	0
Patti Scialfa	30309	2022-05-12	0
Jack Johnson	30310	2022-05-12	0
Celtic Frost	30311	2022-05-12	0
Sadao Watanabe	30312	2022-05-12	0
Marcus Schössow	30313	2022-05-12	0
Norman Palm	30314	2022-05-12	0
Averse Sefira	30315	2022-05-12	0
Luke Doucet	30316	2022-05-12	0
Sarissa	30317	2022-05-12	0
Gavin DeGraw	30318	2022-05-12	0
Helvetic Nerds	30319	2022-05-12	0
Willie Isz	30320	2022-05-12	0
Covenant	30321	2022-05-12	0
The Mello-Kings	30322	2022-05-12	0
Hector Zazou	30323	2022-05-12	0
Whizz For Atoms	30324	2022-05-12	0
Erick Sermon	30325	2022-05-12	0
Lory Bianco	30326	2022-05-12	0
23 Skidoo	30327	2022-05-12	0
Roots Radics	30328	2022-05-12	0
Mad Professor & Lee Perry	30329	2022-05-12	0
Defecation	30330	2022-05-12	0
Speech Defect	30331	2022-05-12	0
Diego	30332	2022-05-12	0
Duster Bennett	30333	2022-05-12	0
The Cult	30334	2022-05-12	0
Stillste Stund	30335	2022-05-12	0
House of Freaks	30336	2022-05-12	0
Ibrahim Ferrer	30337	2022-05-12	0
Illuminate	30338	2022-05-12	0
Lucky Boys Confusion	30339	2022-05-12	0
Sarandon	30340	2022-05-12	0
Spacekees Feat. Hairo	30341	2022-05-12	0
Leonid Rudenko	30342	2022-05-12	0
The Zico Chain	30343	2022-05-12	0
Queensryche	30344	2022-05-12	0
Denis The Menace	30345	2022-05-12	0
Mark Mothersbaugh	30346	2022-05-12	0
Gilli Moon	30347	2022-05-12	0
Quinn Lemley	30348	2022-05-12	0
Den Stora Sömnen	30349	2022-05-12	0
Gordon Haskell	30350	2022-05-12	0
Bob Carlisle	30351	2022-05-12	0
Memphis Slim	30352	2022-05-12	0
Ben Granfelt Band	30353	2022-05-12	0
Interference	30354	2022-05-12	0
New Funky Generation	30355	2022-05-12	0
Justin Hinds	30356	2022-05-12	0
Brand X	30357	2022-05-12	0
Nuclear Valdez	30358	2022-05-12	0
Bill Wyman's Rhythm Kings	30359	2022-05-12	0
Benabar	30360	2022-05-12	0
Ghostface Killah	30361	2022-05-12	0
Frank Sinatra;Tommy Dorsey	30362	2022-05-12	0
Jil Is Lucky	30363	2022-05-12	0
Aaliyah	30364	2022-05-12	0
Levon Helm	30365	2022-05-12	0
Daryl Williams Trio	30366	2022-05-12	0
Der Moderne Man	30367	2022-05-12	0
Time Requiem	30368	2022-05-12	0
Tim Deluxe	30369	2022-05-12	0
The Hiss	30370	2022-05-12	0
Public Relations Exercise	30371	2022-05-12	0
Vibrasphere	30372	2022-05-12	0
Moonbound	30373	2022-05-12	0
Ame Caleen	30374	2022-05-12	0
Aimee Mann	30375	2022-05-12	0
LaFee	30376	2022-05-12	0
Magma	30377	2022-05-12	0
Stevie Ray Vaughan	30378	2022-05-12	0
Random	30379	2022-05-12	0
K.I.Z.	30380	2022-05-12	0
Son By 4	30381	2022-05-12	0
Greg Graffin	30382	2022-05-12	0
Glass Ghost	30383	2022-05-12	0
The World-Band	30384	2022-05-12	0
The Vampires Of Dartmoore	30385	2022-05-12	0
The Apex Theory	30386	2022-05-12	0
Hole	30387	2022-05-12	0
Zacarias Ferreíra	30388	2022-05-12	0
Hot Club De Paris	30389	2022-05-12	0
Alex Neri	30390	2022-05-12	0
Culture Shock	30391	2022-05-12	0
Ky-Mani Marley	30392	2022-05-12	0
Zodiac Cartel	30393	2022-05-12	0
Mural	30394	2022-05-12	0
Mike Watt	30395	2022-05-12	0
Oleta Adams	30396	2022-05-12	0
Dino Meira	30397	2022-05-12	0
J Bigga	30398	2022-05-12	0
Darryl D'Bonneau	30399	2022-05-12	0
Doyle Lawson & Quicksilver	30400	2022-05-12	0
17 Hippies	30401	2022-05-12	0
Yusuf Azad	30402	2022-05-12	0
32 Leaves	30403	2022-05-12	0
Copywrite	30404	2022-05-12	0
Penance	30405	2022-05-12	0
Mary J. Blige	30406	2022-05-12	0
Erykah Badu	30407	2022-05-12	0
Sandra	30408	2022-05-12	0
Theuns Jordaan	30409	2022-05-12	0
Relaxed Muscle	30410	2022-05-12	0
Freaky Age	30411	2022-05-12	0
Zeigeist	30412	2022-05-12	0
Kate Miller-Heidke	30413	2022-05-12	0
Sparky Lightbourne	30414	2022-05-12	0
Raul Mezcolanza & Gaspar T	30415	2022-05-12	0
O'so Krispie	30416	2022-05-12	0
Laidback Luke & Diplo	30417	2022-05-12	0
Rework	30418	2022-05-12	0
Outerspace	30419	2022-05-12	0
Lotta Engberg	30420	2022-05-12	0
Gary D.	30421	2022-05-12	0
Jupiter Sunrise	30422	2022-05-12	0
Jermaine Dupri featuring Usher_ Boo & Gotti and R.O.C	30423	2022-05-12	0
Alain Leprest_ François Lemonnier	30424	2022-05-12	0
Teresa Brewer	30425	2022-05-12	0
Dizzy Mizz Lizzy	30426	2022-05-12	0
Steve Erquiaga	30427	2022-05-12	0
Bomb Squad	30428	2022-05-12	0
Ken Doh/ Kings Of Tomorrow	30429	2022-05-12	0
Jorge Oñate;Chiche Martinez	30430	2022-05-12	0
The Sleeping Years	30431	2022-05-12	0
Archie Lee	30432	2022-05-12	0
Edward Martin and Paul Berget	30433	2022-05-12	0
Indica	30434	2022-05-12	0
Campbell_ Cornell	30435	2022-05-12	0
Klaus Doldinger's Passport	30436	2022-05-12	0
Transmutator	30437	2022-05-12	0
Chris Squire	30438	2022-05-12	0
Depth Affect	30439	2022-05-12	0
Frank Zander	30440	2022-05-12	0
Kudu	30441	2022-05-12	0
Sanctus Real	30442	2022-05-12	0
Cobra	30443	2022-05-12	0
Across the Border	30444	2022-05-12	0
Tommy Ridgley	30445	2022-05-12	0
Hazmat Modine	30446	2022-05-12	0
Benjamin Biolay - Chiara Mastroianni	30447	2022-05-12	0
Nicolay & Kay	30448	2022-05-12	0
Jimmy Bowskill	30449	2022-05-12	0
Sir Charles Jones	30450	2022-05-12	0
Roger Reynolds	30451	2022-05-12	0
Scary Bitches	30452	2022-05-12	0
The Curtains	30453	2022-05-12	0
Tower Recordings	30454	2022-05-12	0
The Phantom Band	30455	2022-05-12	0
New Bomb Turks	30456	2022-05-12	0
Metal Mareny	30457	2022-05-12	0
DJ Shah	30458	2022-05-12	0
Slapstick_ Frederic De Carvalho	30459	2022-05-12	0
Late Night Sneaky	30460	2022-05-12	0
Betty Everett & Jerry Butler	30461	2022-05-12	0
Barbara Higbie	30462	2022-05-12	0
AnnaGrace	30463	2022-05-12	0
Tonight Is Glory	30464	2022-05-12	0
Lt. Stitchie	30465	2022-05-12	0
Michelle Weeks / Tichina Arnold / Tisha Campbell / Bill Mitchell	30466	2022-05-12	0
Eko Fresh feat. G-Style	30467	2022-05-12	0
Bal-a-klah-va	30468	2022-05-12	0
Man Alive	30469	2022-05-12	0
Naughty Naughty	30470	2022-05-12	0
Kamchatka	30471	2022-05-12	0
The Rezillos	30472	2022-05-12	0
DXT	30473	2022-05-12	0
Bryan Jones	30474	2022-05-12	0
D'espairsRay	30475	2022-05-12	0
Minnie Driver	30476	2022-05-12	0
Cold World Hustlers	30477	2022-05-12	0
Omar Cunningham	30478	2022-05-12	0
Beat Dominator	30479	2022-05-12	0
Marlon	30480	2022-05-12	0
Earth_ Wind And Fire	30481	2022-05-12	0
Sandy & Junior	30482	2022-05-12	0
Telepath	30483	2022-05-12	0
Knives Exchanging Hands	30484	2022-05-12	0
Ressu Redford	30485	2022-05-12	0
MC Breed & DFC	30486	2022-05-12	0
Dimension F3H	30487	2022-05-12	0
Vaya Con Dios	30488	2022-05-12	0
Kokolo	30489	2022-05-12	0
George Howard	30490	2022-05-12	0
Spleen United	30491	2022-05-12	0
Yami Bolo	30492	2022-05-12	0
Papercuts	30493	2022-05-12	0
Agent Alvin	30494	2022-05-12	0
Tweet	30495	2022-05-12	0
Lee Ritenour	30496	2022-05-12	0
Stephen Lynch	30497	2022-05-12	0
Patato Valdes_ G. Hidalgo_ Luis Frank_ Pío Leiva_ Chiki	30498	2022-05-12	0
Mathias Schaffhäuser	30499	2022-05-12	0
Ed Case;Elisabeth Troy	30500	2022-05-12	0
Fiona Gélin	30501	2022-05-12	0
Kalilaskov AS	30502	2022-05-12	0
Timbaland / Katy Perry	30503	2022-05-12	0
Brooks & Dunn	30504	2022-05-12	0
Hot Water Music	30505	2022-05-12	0
Roger	30506	2022-05-12	0
Merauder	30507	2022-05-12	0
Al Kapone	30508	2022-05-12	0
MYSTIC PROPHECY	30509	2022-05-12	0
Patty Pravo	30510	2022-05-12	0
Christian Prommer	30511	2022-05-12	0
Rainie Yang	30512	2022-05-12	0
Skint & Demoralised	30513	2022-05-12	0
Dada Life	30514	2022-05-12	0
Cecil Taylor	30515	2022-05-12	0
Joby Talbot	30516	2022-05-12	0
Ira Stein	30517	2022-05-12	0
Ashley Wallbridge	30518	2022-05-12	0
Rain Parade	30519	2022-05-12	0
Baby Dee	30520	2022-05-12	0
Johnnie Ray	30521	2022-05-12	0
Ash	30522	2022-05-12	0
Tonedeff	30523	2022-05-12	0
The Bamboos	30524	2022-05-12	0
Expatriate	30525	2022-05-12	0
Bløf	30526	2022-05-12	0
Buffy Sainte-Marie	30527	2022-05-12	0
Ginjah	30528	2022-05-12	0
Los Salvajes	30529	2022-05-12	0
Mary Wells	30530	2022-05-12	0
Carlos Varela	30531	2022-05-12	0
Minipop	30532	2022-05-12	0
Calvin Richardson	30533	2022-05-12	0
Angra Mainyu featuring Di	30534	2022-05-12	0
Dala	30535	2022-05-12	0
Michael Marcus	30536	2022-05-12	0
Zeca Baleiro	30537	2022-05-12	0
Silver	30538	2022-05-12	0
Annett Louisan	30539	2022-05-12	0
Lil Scrappy	30540	2022-05-12	0
Lucky Dragons	30541	2022-05-12	0
Former Fat Boys	30542	2022-05-12	0
Los Bravos	30543	2022-05-12	0
Iration	30544	2022-05-12	0
Saxon Shore	30545	2022-05-12	0
Amr Diab	30546	2022-05-12	0
Beach House	30547	2022-05-12	0
João Portugal	30548	2022-05-12	0
Alpa Gun	30549	2022-05-12	0
Charmers	30550	2022-05-12	0
Mossy	30551	2022-05-12	0
Hell On Wheels	30552	2022-05-12	0
Eight Legs	30553	2022-05-12	0
Esthero	30554	2022-05-12	0
Headscan	30555	2022-05-12	0
September When	30556	2022-05-12	0
English Chamber Orchestra	30557	2022-05-12	0
Re-Flex	30558	2022-05-12	0
Ian Novak	30559	2022-05-12	0
Brian Kennedy	30560	2022-05-12	0
San Serac	30561	2022-05-12	0
Barbara Cook	30562	2022-05-12	0
Mousse T. feat. Emma Lanford	30563	2022-05-12	0
Jake the Flake	30564	2022-05-12	0
Tenfold Loadstar	30565	2022-05-12	0
Jeff Beck	30566	2022-05-12	0
Al K-Pote	30567	2022-05-12	0
Ym-Stammen	30568	2022-05-12	0
J. Holiday featuring Rick Ross	30569	2022-05-12	0
The B-Sides	30570	2022-05-12	0
The Wonder Stuff	30571	2022-05-12	0
Dirty on Purpose	30572	2022-05-12	0
The 5th Dimension	30573	2022-05-12	0
Teen Idols	30574	2022-05-12	0
Roy Acuff	30575	2022-05-12	0
Lisa Papineau	30576	2022-05-12	0
Johnny Prez	30577	2022-05-12	0
D:Fuse & Hiratzka featuring Kristy Thirsk	30578	2022-05-12	0
Khymera	30579	2022-05-12	0
Andrew Jackson Jihad	30580	2022-05-12	0
Fast Times	30581	2022-05-12	0
Bob Dylan	30582	2022-05-12	0
Groucho Marx	30583	2022-05-12	0
Shotu	30584	2022-05-12	0
B12	30585	2022-05-12	0
Nekromantix	30586	2022-05-12	0
Wade Hayes	30587	2022-05-12	0
Lucerito	30588	2022-05-12	0
Robert Wyatt	30589	2022-05-12	0
The Smooths	30590	2022-05-12	0
David Lee Garza Y Los Musicales	30591	2022-05-12	0
Ian Hunter	30592	2022-05-12	0
Rancid Vat	30593	2022-05-12	0
The dB's	30594	2022-05-12	0
Earl Robinson	30595	2022-05-12	0
Familjen	30596	2022-05-12	0
Mickey And The Students	30597	2022-05-12	0
Asteroid featuring DJ Mike Strip	30598	2022-05-12	0
Tokyo Dragons	30599	2022-05-12	0
The Creatures	30600	2022-05-12	0
Equilibrium	30601	2022-05-12	0
Johan Ekman	30602	2022-05-12	0
The Dreamside	30603	2022-05-12	0
Stemage	30604	2022-05-12	0
Aretha Franklin with the Ray Bryant Combo	30605	2022-05-12	0
Karen Young	30606	2022-05-12	0
Vivian Khor	30607	2022-05-12	0
Mischa Maisky/Sergio Tiempo	30608	2022-05-12	0
Hellnation	30609	2022-05-12	0
Rachel Portman	30610	2022-05-12	0
Streetlife Djs	30611	2022-05-12	0
Valérie Leulliot	30612	2022-05-12	0
Miss Kittin & The Hacker	30613	2022-05-12	0
Night Ranger	30614	2022-05-12	0
Gerhard Schöne	30615	2022-05-12	0
Planeta Imaginario	30616	2022-05-12	0
Evil Mothers	30617	2022-05-12	0
R. Stevie Moore	30618	2022-05-12	0
Elzyo Silver	30619	2022-05-12	0
Peter Brown	30620	2022-05-12	0
Charles Davis	30621	2022-05-12	0
A Grave With No Name	30622	2022-05-12	0
Pete And The Pirates	30623	2022-05-12	0
Jaime Jamgochian	30624	2022-05-12	0
Vinkenoog_ Spinvis Combo	30625	2022-05-12	0
Samim & Michal	30626	2022-05-12	0
Eric Coates	30627	2022-05-12	0
Chevron	30628	2022-05-12	0
Clara Nunes	30629	2022-05-12	0
Choro Ensemble	30630	2022-05-12	0
Manfred Mann	30631	2022-05-12	0
Lost Edit	30632	2022-05-12	0
Procs	30633	2022-05-12	0
Paul Cardall	30634	2022-05-12	0
Exercise One	30635	2022-05-12	0
Robert Palmer	30636	2022-05-12	0
John P. Kee & The New Life Community Choir	30637	2022-05-12	0
King Changó	30638	2022-05-12	0
Bio Muse	30639	2022-05-12	0
Half Man Half Biscuit	30640	2022-05-12	0
Ryuichi Sakamoto	30641	2022-05-12	0
Doug Stanhope	30642	2022-05-12	0
Casino Express	30643	2022-05-12	0
Lord Jamar	30644	2022-05-12	0
Eva Dahlgren	30645	2022-05-12	0
Sá & Guarabyra	30646	2022-05-12	0
Bridget St John	30647	2022-05-12	0
Tata Box Inhibitors	30648	2022-05-12	0
Glassjaw	30649	2022-05-12	0
sergey kuryokhin	30650	2022-05-12	0
Hezekiah Walker & LFC	30651	2022-05-12	0
Nostalgia 77	30652	2022-05-12	0
Dr. Calypso	30653	2022-05-12	0
Elias Viljanen feat. Tony Kakko	30654	2022-05-12	0
The Bedwetters	30655	2022-05-12	0
Gianluca Motta / Molly	30656	2022-05-12	0
Black Oak Arkansas	30657	2022-05-12	0
Heavy Blues Chevy	30658	2022-05-12	0
The Scientists	30659	2022-05-12	0
O.S.I	30660	2022-05-12	0
The Guild League	30661	2022-05-12	0
Abstürzende Brieftauben	30662	2022-05-12	0
Dave Weckl	30663	2022-05-12	0
Paul Blackford	30664	2022-05-12	0
Holly Golightly & The Brokeoffs	30665	2022-05-12	0
Band Of Horses	30666	2022-05-12	0
Edda Moser/Münchner Konzertchor/Münchner Rundfunkorchester/Willi Boskovsky	30667	2022-05-12	0
Peter Gelderblom	30668	2022-05-12	0
Claudia Church	30669	2022-05-12	0
John Proulx	30670	2022-05-12	0
Steve Davis_ Roy Hargrove_ Peter Bernstein_ Anthony Wonsey_ Nat Reeves_ Joe Farnsworth	30671	2022-05-12	0
Tina Britt	30672	2022-05-12	0
The Lawrence Arms	30673	2022-05-12	0
Powderfinger	30674	2022-05-12	0
The Reasoning	30675	2022-05-12	0
The Wake	30676	2022-05-12	0
Sally Yeh	30677	2022-05-12	0
Geri X	30678	2022-05-12	0
Betzefer	30679	2022-05-12	0
I.L.L.	30680	2022-05-12	0
Tankcsapda	30681	2022-05-12	0
Paul Woolford Presents Bobby Peru	30682	2022-05-12	0
KathrynWilliams	30683	2022-05-12	0
The Verlaines	30684	2022-05-12	0
Cobra Starship	30685	2022-05-12	0
AP9	30686	2022-05-12	0
Joe E	30687	2022-05-12	0
Savoy	30688	2022-05-12	0
Brent Dowe	30689	2022-05-12	0
Daleka Obala	30690	2022-05-12	0
Flatt And Scruggs	30691	2022-05-12	0
Room 5 Featuring Oliver Cheatham	30692	2022-05-12	0
Wayne Gratz	30693	2022-05-12	0
Skoud	30694	2022-05-12	0
Hollywood Studio Orchestra	30695	2022-05-12	0
Sex Pistols	30696	2022-05-12	0
Tindersticks	30697	2022-05-12	0
The Soviettes	30698	2022-05-12	0
Jack Dangers	30699	2022-05-12	0
Sharon Jones & The Dap-Kings	30700	2022-05-12	0
Mexicanto	30701	2022-05-12	0
Silverblue	30702	2022-05-12	0
1090 Club	30703	2022-05-12	0
Cdatakill	30704	2022-05-12	0
Maggotron featuring Palmer Force II	30705	2022-05-12	0
Hypnotic Brass Ensemble	30706	2022-05-12	0
Felipe Cazaux	30707	2022-05-12	0
Little Johnny Taylor	30708	2022-05-12	0
Tanika Turner	30709	2022-05-12	0
Arturo Sandoval	30710	2022-05-12	0
The Flesh Eaters	30711	2022-05-12	0
L Kan	30712	2022-05-12	0
Skwatta kamp	30713	2022-05-12	0
Neri Per Caso	30714	2022-05-12	0
Armando Hernandez Y Su Conjunto	30715	2022-05-12	0
Andy Starr	30716	2022-05-12	0
Bebo & Cigala	30717	2022-05-12	0
Mason Jennings	30718	2022-05-12	0
CKY	30719	2022-05-12	0
Phil Collins	30720	2022-05-12	0
Grant Geissman_ Russell Ferrante	30721	2022-05-12	0
Statues	30722	2022-05-12	0
Juelz Santana / Cam'Ron	30723	2022-05-12	0
Lou Donaldson	30724	2022-05-12	0
Disturbed	30725	2022-05-12	0
Cas Metah	30726	2022-05-12	0
My Bloody Valentine	30727	2022-05-12	0
Casual featuring Pep Love and Del Tha Funkee Homosapien	30728	2022-05-12	0
Solis	30729	2022-05-12	0
Brotherhood Of Man	30730	2022-05-12	0
Emanuele Inglese	30731	2022-05-12	0
Delmore brothers	30732	2022-05-12	0
The Feminists	30733	2022-05-12	0
Delicious	30734	2022-05-12	0
Cipher	30735	2022-05-12	0
Ernst Rolf	30736	2022-05-12	0
Robert Tepper	30737	2022-05-12	0
The Five Blind Boys Of Alabama	30738	2022-05-12	0
Paulini	30739	2022-05-12	0
Hood	30740	2022-05-12	0
Space DJs	30741	2022-05-12	0
Akil	30742	2022-05-12	0
Marc Anthony	30743	2022-05-12	0
Little Tragedies	30744	2022-05-12	0
The Card  - 1994 London Cast	30745	2022-05-12	0
Bullet	30746	2022-05-12	0
Snoop Dogg / Slick Rick	30747	2022-05-12	0
Sebastian Deyle	30748	2022-05-12	0
Narvel Felts	30749	2022-05-12	0
Dopamine	30750	2022-05-12	0
Mystic Rhythms	30751	2022-05-12	0
Franco_ Valeriana	30752	2022-05-12	0
Enzo Avitabile	30753	2022-05-12	0
Jags	30754	2022-05-12	0
Mazi featuring Colette	30755	2022-05-12	0
Beverlei Brown	30756	2022-05-12	0
Clancy Brothers & Tommy Makem	30757	2022-05-12	0
Frankie Negron	30758	2022-05-12	0
Mari Trini	30759	2022-05-12	0
Jumbo	30760	2022-05-12	0
Wig Wam	30761	2022-05-12	0
STL	30762	2022-05-12	0
Black Ivory	30763	2022-05-12	0
The Sons Of The West	30764	2022-05-12	0
Philip Sayce	30765	2022-05-12	0
Maxwell Implosion	30766	2022-05-12	0
Atnarko Bear	30767	2022-05-12	0
The Jazz Crusaders	30768	2022-05-12	0
Jacques Loussier Trio	30769	2022-05-12	0
Francis Dhomont	30770	2022-05-12	0
Midwest Product	30771	2022-05-12	0
Shinehead	30772	2022-05-12	0
Opee	30773	2022-05-12	0
Jarabe De Palo	30774	2022-05-12	0
Tad	30775	2022-05-12	0
Joyo Velarde	30776	2022-05-12	0
the feelers	30777	2022-05-12	0
Lale Andersen	30778	2022-05-12	0
Royal Liverpool Philharmonic Orchestra/Barry Wordsworth	30779	2022-05-12	0
Luisito Rosario	30780	2022-05-12	0
Al Campbell	30781	2022-05-12	0
Jaheim Featuring Jadakiss	30782	2022-05-12	0
Wasabi	30783	2022-05-12	0
N.O.R.E. / Mashonda	30784	2022-05-12	0
Ruben	30785	2022-05-12	0
Birdman & Lil Wayne / Fat Joe	30786	2022-05-12	0
Nubla	30787	2022-05-12	0
R.E.M.	30788	2022-05-12	0
Alex Riel	30789	2022-05-12	0
Dallas Moore	30790	2022-05-12	0
Big John Greer	30791	2022-05-12	0
Megatrend	30792	2022-05-12	0
The Sugarcubes	30793	2022-05-12	0
Gojira	30794	2022-05-12	0
DJ Clue / DMX	30795	2022-05-12	0
Herbert  von Karajan	30796	2022-05-12	0
immanu el	30797	2022-05-12	0
Aristocats	30798	2022-05-12	0
Wayne Marshall/Ole Edvard Antonsen	30799	2022-05-12	0
The Swingle Singers	30800	2022-05-12	0
Queensrÿche	30801	2022-05-12	0
Steeleye Span	30802	2022-05-12	0
Lee Ritenour / Alex Acuña	30803	2022-05-12	0
Vyolet	30804	2022-05-12	0
Rodney O_ Joe Cooley	30805	2022-05-12	0
The Skillet-Lickers	30806	2022-05-12	0
Helios Creed	30807	2022-05-12	0
The Terrorist	30808	2022-05-12	0
Albert Hammond	30809	2022-05-12	0
Nyboma	30810	2022-05-12	0
Sunspot Jonz feat. Living legends	30811	2022-05-12	0
Jim Ed Brown	30812	2022-05-12	0
Yann Tiersen	30813	2022-05-12	0
Sharpay	30814	2022-05-12	0
Jorge Velosa	30815	2022-05-12	0
13th Chime	30816	2022-05-12	0
Doomtree	30817	2022-05-12	0
Shae Fiol	30818	2022-05-12	0
The New Cactus Band	30819	2022-05-12	0
Peeping Tom	30820	2022-05-12	0
Soul Coughing	30821	2022-05-12	0
Xmilk	30822	2022-05-12	0
No Turning Back	30823	2022-05-12	0
The Boomtown Rats	30824	2022-05-12	0
Lackluster	30825	2022-05-12	0
The Quireboys	30826	2022-05-12	0
Sharon Shannon	30827	2022-05-12	0
Deems	30828	2022-05-12	0
Grand Funk Railroad	30829	2022-05-12	0
Christer Sandelin	30830	2022-05-12	0
Hora Zulu	30831	2022-05-12	0
Scram C Baby	30832	2022-05-12	0
Boy Crisis	30833	2022-05-12	0
The Velvet Underground / Lou Reed	30834	2022-05-12	0
Starsailor	30835	2022-05-12	0
Bonita & Jerry Cormier	30836	2022-05-12	0
Make Model	30837	2022-05-12	0
Dio	30838	2022-05-12	0
Neil Landstrumm	30839	2022-05-12	0
The Turbo A.C.'s	30840	2022-05-12	0
Benga	30841	2022-05-12	0
Manafest	30842	2022-05-12	0
Patrick Lamb	30843	2022-05-12	0
Bluff City Backsliders	30844	2022-05-12	0
Greenbeam & Leon	30845	2022-05-12	0
Jean-Jacques Milteau / Gil Scott-Heron	30846	2022-05-12	0
Patti LaBelle	30847	2022-05-12	0
Jump5	30848	2022-05-12	0
Beniamino Gigli	30849	2022-05-12	0
Thunderball	30850	2022-05-12	0
Marto	30851	2022-05-12	0
Indochine	30852	2022-05-12	0
God Lives Underwater	30853	2022-05-12	0
ATFC Feat. Lisa Millett	30854	2022-05-12	0
Rufus Wainwright	30855	2022-05-12	0
Stijn	30856	2022-05-12	0
Patent Pending	30857	2022-05-12	0
Priestess	30858	2022-05-12	0
One Way System	30859	2022-05-12	0
Dirtball	30860	2022-05-12	0
Girlboy Girl	30861	2022-05-12	0
Krzysztof Komeda	30862	2022-05-12	0
La Húngara - Jorge González	30863	2022-05-12	0
Fever	30864	2022-05-12	0
Clarence Carter	30865	2022-05-12	0
Pacific Gas & Electric	30866	2022-05-12	0
Lady Gaga / Marilyn Manson	30867	2022-05-12	0
Flamin' Groovies	30868	2022-05-12	0
Mundo Complexo	30869	2022-05-12	0
1000 Clowns	30870	2022-05-12	0
The Horn	30871	2022-05-12	0
Goteki	30872	2022-05-12	0
Back Door Slam	30873	2022-05-12	0
With Chaos in Her Wake	30874	2022-05-12	0
Her Space Holiday	30875	2022-05-12	0
Monday 2 Friday	30876	2022-05-12	0
The Aislers Set	30877	2022-05-12	0
Grand Island	30878	2022-05-12	0
The Shapeshifters & Chic	30879	2022-05-12	0
Patrizio Buanne	30880	2022-05-12	0
Ivan Parker/Joy Gardner	30881	2022-05-12	0
Peter and the Test Tube Babies	30882	2022-05-12	0
Carla Lavern	30883	2022-05-12	0
The Now Time Delegation	30884	2022-05-12	0
Decapitated	30885	2022-05-12	0
Blacktop	30886	2022-05-12	0
Novembre	30887	2022-05-12	0
Doris Day	30888	2022-05-12	0
Half Pint	30889	2022-05-12	0
Stig	30890	2022-05-12	0
Nat King Cole Trio	30891	2022-05-12	0
The Cinematic Orchestra	30892	2022-05-12	0
Ratones Paranoicos	30893	2022-05-12	0
The Benjamin Gate	30894	2022-05-12	0
Bobby Womack / Wilton Felder	30895	2022-05-12	0
honeyhoney	30896	2022-05-12	0
Mike Knott	30897	2022-05-12	0
Kate Wolf	30898	2022-05-12	0
The Eighties Matchbox B-Line Disaster	30899	2022-05-12	0
Franco Battiato	30900	2022-05-12	0
Simbu	30901	2022-05-12	0
Nosoträsh	30902	2022-05-12	0
The Psychotik Tanks	30903	2022-05-12	0
Herois de la Katalunya Interior	30904	2022-05-12	0
Yolanda Del Rio;Mariachi Vargas De Tecalitlan	30905	2022-05-12	0
Iron Butterfly	30906	2022-05-12	0
Conjure One	30907	2022-05-12	0
Ruth Jacott	30908	2022-05-12	0
Joy Kitikonti	30909	2022-05-12	0
Soul Shaker	30910	2022-05-12	0
Sam Beeton	30911	2022-05-12	0
Jedi Mind Tricks Presents: Army Of The Pharaohs	30912	2022-05-12	0
The Charles River Valley Boys	30913	2022-05-12	0
Turdus Musicus	30914	2022-05-12	0
The Prairie Cartel	30915	2022-05-12	0
Tim Berg	30916	2022-05-12	0
Unter Null	30917	2022-05-12	0
King Midas	30918	2022-05-12	0
Phish	30919	2022-05-12	0
Patty Larkin	30920	2022-05-12	0
Maurice Chevalier	30921	2022-05-12	0
Unladylike	30922	2022-05-12	0
The Replacements	30923	2022-05-12	0
Cary Hudson	30924	2022-05-12	0
Iron Lung Corp	30925	2022-05-12	0
Virgil Moorefield	30926	2022-05-12	0
Camila	30927	2022-05-12	0
Accept	30928	2022-05-12	0
Sheena Easton	30929	2022-05-12	0
The Mighty Lemon Drops	30930	2022-05-12	0
Djaimin feat. Crystal Re-Clear	30931	2022-05-12	0
H-Bomb Ferguson & Andy Kirk Orchestra	30932	2022-05-12	0
City of Prague Philharmonic / Bateman	30933	2022-05-12	0
707	30934	2022-05-12	0
Mark Bishop	30935	2022-05-12	0
Slush The Villian	30936	2022-05-12	0
Didier Lockwood	30937	2022-05-12	0
Harmonic 313	30938	2022-05-12	0
Third Eye Blind	30939	2022-05-12	0
Estela Nuñez	30940	2022-05-12	0
Luke Shipstad	30941	2022-05-12	0
Dopeman	30942	2022-05-12	0
John Brown's Body	30943	2022-05-12	0
The Aztext	30944	2022-05-12	0
Ben Sidran	30945	2022-05-12	0
Swedish Erotica	30946	2022-05-12	0
The Shortwave Set	30947	2022-05-12	0
Stockholm Monsters	30948	2022-05-12	0
Acroma	30949	2022-05-12	0
Payami feat. Lazee	30950	2022-05-12	0
The Glencastle Sound	30951	2022-05-12	0
Deadmau5	30952	2022-05-12	0
Jennifer Hudson	30953	2022-05-12	0
Prozzak	30954	2022-05-12	0
David calzado y su Charanga Habanera	30955	2022-05-12	0
Eugene McGuinness	30956	2022-05-12	0
Karine Polwart	30957	2022-05-12	0
Candyman	30958	2022-05-12	0
Swan Silvertones	30959	2022-05-12	0
The Four Of Us	30960	2022-05-12	0
Kleenex	30961	2022-05-12	0
Faron Young	30962	2022-05-12	0
Yung Joc	30963	2022-05-12	0
Kaleidoscope	30964	2022-05-12	0
John Denver	30965	2022-05-12	0
Les Choeurs De L'Armée Rouge (Alexandrov)	30966	2022-05-12	0
Gustavo Cerati	30967	2022-05-12	0
Edda Moser/Hermann Prey/Münchner Rundfunkorchester/Heinz Wallberg	30968	2022-05-12	0
Faudel	30969	2022-05-12	0
Stanley Black	30970	2022-05-12	0
Bobby Freeman	30971	2022-05-12	0
Stellar	30972	2022-05-12	0
Orson	30973	2022-05-12	0
Rolling Blackouts	30974	2022-05-12	0
The Orange Peels	30975	2022-05-12	0
Supersuckers	30976	2022-05-12	0
Italian Instabile Orchestra	30977	2022-05-12	0
Manowar	30978	2022-05-12	0
Yennah	30979	2022-05-12	0
Frank Serious	30980	2022-05-12	0
Sagopa Kajmer	30981	2022-05-12	0
The Irish Tenors	30982	2022-05-12	0
David Raskin	30983	2022-05-12	0
True Live	30984	2022-05-12	0
Katan	30985	2022-05-12	0
Fast Distance	30986	2022-05-12	0
Mark Ronson featuring Tiggers	30987	2022-05-12	0
Filter	30988	2022-05-12	0
While	30989	2022-05-12	0
Jessy Greene	30990	2022-05-12	0
Love/Hate	30991	2022-05-12	0
Zebra	30992	2022-05-12	0
Finger Lickin' Allstars	30993	2022-05-12	0
The Gregg Allman Band	30994	2022-05-12	0
Dom Dummaste	30995	2022-05-12	0
Alain-François	30996	2022-05-12	0
Asobi Seksu	30997	2022-05-12	0
*NSYNC featuring Nelly	30998	2022-05-12	0
Christian Prommer's Drumlesson	30999	2022-05-12	0
Four Aces Featuring Al Roberts	31000	2022-05-12	0
Walter Brown	31001	2022-05-12	0
Snub	31002	2022-05-12	0
Johnny Hallyday	31003	2022-05-12	0
Dyce	31004	2022-05-12	0
Bersuit Vergarabat	31005	2022-05-12	0
DJ Shadow	31006	2022-05-12	0
The Flaming Sideburns	31007	2022-05-12	0
Rock et belles oreilles	31008	2022-05-12	0
IOS	31009	2022-05-12	0
Teoman	31010	2022-05-12	0
Fatboy Slim	31011	2022-05-12	0
SAF	31012	2022-05-12	0
Nils Lofgren	31013	2022-05-12	0
STRATOVARIUS	31014	2022-05-12	0
Bain Wolfkind	31015	2022-05-12	0
Augury	31016	2022-05-12	0
Tiger Man	31017	2022-05-12	0
Savon	31018	2022-05-12	0
Blind Blake	31019	2022-05-12	0
Airwave	31020	2022-05-12	0
Surra	31021	2022-05-12	0
Chris Christian	31022	2022-05-12	0
Cactus	31023	2022-05-12	0
The Stone Poneys Featuring Linda Ronstadt	31024	2022-05-12	0
Mike Westbrook	31025	2022-05-12	0
John Littlejohn	31026	2022-05-12	0
Casey Jones	31027	2022-05-12	0
Dallas Superstars	31028	2022-05-12	0
Ghislain Poirier	31029	2022-05-12	0
Corey Andrew	31030	2022-05-12	0
Antikue	31031	2022-05-12	0
Burl Ives	31032	2022-05-12	0
Demon Hunter	31033	2022-05-12	0
Mudvayne	31034	2022-05-12	0
Los Player's	31035	2022-05-12	0
Unwritten Law	31036	2022-05-12	0
Mr. Irish Bastard	31037	2022-05-12	0
Srebrna Krila	31038	2022-05-12	0
Lena Valaitis	31039	2022-05-12	0
Gisselle	31040	2022-05-12	0
No Bragging Rights	31041	2022-05-12	0
Dave Carter & Tracy Grammer	31042	2022-05-12	0
The Morning After Girls	31043	2022-05-12	0
Proyecto Uno	31044	2022-05-12	0
Ricky Valance	31045	2022-05-12	0
Loona	31046	2022-05-12	0
The Kingbees	31047	2022-05-12	0
Pato Fu	31048	2022-05-12	0
Ghosts	31049	2022-05-12	0
Deborah Allen	31050	2022-05-12	0
Tony Bennett	31051	2022-05-12	0
Josh Rouse	31052	2022-05-12	0
Herbst9	31053	2022-05-12	0
Sir Mack Rice	31054	2022-05-12	0
Amity in fame	31055	2022-05-12	0
Strike Anywhere	31056	2022-05-12	0
Glen Glenn	31057	2022-05-12	0
Johan Herz	31058	2022-05-12	0
The Mighty Bop	31059	2022-05-12	0
Metallica	31060	2022-05-12	0
Jeanie Lambe & The Danny Moss Quartet	31061	2022-05-12	0
Anne Linnet	31062	2022-05-12	0
Budapest Strings	31063	2022-05-12	0
Minor Threat	31064	2022-05-12	0
Claudine Longet	31065	2022-05-12	0
Maria de Barros	31066	2022-05-12	0
Missing Persons	31067	2022-05-12	0
Mister Ries	31068	2022-05-12	0
Joe Zawinul	31069	2022-05-12	0
Captain Gumbo	31070	2022-05-12	0
Rocco Deluca and The Burden	31071	2022-05-12	0
Boss AC	31072	2022-05-12	0
Albert Ammons	31073	2022-05-12	0
Fausto Leali	31074	2022-05-12	0
Jeff Dunham	31075	2022-05-12	0
Jazz Gillum	31076	2022-05-12	0
Jean-Jacques Milteau	31077	2022-05-12	0
Veggie Tales (Veggie Tunes)	31078	2022-05-12	0
Pin Me Down	31079	2022-05-12	0
Captain Comatose	31080	2022-05-12	0
Los Verdaderos Negros	31081	2022-05-12	0
Don Walser	31082	2022-05-12	0
Kenny Wayne Shepherd Band	31083	2022-05-12	0
Faxed Head	31084	2022-05-12	0
Wallace Roney	31085	2022-05-12	0
War	31086	2022-05-12	0
Scorn	31087	2022-05-12	0
Strata	31088	2022-05-12	0
Erra Fazira	31089	2022-05-12	0
Wes Carr	31090	2022-05-12	0
Chandeliers	31091	2022-05-12	0
Nine Inch Nails	31092	2022-05-12	0
David Vandervelde	31093	2022-05-12	0
Brute	31094	2022-05-12	0
Jelly Roll Morton's New Orleans Jazzmen	31095	2022-05-12	0
Dj Wady	31096	2022-05-12	0
Jason Derulo	31097	2022-05-12	0
Darkest Hour	31098	2022-05-12	0
Teckno Master DL	31099	2022-05-12	0
Jonathan Rhys Meyers;Steve Erdody	31100	2022-05-12	0
Satyricon	31101	2022-05-12	0
Richard Grey	31102	2022-05-12	0
Bobby Birdman	31103	2022-05-12	0
Treixadura	31104	2022-05-12	0
Hopeton Lewis	31105	2022-05-12	0
Promoe	31106	2022-05-12	0
Garnet Mimms And The Enchanters	31107	2022-05-12	0
Doc Scott	31108	2022-05-12	0
Orlando Cachaíto López	31109	2022-05-12	0
Al Jarreau	31110	2022-05-12	0
Das Bo	31111	2022-05-12	0
New York Philharmonic;Leonard Bernstein	31112	2022-05-12	0
AFTA-1	31113	2022-05-12	0
Icons of Filth	31114	2022-05-12	0
Jordan Suckley	31115	2022-05-12	0
The Pepper Pots	31116	2022-05-12	0
Atom	31117	2022-05-12	0
Serebro	31118	2022-05-12	0
Federico Franchi	31119	2022-05-12	0
Leon Jean-Marie	31120	2022-05-12	0
Jan & Dean	31121	2022-05-12	0
Dee Dee & Barbara Ramone	31122	2022-05-12	0
Erkki Junkkarinen	31123	2022-05-12	0
Nacho Marco	31124	2022-05-12	0
Reba McEntire	31125	2022-05-12	0
D Bridge	31126	2022-05-12	0
CDM Project	31127	2022-05-12	0
Grievous Angel	31128	2022-05-12	0
Planar	31129	2022-05-12	0
Jacob Young	31130	2022-05-12	0
The Royal Family And The Poor	31131	2022-05-12	0
Ecstasy Of St. Theresa	31132	2022-05-12	0
Fred Anderson	31133	2022-05-12	0
Ayumi Nakamura	31134	2022-05-12	0
Zuma	31135	2022-05-12	0
Pakita	31136	2022-05-12	0
First Aid Kit	31137	2022-05-12	0
Accuface	31138	2022-05-12	0
MARTIRES DEL COMPAS	31139	2022-05-12	0
Shwayze	31140	2022-05-12	0
Flobots	31141	2022-05-12	0
The String Cheese Incident	31142	2022-05-12	0
Everette Harp	31143	2022-05-12	0
Beatriz Adriana	31144	2022-05-12	0
Captain Capa	31145	2022-05-12	0
Willie Rosario	31146	2022-05-12	0
Marc-André Fortin	31147	2022-05-12	0
Blue Man Group	31148	2022-05-12	0
The Indians_ The Sioux Company	31149	2022-05-12	0
Svenska Akademien	31150	2022-05-12	0
Los Intocables Del Norte	31151	2022-05-12	0
Jean Segurel	31152	2022-05-12	0
Apollonia	31153	2022-05-12	0
Stefan Sundström	31154	2022-05-12	0
Jimmy Durante	31155	2022-05-12	0
Toni Dimitrova	31156	2022-05-12	0
Suicidal Tendencies	31157	2022-05-12	0
Skinlab	31158	2022-05-12	0
EDX	31159	2022-05-12	0
Nightwish	31160	2022-05-12	0
Avani	31161	2022-05-12	0
The Things	31162	2022-05-12	0
Chakra	31163	2022-05-12	0
Fred Giannelli	31164	2022-05-12	0
Blackstreet	31165	2022-05-12	0
Gino Paoli	31166	2022-05-12	0
The Chills	31167	2022-05-12	0
Lester Flatt and Earl Scruggs	31168	2022-05-12	0
Catherine Zeta-Jones;Queen Latifah	31169	2022-05-12	0
Buju Banton	31170	2022-05-12	0
Mega Banton	31171	2022-05-12	0
Hobo Junction_ Azeem_ Greans	31172	2022-05-12	0
BLESTeNATION	31173	2022-05-12	0
Demarkus Lewis	31174	2022-05-12	0
The Ventures	31175	2022-05-12	0
I_ Synthesist	31176	2022-05-12	0
Allergic to Whores	31177	2022-05-12	0
Kings Go Forth	31178	2022-05-12	0
Heatwave	31179	2022-05-12	0
Teairra Marí	31180	2022-05-12	0
Sofia Loell	31181	2022-05-12	0
Cheech And Chong	31182	2022-05-12	0
Guana Batz	31183	2022-05-12	0
Mighty Clouds Of Joy	31184	2022-05-12	0
Brad Paisley Duet With Keith Urban	31185	2022-05-12	0
Brant Bjork	31186	2022-05-12	0
Norman	31187	2022-05-12	0
John Williams;Itzhak Perlman;The Boston Pops Orchestra	31188	2022-05-12	0
Svenson & Gielen	31189	2022-05-12	0
Orquesta Guayacan	31190	2022-05-12	0
Intra Meridian	31191	2022-05-12	0
Nichols	31192	2022-05-12	0
Modeselektor	31193	2022-05-12	0
Tiltmeter	31194	2022-05-12	0
Bauhaus	31195	2022-05-12	0
Christie Front Drive	31196	2022-05-12	0
Quiero Club	31197	2022-05-12	0
Freddie Hubbard	31198	2022-05-12	0
Lord Sterling	31199	2022-05-12	0
Corrosion Of Conformity	31200	2022-05-12	0
Rod Stewart featuring Dolly Parton	31201	2022-05-12	0
Carlton Livingston	31202	2022-05-12	0
Luke Chable	31203	2022-05-12	0
Celldweller	31204	2022-05-12	0
Hugh Dillon	31205	2022-05-12	0
Urinals	31206	2022-05-12	0
Wolfgang Petry	31207	2022-05-12	0
The Mae Shi	31208	2022-05-12	0
Lee Lessack	31209	2022-05-12	0
Kasper Bjørke	31210	2022-05-12	0
Nina Simone	31211	2022-05-12	0
Mudhoney	31212	2022-05-12	0
Lydian Sea	31213	2022-05-12	0
Alexandre Pires	31214	2022-05-12	0
Andrew W.K.	31215	2022-05-12	0
blessed	31216	2022-05-12	0
Dekapitator	31217	2022-05-12	0
Blitzen Trapper	31218	2022-05-12	0
The High Strung	31219	2022-05-12	0
Gondwana	31220	2022-05-12	0
Technicolor	31221	2022-05-12	0
Slumlords	31222	2022-05-12	0
Chicharones	31223	2022-05-12	0
Orishas	31224	2022-05-12	0
Neon Horse	31225	2022-05-12	0
Livvi Franc	31226	2022-05-12	0
Casuarina	31227	2022-05-12	0
Gloria	31228	2022-05-12	0
Henry Mancini	31229	2022-05-12	0
First Class	31230	2022-05-12	0
Chelsea	31231	2022-05-12	0
Shy'm	31232	2022-05-12	0
Nas featuring Ginuwine	31233	2022-05-12	0
The Weakerthans	31234	2022-05-12	0
Mark Knight & Funkagenda	31235	2022-05-12	0
White Rabbits	31236	2022-05-12	0
40 Cal feat. Sudaboss	31237	2022-05-12	0
The Specials and Fun Boy Three	31238	2022-05-12	0
Warrant	31239	2022-05-12	0
Marian McPartland / Teddy Wilson	31240	2022-05-12	0
Robert Dietz	31241	2022-05-12	0
Marilyn Maxwell	31242	2022-05-12	0
The Chieftains	31243	2022-05-12	0
Mad Cobra	31244	2022-05-12	0
Andrew Gold	31245	2022-05-12	0
Stan Kenton	31246	2022-05-12	0
AC Slater	31247	2022-05-12	0
Stevie Nicks	31248	2022-05-12	0
The Giant Leap	31249	2022-05-12	0
The Bats	31250	2022-05-12	0
Nebula-H	31251	2022-05-12	0
Bangles	31252	2022-05-12	0
Tamara	31253	2022-05-12	0
Benoist Pipon	31254	2022-05-12	0
Kay D.Smith	31255	2022-05-12	0
Alberta Hunter	31256	2022-05-12	0
Morjac	31257	2022-05-12	0
Sandy B	31258	2022-05-12	0
Devo	31259	2022-05-12	0
The Koffin Kats	31260	2022-05-12	0
The Coalition Crew	31261	2022-05-12	0
Laika Dog	31262	2022-05-12	0
Thomas Fersen	31263	2022-05-12	0
Altern 8	31264	2022-05-12	0
Secret Affair	31265	2022-05-12	0
Cris Delanno	31266	2022-05-12	0
Marcilo Agro e il Duo Maravilha	31267	2022-05-12	0
Beat Dominator & Bass Automator	31268	2022-05-12	0
A Perfect Circle	31269	2022-05-12	0
Mike And The Mechanics	31270	2022-05-12	0
Two Hours Traffic	31271	2022-05-12	0
Lustral	31272	2022-05-12	0
Erasmo Carlos	31273	2022-05-12	0
Bachelors of Science	31274	2022-05-12	0
Atlanta Rhythm Section	31275	2022-05-12	0
La Chanson Du Dimanche	31276	2022-05-12	0
Fame	31277	2022-05-12	0
Zox	31278	2022-05-12	0
Don Juan Dracula	31279	2022-05-12	0
Blackfoot	31280	2022-05-12	0
Sebastian Hardie	31281	2022-05-12	0
Foreign Beggars	31282	2022-05-12	0
Black Devil Disco Club	31283	2022-05-12	0
Silver City	31284	2022-05-12	0
Midnyte	31285	2022-05-12	0
Hypo & Nikolu	31286	2022-05-12	0
The Untamed Youth	31287	2022-05-12	0
Rupaul	31288	2022-05-12	0
Percy Grainger	31289	2022-05-12	0
Serena Ryder	31290	2022-05-12	0
LMNO & Yann Kesz	31291	2022-05-12	0
Fonseca	31292	2022-05-12	0
Magic Arm	31293	2022-05-12	0
Neil Halstead	31294	2022-05-12	0
Movie Star Junkies	31295	2022-05-12	0
Three Trapped Tigers	31296	2022-05-12	0
Raz Ohara & The Odd Orchestra	31297	2022-05-12	0
Ace Cannon	31298	2022-05-12	0
Ivan Parker	31299	2022-05-12	0
CHAMPS	31300	2022-05-12	0
Bobby	31301	2022-05-12	0
B-Legit and Clyde Carson of the Team | Betta Way	31302	2022-05-12	0
Noyz Narcos	31303	2022-05-12	0
Randy Travis	31304	2022-05-12	0
Hootie And The Blowfish	31305	2022-05-12	0
Jai Uttal	31306	2022-05-12	0
Ray Conniff Singers	31307	2022-05-12	0
Chris Cotton	31308	2022-05-12	0
Alex Reece	31309	2022-05-12	0
Jean-Louis Murat	31310	2022-05-12	0
Archie Bronson Outfit	31311	2022-05-12	0
Victor Spinetti	31312	2022-05-12	0
Thee Headcoats	31313	2022-05-12	0
Vipers Skiffle Group	31314	2022-05-12	0
Andrea Bocelli	31315	2022-05-12	0
Phantom Band	31316	2022-05-12	0
London Elektricity	31317	2022-05-12	0
Finis Tasby	31318	2022-05-12	0
The Chemical Brothers	31319	2022-05-12	0
Bleeding Through	31320	2022-05-12	0
The Afghan Whigs	31321	2022-05-12	0
Esa Pakarinen	31322	2022-05-12	0
Darren Hanlon	31323	2022-05-12	0
John Ottman	31324	2022-05-12	0
Karl Denson	31325	2022-05-12	0
Ralph Towner_ Gary Peacock	31326	2022-05-12	0
The Irish Rovers	31327	2022-05-12	0
Pupy Y Los Que Son Son	31328	2022-05-12	0
Carmin Turco	31329	2022-05-12	0
Vinegar Joe	31330	2022-05-12	0
Ion	31331	2022-05-12	0
Pepe Aguilar	31332	2022-05-12	0
Blue Highway	31333	2022-05-12	0
The Dirtball_ Big B	31334	2022-05-12	0
Robert Plant	31335	2022-05-12	0
Ayiesha Woods	31336	2022-05-12	0
Bitty McLean	31337	2022-05-12	0
Deep Swing & Luis Radio pres The Roman Jazz Project	31338	2022-05-12	0
Andre Verchuren	31339	2022-05-12	0
Storybox	31340	2022-05-12	0
Dweazle	31341	2022-05-12	0
The Divine Comedy	31342	2022-05-12	0
Brainpower	31343	2022-05-12	0
Talkdemonic	31344	2022-05-12	0
Big House	31345	2022-05-12	0
Christina Aguilera	31346	2022-05-12	0
Big Money	31347	2022-05-12	0
Robbie Nevil	31348	2022-05-12	0
Idale	31349	2022-05-12	0
Carey Bell_ Lazy Lester_ Raful Neal & Snooky Pryor	31350	2022-05-12	0
Jennifer Lang	31351	2022-05-12	0
Oscar Lopez	31352	2022-05-12	0
Bacilos	31353	2022-05-12	0
Joi	31354	2022-05-12	0
Kid Creole And The Coconuts	31355	2022-05-12	0
Manuel De La Mare	31356	2022-05-12	0
Marco Beltrami	31357	2022-05-12	0
The Boo Radleys	31358	2022-05-12	0
Brighter	31359	2022-05-12	0
Edda	31360	2022-05-12	0
Naftule Brandwein	31361	2022-05-12	0
Bassbin Twins	31362	2022-05-12	0
JOHN COLTRANE	31363	2022-05-12	0
Don & Juan	31364	2022-05-12	0
Pascal Lejeune	31365	2022-05-12	0
Angelo Badalamenti	31366	2022-05-12	0
Giggs	31367	2022-05-12	0
Skye	31368	2022-05-12	0
220 Volt	31369	2022-05-12	0
Béla Fleck & the Flecktones	31370	2022-05-12	0
J Dilla aka Jay Dee	31371	2022-05-12	0
Kammerflimmer Kollektief	31372	2022-05-12	0
Yanou	31373	2022-05-12	0
Lexxus	31374	2022-05-12	0
Dion	31375	2022-05-12	0
Quasi	31376	2022-05-12	0
83	31377	2022-05-12	0
Williamson	31378	2022-05-12	0
Subsonica	31379	2022-05-12	0
Jah Wobble & Temple of Sound	31380	2022-05-12	0
Beatriz Luengo	31381	2022-05-12	0
Exit Osaka	31382	2022-05-12	0
Gong	31383	2022-05-12	0
Karminsky Experience Inc.	31384	2022-05-12	0
The Freelance Hellraiser	31385	2022-05-12	0
That Petrol Emotion	31386	2022-05-12	0
Joe Budden	31387	2022-05-12	0
The Mellows	31388	2022-05-12	0
Humanzi	31389	2022-05-12	0
Fernanda De Utrera	31390	2022-05-12	0
Rabbit	31391	2022-05-12	0
Foreign Born	31392	2022-05-12	0
The Undertones	31393	2022-05-12	0
Tako	31394	2022-05-12	0
Celso Piña	31395	2022-05-12	0
Omen	31396	2022-05-12	0
Lil Cuete	31397	2022-05-12	0
Neviss	31398	2022-05-12	0
Multiphase	31399	2022-05-12	0
Boyz II Men / Shae Jones	31400	2022-05-12	0
Natty King & Al Pancho	31401	2022-05-12	0
Connie Smith	31402	2022-05-12	0
Gordon	31403	2022-05-12	0
Transplants	31404	2022-05-12	0
Trio Odemira	31405	2022-05-12	0
David Morales W/ Vivan Sessoms	31406	2022-05-12	0
Bret Michaels	31407	2022-05-12	0
Blood	31408	2022-05-12	0
Hanna	31409	2022-05-12	0
UMEK	31410	2022-05-12	0
Discover America	31411	2022-05-12	0
Esmée Denters	31412	2022-05-12	0
Whodini	31413	2022-05-12	0
For The Fallen Dreams	31414	2022-05-12	0
Wavering Saints	31415	2022-05-12	0
Jes	31416	2022-05-12	0
Paul McCandless	31417	2022-05-12	0
T.I.'S	31418	2022-05-12	0
Harry Belafonte	31419	2022-05-12	0
The Libertines	31420	2022-05-12	0
Les Yeux Noirs	31421	2022-05-12	0
Tony Roots	31422	2022-05-12	0
Nasty Nardo	31423	2022-05-12	0
Los Lonely Boys	31424	2022-05-12	0
Tim Fite	31425	2022-05-12	0
Mac & A.K.	31426	2022-05-12	0
Jennifer Rostock	31427	2022-05-12	0
ZAO	31428	2022-05-12	0
Boulbar	31429	2022-05-12	0
El Chojin (con Gospel Factory)	31430	2022-05-12	0
Jackson Do Pandeiro	31431	2022-05-12	0
Katja Ebstein	31432	2022-05-12	0
Natalia Kukulska	31433	2022-05-12	0
Rubyhorse	31434	2022-05-12	0
Sister Double Happiness	31435	2022-05-12	0
Tino Derado	31436	2022-05-12	0
KRS-One	31437	2022-05-12	0
Benassi Bros.	31438	2022-05-12	0
Kevin Max	31439	2022-05-12	0
The Members	31440	2022-05-12	0
Claude Thornhill	31441	2022-05-12	0
The Crystal Method	31442	2022-05-12	0
Tommy Guerrero	31443	2022-05-12	0
Solarstone & Orkidea	31444	2022-05-12	0
Diamond Rexx	31445	2022-05-12	0
Dom Um Romao	31446	2022-05-12	0
Bobby Hackett	31447	2022-05-12	0
Anti-Flag	31448	2022-05-12	0
Sans Pression	31449	2022-05-12	0
Margot & The Nuclear So And So's	31450	2022-05-12	0
None More Black	31451	2022-05-12	0
Rubby	31452	2022-05-12	0
The Oohlas	31453	2022-05-12	0
Mud Boy and the Neutrons	31454	2022-05-12	0
Frank Ifield	31455	2022-05-12	0
Princess Superstar	31456	2022-05-12	0
Northern State feat. Pete Rock	31457	2022-05-12	0
Chava Flores	31458	2022-05-12	0
Leroy Smart	31459	2022-05-12	0
Erik Satie	31460	2022-05-12	0
Ivan Villazon;Gonzalo Arturo Molina	31461	2022-05-12	0
Mouse On Mars	31462	2022-05-12	0
Miles Davis Quintet	31463	2022-05-12	0
Les Filles de Sainte Colombe	31464	2022-05-12	0
Fay-Ann Lyons & Macka Diamond	31465	2022-05-12	0
Los Bunkers	31466	2022-05-12	0
The Quantic Soul Orchestra	31467	2022-05-12	0
RONNIE RONALDE	31468	2022-05-12	0
Alessandra Amoroso	31469	2022-05-12	0
Incantation	31470	2022-05-12	0
Roch Voisine	31471	2022-05-12	0
Keak Da Sneak_ T-Nutty	31472	2022-05-12	0
Steve Brian	31473	2022-05-12	0
Christmas Acoustica	31474	2022-05-12	0
Meat Katie	31475	2022-05-12	0
Mellow Trax feat. Lyck	31476	2022-05-12	0
Ricaine	31477	2022-05-12	0
S.O.S.	31478	2022-05-12	0
Wrinkle Neck Mules	31479	2022-05-12	0
James Cleveland_ The Southern California Community Choir_ James Cleveland	31480	2022-05-12	0
Bam Bam	31481	2022-05-12	0
Apache Indian / A.R. Rahman	31482	2022-05-12	0
The Flashing Lights	31483	2022-05-12	0
Baba Brooks	31484	2022-05-12	0
MC Duty	31485	2022-05-12	0
Landser	31486	2022-05-12	0
Fabio Stein	31487	2022-05-12	0
Paco Peña	31488	2022-05-12	0
Deitra Farr	31489	2022-05-12	0
Ana Cirré	31490	2022-05-12	0
Bill Anschell	31491	2022-05-12	0
Detroit Grand Pubahs featuring Gerald Mitchell & Jerry the Cat	31492	2022-05-12	0
Mark Medlock & Dieter Bohlen	31493	2022-05-12	0
Loose Shus	31494	2022-05-12	0
Anthrax / Public Enemy	31495	2022-05-12	0
Jimena	31496	2022-05-12	0
Sielun Veljet	31497	2022-05-12	0
The Speed Freak	31498	2022-05-12	0
Waldick Soriano	31499	2022-05-12	0
Felix Cavaliere	31500	2022-05-12	0
Hirshee featuring Tara Lett	31501	2022-05-12	0
1.000 Mexicans	31502	2022-05-12	0
Legend B	31503	2022-05-12	0
Gui Boratto	31504	2022-05-12	0
Sergent Garcia	31505	2022-05-12	0
Mustang	31506	2022-05-12	0
Robert Rich	31507	2022-05-12	0
Martha Reeves & The Vandellas	31508	2022-05-12	0
Moot Davis	31509	2022-05-12	0
Second Skin	31510	2022-05-12	0
Nicolette	31511	2022-05-12	0
Gorerotted	31512	2022-05-12	0
Daru & Reggie B.	31513	2022-05-12	0
Jani Lane (formerly of Warrant)	31514	2022-05-12	0
Midtown	31515	2022-05-12	0
Rye Coalition	31516	2022-05-12	0
A.Human	31517	2022-05-12	0
Flaco Jimenez	31518	2022-05-12	0
Bob Gibson & Bob Camp	31519	2022-05-12	0
Dr. Know	31520	2022-05-12	0
Loretta Lynn / Conway Twitty	31521	2022-05-12	0
Frankie 'Half-Pint' Jaxon	31522	2022-05-12	0
Rolf Harris	31523	2022-05-12	0
David Mead	31524	2022-05-12	0
The Court & Spark	31525	2022-05-12	0
BuRo feat. Tiff Lacey	31526	2022-05-12	0
Patrick Jumpen	31527	2022-05-12	0
Cadia	31528	2022-05-12	0
Werner Pirchner	31529	2022-05-12	0
Sugafree featuring Reece	31530	2022-05-12	0
Los Rurales De Gilberto Parra	31531	2022-05-12	0
Maurizio Vandelli	31532	2022-05-12	0
Orquesta El Arranque	31533	2022-05-12	0
Project Polaroid (tom c3 & kool keith)	31534	2022-05-12	0
Ex-Girl	31535	2022-05-12	0
S'Express	31536	2022-05-12	0
Jaime Roos	31537	2022-05-12	0
Emmon	31538	2022-05-12	0
Little River Band	31539	2022-05-12	0
George Duke	31540	2022-05-12	0
Sergio Tiempo	31541	2022-05-12	0
Jerry Garcia / Merl Saunders / John Kahn / Bill Vitt	31542	2022-05-12	0
WC And The Maad Circle	31543	2022-05-12	0
Robert Gawlinski	31544	2022-05-12	0
Derek Miller	31545	2022-05-12	0
Ornatos Violeta	31546	2022-05-12	0
Young Capone	31547	2022-05-12	0
1997	31548	2022-05-12	0
Ochre	31549	2022-05-12	0
Lila Downs	31550	2022-05-12	0
Khalil Fong	31551	2022-05-12	0
Moqui Marbles	31552	2022-05-12	0
Open Season	31553	2022-05-12	0
Gustavo Lins	31554	2022-05-12	0
Jim Hall	31555	2022-05-12	0
Burning Spear	31556	2022-05-12	0
Baja Marimba Band	31557	2022-05-12	0
Freda Payne	31558	2022-05-12	0
DJ Lambda feat. Euphoria vs. Solar Explosion	31559	2022-05-12	0
Belinda Carlisle	31560	2022-05-12	0
Black Attack	31561	2022-05-12	0
Deep Wound	31562	2022-05-12	0
The Screamin' Cheetah Wheelies	31563	2022-05-12	0
La Ciapa Rusa	31564	2022-05-12	0
Mink	31565	2022-05-12	0
Brian Wilson	31566	2022-05-12	0
50 Cent	31567	2022-05-12	0
Mahavishnu Orchestra	31568	2022-05-12	0
Urszula Dudziak	31569	2022-05-12	0
Django Reinhardt - Dicky Wells	31570	2022-05-12	0
Barbara Morrison	31571	2022-05-12	0
Vimana	31572	2022-05-12	0
The Isley Brothers	31573	2022-05-12	0
Cecil Grant	31574	2022-05-12	0
Magical Sunrise	31575	2022-05-12	0
Tapper Zukie	31576	2022-05-12	0
Attica! Attica!	31577	2022-05-12	0
The Pogues	31578	2022-05-12	0
Naomi Shelton & the Gospel Queens	31579	2022-05-12	0
Bronski Beat	31580	2022-05-12	0
Electrik Red	31581	2022-05-12	0
Dougie Pincock	31582	2022-05-12	0
Winx	31583	2022-05-12	0
Black Market Radio	31584	2022-05-12	0
Oscarlima	31585	2022-05-12	0
The D4	31586	2022-05-12	0
José James	31587	2022-05-12	0
Domenic Marte	31588	2022-05-12	0
David Poe	31589	2022-05-12	0
Beneath Autumn Sky	31590	2022-05-12	0
4-Tay	31591	2022-05-12	0
Baba Zula	31592	2022-05-12	0
Presidents Of The United States Of America	31593	2022-05-12	0
SIS	31594	2022-05-12	0
Hugh Hopper	31595	2022-05-12	0
Math Head	31596	2022-05-12	0
Malos Vicios	31597	2022-05-12	0
Crash!	31598	2022-05-12	0
Noah23	31599	2022-05-12	0
Mark Sultan	31600	2022-05-12	0
Avoid One Thing	31601	2022-05-12	0
Zimbaria	31602	2022-05-12	0
Bamberg Symphony Orchestra	31603	2022-05-12	0
Big Audio Dynamite	31604	2022-05-12	0
Scared Of Chaka	31605	2022-05-12	0
Night Dreamers	31606	2022-05-12	0
Jeremy Camp	31607	2022-05-12	0
SOIL & "PIMP" SESSIONS	31608	2022-05-12	0
Ruth Brown	31609	2022-05-12	0
Jennifer Holliday / Sheryl Lee Ralph / Loretta Devine / Deborah Burrell / The Company	31610	2022-05-12	0
Peggy Lee_ Bing Crosby	31611	2022-05-12	0
Magnapop	31612	2022-05-12	0
Pay TV	31613	2022-05-12	0
One Win Choice	31614	2022-05-12	0
Darwin C Bogan	31615	2022-05-12	0
Ismo Alanko Säätiö	31616	2022-05-12	0
Daughters	31617	2022-05-12	0
Solar Plexus	31618	2022-05-12	0
Mindy Smith	31619	2022-05-12	0
Aidonia	31620	2022-05-12	0
The Winter Sounds	31621	2022-05-12	0
Razah	31622	2022-05-12	0
Winger	31623	2022-05-12	0
Kultur Shock	31624	2022-05-12	0
Benny Goodman	31625	2022-05-12	0
Alborosie	31626	2022-05-12	0
Tickle Me Pink	31627	2022-05-12	0
La Castaneda	31628	2022-05-12	0
Tex Williams	31629	2022-05-12	0
Louis Armstrong and His Orchestra	31630	2022-05-12	0
Kollaa Kestää	31631	2022-05-12	0
Current Value	31632	2022-05-12	0
The Phantom	31633	2022-05-12	0
Fire Island	31634	2022-05-12	0
The Long Blondes	31635	2022-05-12	0
Denyo 77	31636	2022-05-12	0
Interpol	31637	2022-05-12	0
No Comment	31638	2022-05-12	0
Nick Terranova feat. Steve Bertrand	31639	2022-05-12	0
Westlife	31640	2022-05-12	0
Gustavo Lamas	31641	2022-05-12	0
Kid Rock	31642	2022-05-12	0
Dino Psaras	31643	2022-05-12	0
Sk Radicals	31644	2022-05-12	0
Baldwin Brothers	31645	2022-05-12	0
38 Special	31646	2022-05-12	0
Victims Family	31647	2022-05-12	0
Dr. Didg	31648	2022-05-12	0
Banda Eva / Ivete Sangalo / Emanuelle / Ricardo Chaves / Durval Lelys / Marcionílio / Luiz Caldas	31649	2022-05-12	0
Lila Mccann	31650	2022-05-12	0
Jim Kweskin	31651	2022-05-12	0
Television	31652	2022-05-12	0
Zircon	31653	2022-05-12	0
The Appleseed Cast	31654	2022-05-12	0
Us3	31655	2022-05-12	0
Brian Free & Assurance	31656	2022-05-12	0
Chelonis R. Jones	31657	2022-05-12	0
Claw Boys Claw	31658	2022-05-12	0
Comanechi	31659	2022-05-12	0
Richard Cocciante	31660	2022-05-12	0
Concrete Blonde	31661	2022-05-12	0
Zap Mama	31662	2022-05-12	0
Plume Latraverse and The Plumettes	31663	2022-05-12	0
Gorgeous X feat. Julia Falke	31664	2022-05-12	0
Marc Korn	31665	2022-05-12	0
Swiz	31666	2022-05-12	0
Roy Clark	31667	2022-05-12	0
Tom Grant	31668	2022-05-12	0
The Gamits	31669	2022-05-12	0
2MB	31670	2022-05-12	0
Parasites	31671	2022-05-12	0
Thinkman	31672	2022-05-12	0
Perpetual Groove	31673	2022-05-12	0
Othar Turner & The Rising Star Fife And Drum Band	31674	2022-05-12	0
Jay Vaquer	31675	2022-05-12	0
Big Joe Williams	31676	2022-05-12	0
Timmy O'tool	31677	2022-05-12	0
Silver Sun	31678	2022-05-12	0
Arthur Collins & Byron G. Harlan	31679	2022-05-12	0
Hope For The Dying	31680	2022-05-12	0
A.C. Reed	31681	2022-05-12	0
Marshall Crenshaw	31682	2022-05-12	0
The Crystals	31683	2022-05-12	0
Melanie B	31684	2022-05-12	0
M6	31685	2022-05-12	0
Ebru Yasar	31686	2022-05-12	0
Paul Fried  - Mark Kroll	31687	2022-05-12	0
tim scott	31688	2022-05-12	0
Big Country	31689	2022-05-12	0
Bill Haley & Comets	31690	2022-05-12	0
Pärson Sound	31691	2022-05-12	0
Whiskey Rebels	31692	2022-05-12	0
The Fugs	31693	2022-05-12	0
Kate Smith	31694	2022-05-12	0
Mijares	31695	2022-05-12	0
Doc Holliday	31696	2022-05-12	0
Billy Eckstine & His Orchestra	31697	2022-05-12	0
Peter Case	31698	2022-05-12	0
Jackie McLean Quintet	31699	2022-05-12	0
Talib Kweli	31700	2022-05-12	0
Vibeke Saugestad	31701	2022-05-12	0
Richard 'Humpty' Vission	31702	2022-05-12	0
Les Rita Mitsouko	31703	2022-05-12	0
MoShang	31704	2022-05-12	0
Altered Images	31705	2022-05-12	0
Vincent Bruley	31706	2022-05-12	0
Pig & Dan	31707	2022-05-12	0
Charlotte Gainsbourg	31708	2022-05-12	0
Pink Cream 69	31709	2022-05-12	0
Mandala feat. Beth Macari	31710	2022-05-12	0
Le Vibrazioni	31711	2022-05-12	0
Active Sight	31712	2022-05-12	0
The Black Box Revelation	31713	2022-05-12	0
Gabinete Caligari	31714	2022-05-12	0
Amar Sundy	31715	2022-05-12	0
Shinedown	31716	2022-05-12	0
Daniel Santos & La Sonora Matancera	31717	2022-05-12	0
Joe Simon	31718	2022-05-12	0
Tuck & Patti	31719	2022-05-12	0
J.C. Lodge	31720	2022-05-12	0
Jamie Janover	31721	2022-05-12	0
Nancy Martinez	31722	2022-05-12	0
Momo Wandel Soumah	31723	2022-05-12	0
Ella Fitzgerald	31724	2022-05-12	0
Heavyweight Dub Champion	31725	2022-05-12	0
BB Jürgen	31726	2022-05-12	0
9 West	31727	2022-05-12	0
Die! Die! Die!	31728	2022-05-12	0
DJ Muggs / Sick Jacken / Cynic	31729	2022-05-12	0
Gwen Stefani	31730	2022-05-12	0
L'Orchestra Cinematique	31731	2022-05-12	0
Axwell_ Angello_ Ingrosso & Laidback Luke	31732	2022-05-12	0
Bertrand Burgalat	31733	2022-05-12	0
Jan Leyers	31734	2022-05-12	0
Dead Prez & The Evil Genius DJ Green Lantern	31735	2022-05-12	0
Little John	31736	2022-05-12	0
Hacienda Brothers	31737	2022-05-12	0
Jussi Soro	31738	2022-05-12	0
Troubled Hubble	31739	2022-05-12	0
Brigadier Jerry (feat. Llawi)	31740	2022-05-12	0
Baby Bash / Low G.	31741	2022-05-12	0
Arbee Stidham	31742	2022-05-12	0
Colder	31743	2022-05-12	0
Toby Dreher	31744	2022-05-12	0
Smokie Norful	31745	2022-05-12	0
Nacho Sotomayor	31746	2022-05-12	0
Lights	31747	2022-05-12	0
Christian McBride	31748	2022-05-12	0
Jeromes Dream	31749	2022-05-12	0
Sir Simon Rattle/Berliner Philharmoniker	31750	2022-05-12	0
Pat Martino	31751	2022-05-12	0
Craig Morgan	31752	2022-05-12	0
Lucky Goat	31753	2022-05-12	0
Elakelaiset	31754	2022-05-12	0
Los Concorde	31755	2022-05-12	0
Linda Guilala	31756	2022-05-12	0
Pyrolator	31757	2022-05-12	0
Goonies Never Say Die	31758	2022-05-12	0
In The Woods	31759	2022-05-12	0
Fugees	31760	2022-05-12	0
The Late Greats	31761	2022-05-12	0
Chesney Hawkes	31762	2022-05-12	0
Sami Saari	31763	2022-05-12	0
Sommerset	31764	2022-05-12	0
Brand Nubian	31765	2022-05-12	0
Soul Flower Union	31766	2022-05-12	0
The Clancy Brothers	31767	2022-05-12	0
Patrick Fiori	31768	2022-05-12	0
Forty Percent	31769	2022-05-12	0
Jonas Hellborg	31770	2022-05-12	0
Codes In The Clouds	31771	2022-05-12	0
Elliot Lawrence	31772	2022-05-12	0
Fatty Koo	31773	2022-05-12	0
No Innocent Victim	31774	2022-05-12	0
The Ipanemas	31775	2022-05-12	0
Coolio feat. 40 thevz	31776	2022-05-12	0
Craig Urquhart	31777	2022-05-12	0
Jackie Mittoo and Sound Dimension	31778	2022-05-12	0
John McEuen	31779	2022-05-12	0
Fake Blood	31780	2022-05-12	0
The Cuff Links	31781	2022-05-12	0
Ligabue	31782	2022-05-12	0
Mojave 3	31783	2022-05-12	0
Southeast Engine	31784	2022-05-12	0
Feral Children	31785	2022-05-12	0
Pohjannaula	31786	2022-05-12	0
Samba Mapangala and Orchestra Virunga	31787	2022-05-12	0
Jolin Tsai	31788	2022-05-12	0
Cass Phang	31789	2022-05-12	0
Tony Delafose	31790	2022-05-12	0
Polecats	31791	2022-05-12	0
Pfeffer	31792	2022-05-12	0
Huggy Bear	31793	2022-05-12	0
Santa Claws and the Naughty But Nice Orchestra	31794	2022-05-12	0
The Manhattan Transfer	31795	2022-05-12	0
Andreas Mattsson	31796	2022-05-12	0
DOB	31797	2022-05-12	0
Macc Lads	31798	2022-05-12	0
Jeff Samuel	31799	2022-05-12	0
Dirt Crew	31800	2022-05-12	0
E.C. Illa	31801	2022-05-12	0
The Jive Aces_ Chick Corea	31802	2022-05-12	0
Ponies In the Surf	31803	2022-05-12	0
Lynch Mob	31804	2022-05-12	0
Pelle Miljoona	31805	2022-05-12	0
Yo Majesty	31806	2022-05-12	0
Astura	31807	2022-05-12	0
Sunscreem	31808	2022-05-12	0
Boys Of The Lough	31809	2022-05-12	0
Monodeluxe	31810	2022-05-12	0
Beau Jocque_ The Zydeco Hi-Rollers	31811	2022-05-12	0
Helalyn Flowers	31812	2022-05-12	0
Sahara Hotnights	31813	2022-05-12	0
Team Waterpolo	31814	2022-05-12	0
Fey	31815	2022-05-12	0
Songs Of Green Pheasant	31816	2022-05-12	0
Famous L. Renfroe	31817	2022-05-12	0
Die Kleinen Götter	31818	2022-05-12	0
Sevendust	31819	2022-05-12	0
Leatherface	31820	2022-05-12	0
Hughes Turner Project	31821	2022-05-12	0
Blufeld	31822	2022-05-12	0
The Dum Dum Project	31823	2022-05-12	0
The Leftovers	31824	2022-05-12	0
GROVER WASHINGTON_ JR.	31825	2022-05-12	0
X-Wife	31826	2022-05-12	0
Title Tracks	31827	2022-05-12	0
Uranium 235	31828	2022-05-12	0
Silent Knight	31829	2022-05-12	0
DjaKo	31830	2022-05-12	0
The Homens	31831	2022-05-12	0
Clave Y Guaguancó	31832	2022-05-12	0
The California Cajun Orchestra	31833	2022-05-12	0
Alex Kenji	31834	2022-05-12	0
MAS 2008	31835	2022-05-12	0
Glen Gray And The Casa Loma Orchestra	31836	2022-05-12	0
Norman And Nancy Blakie	31837	2022-05-12	0
Screamin' Jay Hawkins	31838	2022-05-12	0
Resin Dogs	31839	2022-05-12	0
John Foxx	31840	2022-05-12	0
Gipsy Kings	31841	2022-05-12	0
Modjo	31842	2022-05-12	0
Barbara Cook;John Raitt	31843	2022-05-12	0
Murder 1	31844	2022-05-12	0
Baby Grandmothers	31845	2022-05-12	0
Kahvas Jute	31846	2022-05-12	0
Across Five Aprils	31847	2022-05-12	0
John David Souther	31848	2022-05-12	0
Springbok Nude Girls	31849	2022-05-12	0
Nocturnal Rites	31850	2022-05-12	0
Bizzy B	31851	2022-05-12	0
Sylvia Syms	31852	2022-05-12	0
Skatebard	31853	2022-05-12	0
Johannes Linstead	31854	2022-05-12	0
UFO	31855	2022-05-12	0
The Jazz Mandolin Project	31856	2022-05-12	0
Lisa Gerrard & Jeff Rona	31857	2022-05-12	0
Frances-Marie Uitti	31858	2022-05-12	0
The Only Ones	31859	2022-05-12	0
Rachel Unthank And The Winterset	31860	2022-05-12	0
Vicky Beeching	31861	2022-05-12	0
Negative	31862	2022-05-12	0
Lil Boosie	31863	2022-05-12	0
Paco Peña / Eduardo Falú	31864	2022-05-12	0
Double X	31865	2022-05-12	0
Joanie Sommers	31866	2022-05-12	0
Bambam	31867	2022-05-12	0
Pumpkin Buzzard	31868	2022-05-12	0
Eco	31869	2022-05-12	0
Dimitri DKN featuring Dj Mack	31870	2022-05-12	0
ALTERED STATES	31871	2022-05-12	0
Meg Baird	31872	2022-05-12	0
S Club 8	31873	2022-05-12	0
Crucifixion	31874	2022-05-12	0
Shakespears Sister	31875	2022-05-12	0
Betagarri	31876	2022-05-12	0
Tayfun	31877	2022-05-12	0
B-Boy 3000	31878	2022-05-12	0
Dillard Chandler	31879	2022-05-12	0
Les Paul_ Mary Ford	31880	2022-05-12	0
Harry James And His Orchestra	31881	2022-05-12	0
Little Anthony & The Imperials	31882	2022-05-12	0
Magic Slim	31883	2022-05-12	0
Cibelle	31884	2022-05-12	0
Stephen Warbeck	31885	2022-05-12	0
T-Bone	31886	2022-05-12	0
Kooii	31887	2022-05-12	0
Lowkey	31888	2022-05-12	0
Becky Baeling	31889	2022-05-12	0
Duo Live	31890	2022-05-12	0
Skylab	31891	2022-05-12	0
Frauenarzt	31892	2022-05-12	0
Stan Rogers	31893	2022-05-12	0
Lisa Stansfield;Ian Devaney;Andy Morris	31894	2022-05-12	0
Jungle Rot	31895	2022-05-12	0
Karin Krog	31896	2022-05-12	0
Super Cayor De Dakar	31897	2022-05-12	0
Loquillo Y Los Trogloditas	31898	2022-05-12	0
Heiner Goebbels	31899	2022-05-12	0
Amon Düül 2	31900	2022-05-12	0
Paul Kelly	31901	2022-05-12	0
Tonicha	31902	2022-05-12	0
No Fun At All	31903	2022-05-12	0
Outworld	31904	2022-05-12	0
Gabor Szabo	31905	2022-05-12	0
The Count & Sinden	31906	2022-05-12	0
Jules Shear	31907	2022-05-12	0
Duke Ellington_ His Famous Orchestra	31908	2022-05-12	0
Wellenrausch & Velvet Skies feat. Tiff Lacey	31909	2022-05-12	0
J. J. Barnes	31910	2022-05-12	0
Jan Hammer	31911	2022-05-12	0
Trüby Trio	31912	2022-05-12	0
Al Gromer Khan	31913	2022-05-12	0
Great Plains	31914	2022-05-12	0
Two Door Cinema Club	31915	2022-05-12	0
Evan Yo	31916	2022-05-12	0
Roedelius / Lunz	31917	2022-05-12	0
Tim Fischer	31918	2022-05-12	0
Hypasonic	31919	2022-05-12	0
Dance 2 Infinity feat. Elena	31920	2022-05-12	0
Claustrofobia	31921	2022-05-12	0
Pittsburgh Slim	31922	2022-05-12	0
Bo Selecta	31923	2022-05-12	0
Leopold Kraus Wellenkapelle	31924	2022-05-12	0
Philly Slim	31925	2022-05-12	0
Karkkiautomaatti	31926	2022-05-12	0
Fernando Correia Marques	31927	2022-05-12	0
Jenny Piccolo	31928	2022-05-12	0
Fact	31929	2022-05-12	0
Pieces Of A Dream	31930	2022-05-12	0
EDSON	31931	2022-05-12	0
Poor Rich Ones	31932	2022-05-12	0
Bryan Scary and the Shredding Tears	31933	2022-05-12	0
Janice Grace	31934	2022-05-12	0
Old Crow Medicine Show	31935	2022-05-12	0
Wayne Krantz	31936	2022-05-12	0
Bryan Savage	31937	2022-05-12	0
F4	31938	2022-05-12	0
Nas featuring the Bravehearts	31939	2022-05-12	0
Kids In Glass Houses	31940	2022-05-12	0
Switch	31941	2022-05-12	0
Crab Smasher	31942	2022-05-12	0
Covered Call	31943	2022-05-12	0
Greg Long	31944	2022-05-12	0
Avanto	31945	2022-05-12	0
Walter Smith & Friends	31946	2022-05-12	0
The Last	31947	2022-05-12	0
Dayglo Abortions	31948	2022-05-12	0
Mississippi Mass Choir	31949	2022-05-12	0
Dislocation Dance	31950	2022-05-12	0
Adrian (Sir) Boult	31951	2022-05-12	0
Antonio Carlos Jobim / Elis Regina	31952	2022-05-12	0
Days Difference	31953	2022-05-12	0
Future Prophecy	31954	2022-05-12	0
Eugene Record	31955	2022-05-12	0
Swen Weber	31956	2022-05-12	0
Magno	31957	2022-05-12	0
Prince Malachi	31958	2022-05-12	0
The Moody Blues	31959	2022-05-12	0
Nightfall	31960	2022-05-12	0
Adriano Canzian	31961	2022-05-12	0
The Riffs	31962	2022-05-12	0
Thanatos	31963	2022-05-12	0
AWOL One	31964	2022-05-12	0
Bright Eyes	31965	2022-05-12	0
1001 Ways	31966	2022-05-12	0
Malavoi	31967	2022-05-12	0
Angel City Outcasts	31968	2022-05-12	0
Cheater Slicks	31969	2022-05-12	0
Ray Dee Ohh	31970	2022-05-12	0
Jet Set Satellite	31971	2022-05-12	0
The Rockwells	31972	2022-05-12	0
Panpipes	31973	2022-05-12	0
Daniel Mehlhart	31974	2022-05-12	0
Kettcar	31975	2022-05-12	0
Souls She Said	31976	2022-05-12	0
Mychael Danna	31977	2022-05-12	0
Jello Biafra With D.O.A.	31978	2022-05-12	0
Fletcher Henderson & The Dixie Stompers	31979	2022-05-12	0
George Jones;Patti Page	31980	2022-05-12	0
Roi Heenok_ La Dose_ La Mixtape	31981	2022-05-12	0
Heiruspecs	31982	2022-05-12	0
Terminal Choice	31983	2022-05-12	0
Los Rodriguez	31984	2022-05-12	0
Zen Café	31985	2022-05-12	0
Ali Hassan Kuban	31986	2022-05-12	0
Roni Size	31987	2022-05-12	0
Who's That Girl!	31988	2022-05-12	0
Christian Castro	31989	2022-05-12	0
Micatone	31990	2022-05-12	0
John Waller	31991	2022-05-12	0
Joi Cardwell	31992	2022-05-12	0
John Oszajca	31993	2022-05-12	0
Los Vallenato Trio	31994	2022-05-12	0
Jacques Brel	31995	2022-05-12	0
Kevin McKendree	31996	2022-05-12	0
Reuben	31997	2022-05-12	0
Krokus	31998	2022-05-12	0
Ras Kass	31999	2022-05-12	0
Sam Riney	32000	2022-05-12	0
Dean Elliott And His Big Band	32001	2022-05-12	0
Jody Sticker	32002	2022-05-12	0
Findo Gask	32003	2022-05-12	0
Birdsongs of the Mesozoic	32004	2022-05-12	0
Zoe Birkett	32005	2022-05-12	0
Raging Slab	32006	2022-05-12	0
Lenny Kravitz	32007	2022-05-12	0
Mystery	32008	2022-05-12	0
Thomas Penton	32009	2022-05-12	0
Dennis Coffey	32010	2022-05-12	0
Matheux	32011	2022-05-12	0
Dishwalla	32012	2022-05-12	0
Our Time Down Here	32013	2022-05-12	0
The Jet Set	32014	2022-05-12	0
Bleeding Hearts	32015	2022-05-12	0
Andy Tau	32016	2022-05-12	0
Dubfire	32017	2022-05-12	0
Upon Beauty Rests	32018	2022-05-12	0
Smokey Robinson & The Miracles	32019	2022-05-12	0
Joe McBride	32020	2022-05-12	0
Craig Chaquico	32021	2022-05-12	0
The Modern	32022	2022-05-12	0
U.S. Bombs	32023	2022-05-12	0
Julian's Treatment	32024	2022-05-12	0
Banner Pilot	32025	2022-05-12	0
Michael Franti & Spearhead	32026	2022-05-12	0
Paper Route	32027	2022-05-12	0
Moonstarr	32028	2022-05-12	0
Reagan Youth	32029	2022-05-12	0
Elise Estrada	32030	2022-05-12	0
Sonik City	32031	2022-05-12	0
GENUINE CHILDS	32032	2022-05-12	0
Laurel Aitken	32033	2022-05-12	0
The Sweetest Ache	32034	2022-05-12	0
Count Basie & His Sextet	32035	2022-05-12	0
Kingpin Skinny Pimp	32036	2022-05-12	0
Siw Malmqvist	32037	2022-05-12	0
Andy Jay Powell	32038	2022-05-12	0
Puny Human	32039	2022-05-12	0
BnK	32040	2022-05-12	0
Ideal	32041	2022-05-12	0
The Kaze	32042	2022-05-12	0
Felix Cartal	32043	2022-05-12	0
Noel Pointer	32044	2022-05-12	0
Yves Murasca pres. Vintage System	32045	2022-05-12	0
Roedelius	32046	2022-05-12	0
DC Talk	32047	2022-05-12	0
So Many Dynamos	32048	2022-05-12	0
Devics	32049	2022-05-12	0
Rockin' Squat	32050	2022-05-12	0
The Postmarks	32051	2022-05-12	0
Kristin Chenoweth	32052	2022-05-12	0
Gilbert Bécaud	32053	2022-05-12	0
Ensemble P.A.N. (Project Ars Nova)	32054	2022-05-12	0
Evile	32055	2022-05-12	0
Skink	32056	2022-05-12	0
Scottish Chamber Orchestra/Jukka-Pekka Saraste	32057	2022-05-12	0
Natural History feat. Joe Morris	32058	2022-05-12	0
Aled Jones	32059	2022-05-12	0
Stone Sour	32060	2022-05-12	0
Tarot	32061	2022-05-12	0
Rick James	32062	2022-05-12	0
Oxygenfad	32063	2022-05-12	0
Lionel Rogg	32064	2022-05-12	0
Dogzuki	32065	2022-05-12	0
Ron Goodwin	32066	2022-05-12	0
The White Stripes	32067	2022-05-12	0
Andrea Echeverri	32068	2022-05-12	0
Mistah F.A.B ft.E40_  Mac Dre_ Messy Marv_ Yukmouth_ Mac Mall_ Mr. Kee_ Various Otheres	32069	2022-05-12	0
Josephine Premice	32070	2022-05-12	0
Threat Signal	32071	2022-05-12	0
The Muffins	32072	2022-05-12	0
Billie Davis	32073	2022-05-12	0
Tomas Ledin	32074	2022-05-12	0
This Is The Kit	32075	2022-05-12	0
Chariot	32076	2022-05-12	0
Gerald Clayton	32077	2022-05-12	0
Duplex	32078	2022-05-12	0
Harpo	32079	2022-05-12	0
Joe Vasconcellos	32080	2022-05-12	0
Maureen McGovern;Mike Renzi	32081	2022-05-12	0
Cast	32082	2022-05-12	0
We've Got A Fuzzbox and We're Gonna Use It	32083	2022-05-12	0
Niccolò Fabi	32084	2022-05-12	0
Robyn Hitchcock	32085	2022-05-12	0
Goat	32086	2022-05-12	0
Nanette Natal	32087	2022-05-12	0
Avril Lavigne	32088	2022-05-12	0
The Get Up Kids	32089	2022-05-12	0
Greg Weeks	32090	2022-05-12	0
Valerie Simpson	32091	2022-05-12	0
Digable Planets	32092	2022-05-12	0
Da Lata	32093	2022-05-12	0
The Gift	32094	2022-05-12	0
Fightstar	32095	2022-05-12	0
Kurt Masur	32096	2022-05-12	0
Arcana	32097	2022-05-12	0
Echoes Of Eternity	32098	2022-05-12	0
Talla 2XLC feat. Ely	32099	2022-05-12	0
Dub Pistols	32100	2022-05-12	0
Tommy Dorsey & His Orchestra	32101	2022-05-12	0
The Evaluation	32102	2022-05-12	0
The Poppees	32103	2022-05-12	0
King Creosote with James Yorkston	32104	2022-05-12	0
The Elms	32105	2022-05-12	0
Michael Hoenig	32106	2022-05-12	0
Conya Doss	32107	2022-05-12	0
Da Juve	32108	2022-05-12	0
Perry Blake	32109	2022-05-12	0
Vitamin C	32110	2022-05-12	0
Vivian Girls	32111	2022-05-12	0
Get Low Playaz	32112	2022-05-12	0
Toni Basil	32113	2022-05-12	0
Dillard & Clark	32114	2022-05-12	0
Silversun Pickups	32115	2022-05-12	0
Larry Marshall	32116	2022-05-12	0
Kalaban	32117	2022-05-12	0
Otis Redding	32118	2022-05-12	0
James Carter	32119	2022-05-12	0
Chuy Reyes	32120	2022-05-12	0
J-Diggs & Rich The Factor	32121	2022-05-12	0
Freddie Mercury	32122	2022-05-12	0
Cute Is What We Aim For	32123	2022-05-12	0
Grum	32124	2022-05-12	0
Swat-Squad	32125	2022-05-12	0
Mikki Koloski	32126	2022-05-12	0
Wayne Potash	32127	2022-05-12	0
Akimbo	32128	2022-05-12	0
Dr. John & The Lower 911	32129	2022-05-12	0
Ramses	32130	2022-05-12	0
Richard Grey Vs. Bob Marley	32131	2022-05-12	0
Rated R	32132	2022-05-12	0
tsurubami	32133	2022-05-12	0
Sofia National Opera House Orchestra And Chorus	32134	2022-05-12	0
2Pac featuring Val Young	32135	2022-05-12	0
Soulive	32136	2022-05-12	0
Pati Yang	32137	2022-05-12	0
Christopher Willits	32138	2022-05-12	0
Fredericks_ Goldman_ Jones	32139	2022-05-12	0
Zeltinger Band	32140	2022-05-12	0
Trist	32141	2022-05-12	0
Marco Carta	32142	2022-05-12	0
DJ Bobo	32143	2022-05-12	0
Sui Generis	32144	2022-05-12	0
Rasha	32145	2022-05-12	0
Eugene Ormandy	32146	2022-05-12	0
The Edgar Winter Group	32147	2022-05-12	0
The Subways	32148	2022-05-12	0
EPMD	32149	2022-05-12	0
Ondina Sannino & Riccardo Distasi	32150	2022-05-12	0
Floh De Cologne	32151	2022-05-12	0
Aceyalone	32152	2022-05-12	0
Origin Unknown	32153	2022-05-12	0
Chris De Burgh	32154	2022-05-12	0
Amuka	32155	2022-05-12	0
Dynamix Featuring Inda Matrix	32156	2022-05-12	0
Steffen Basho-Junghans	32157	2022-05-12	0
Efdemin	32158	2022-05-12	0
Soulgate's Dawn	32159	2022-05-12	0
Ruby Turner	32160	2022-05-12	0
The Agony Scene	32161	2022-05-12	0
Novos Baianos	32162	2022-05-12	0
LOCK UP	32163	2022-05-12	0
Chaotic Alliance	32164	2022-05-12	0
Jakob Dylan	32165	2022-05-12	0
Mr. Peppa	32166	2022-05-12	0
Dead Ant Farm	32167	2022-05-12	0
Ms. Jade	32168	2022-05-12	0
Stanley Jordan	32169	2022-05-12	0
Henri Pousseur	32170	2022-05-12	0
Cleopatra	32171	2022-05-12	0
Exhumed	32172	2022-05-12	0
Iggy Pop	32173	2022-05-12	0
Justin Hayford	32174	2022-05-12	0
Shazz	32175	2022-05-12	0
Circus Maximus	32176	2022-05-12	0
Kenny G featuring Bebel Gilberto	32177	2022-05-12	0
Miracle Chosuke	32178	2022-05-12	0
Itchy Poopzkid	32179	2022-05-12	0
OT Quartet	32180	2022-05-12	0
8om	32181	2022-05-12	0
JoAnn Campbell	32182	2022-05-12	0
Deus Ex Machina	32183	2022-05-12	0
Change	32184	2022-05-12	0
Darren Emerson	32185	2022-05-12	0
Roebeck	32186	2022-05-12	0
Fanfarlo	32187	2022-05-12	0
Enrique Quezadas	32188	2022-05-12	0
The Twilight Singers	32189	2022-05-12	0
Jonell Mosser	32190	2022-05-12	0
George Williams	32191	2022-05-12	0
MC Sadri	32192	2022-05-12	0
The Gym Rats	32193	2022-05-12	0
BB Brunes	32194	2022-05-12	0
Medine	32195	2022-05-12	0
Teddy Geiger	32196	2022-05-12	0
Sleepy Sun	32197	2022-05-12	0
Steve Howe	32198	2022-05-12	0
Happy Family	32199	2022-05-12	0
Charlie	32200	2022-05-12	0
Angelus Apatrida	32201	2022-05-12	0
Nana Caymmi	32202	2022-05-12	0
Gabriel Le Mar	32203	2022-05-12	0
The Darling Buds	32204	2022-05-12	0
Bascom Lamar Lunsford	32205	2022-05-12	0
The Black Keys	32206	2022-05-12	0
Charanga Colonial	32207	2022-05-12	0
Pluto Project	32208	2022-05-12	0
Michael Fredo	32209	2022-05-12	0
Jamelia	32210	2022-05-12	0
We Are Terrorists	32211	2022-05-12	0
Winterborn	32212	2022-05-12	0
Tommy Smith	32213	2022-05-12	0
Karizma	32214	2022-05-12	0
Billy Dalessandro	32215	2022-05-12	0
Waddie Mitchell	32216	2022-05-12	0
Clay Walker	32217	2022-05-12	0
David "Honeyboy" Edwards	32218	2022-05-12	0
Alternative TV	32219	2022-05-12	0
Lordi	32220	2022-05-12	0
Streetlight Manifesto	32221	2022-05-12	0
Manolo Sanlucar / Agustin Fernandez	32222	2022-05-12	0
Los Twang Marvels	32223	2022-05-12	0
The Pop Group	32224	2022-05-12	0
C-Rayz Walz	32225	2022-05-12	0
Simon Webbe	32226	2022-05-12	0
Hoots & Hellmouth	32227	2022-05-12	0
Dyablo	32228	2022-05-12	0
The Ziggens	32229	2022-05-12	0
Crux	32230	2022-05-12	0
Cristal Snow	32231	2022-05-12	0
Toxpack	32232	2022-05-12	0
Bouncing Souls	32233	2022-05-12	0
Furthest From the Star	32234	2022-05-12	0
Damage Featuring MC Romeo	32235	2022-05-12	0
KiEw	32236	2022-05-12	0
Neobe_ Adani & Wolf	32237	2022-05-12	0
The Chambers Brothers	32238	2022-05-12	0
Lhasa De Sela	32239	2022-05-12	0
George Jones & Tammy Wynette	32240	2022-05-12	0
Peer Günt	32241	2022-05-12	0
Johnny Wakelin	32242	2022-05-12	0
Gonads	32243	2022-05-12	0
The Munros_David Methven	32244	2022-05-12	0
Karl Denson's Tiny Universe	32245	2022-05-12	0
Regurgitate	32246	2022-05-12	0
Ina Deter	32247	2022-05-12	0
Ionic Vision	32248	2022-05-12	0
Jasbir Jassi	32249	2022-05-12	0
William Lee Ellis	32250	2022-05-12	0
Anna Meliti	32251	2022-05-12	0
Carmen Amaya_ Carmen Amaya_ Paco Amaya_ José Amaya	32252	2022-05-12	0
The Flowers Of Hell	32253	2022-05-12	0
Bond	32254	2022-05-12	0
Sara Martin	32255	2022-05-12	0
Michael Brecker	32256	2022-05-12	0
Tom Principato	32257	2022-05-12	0
Summer Channel	32258	2022-05-12	0
Sera	32259	2022-05-12	0
Lee Perry	32260	2022-05-12	0
The Karminsky Experience Inc.	32261	2022-05-12	0
Gerardo Reyes	32262	2022-05-12	0
Parzivals Eye	32263	2022-05-12	0
NB Ridaz	32264	2022-05-12	0
MADISON	32265	2022-05-12	0
Sofi Bonde	32266	2022-05-12	0
Diskjokke	32267	2022-05-12	0
Andy Stochansky	32268	2022-05-12	0
Captain Jack	32269	2022-05-12	0
Head Like a Kite	32270	2022-05-12	0
Slapp Happy	32271	2022-05-12	0
Master Chorale of Washington Chamber Singers	32272	2022-05-12	0
Gak Sato	32273	2022-05-12	0
Maria	32274	2022-05-12	0
Caliban_ Heaven Shall Burn	32275	2022-05-12	0
Music Go Music	32276	2022-05-12	0
Manjul	32277	2022-05-12	0
Fito Olivares	32278	2022-05-12	0
Basic Vocab	32279	2022-05-12	0
Mable John	32280	2022-05-12	0
Ronnie Davis	32281	2022-05-12	0
Tim Hecker	32282	2022-05-12	0
This Vision	32283	2022-05-12	0
Xtatik / Burning Flames	32284	2022-05-12	0
Paolo Conte	32285	2022-05-12	0
Bass Unlimited	32286	2022-05-12	0
Ciccolini_ Aldo / Tacchino_ Gabriel	32287	2022-05-12	0
Dream Warriors	32288	2022-05-12	0
Immoral Monkeys	32289	2022-05-12	0
Remember Remember	32290	2022-05-12	0
Lucky Peterson	32291	2022-05-12	0
The Mitchell Brothers	32292	2022-05-12	0
Theory Hazit	32293	2022-05-12	0
Michael Rose + Sly & Robbie	32294	2022-05-12	0
Mr. Oizo	32295	2022-05-12	0
ZZ Top	32296	2022-05-12	0
Elizabeth Fraser	32297	2022-05-12	0
Onra	32298	2022-05-12	0
Trisco	32299	2022-05-12	0
Atllas	32300	2022-05-12	0
F-Minus	32301	2022-05-12	0
Montserrat Caballé	32302	2022-05-12	0
Thomas Function	32303	2022-05-12	0
Lady Saw	32304	2022-05-12	0
Spencer Bohren	32305	2022-05-12	0
Sierra Hull	32306	2022-05-12	0
Yellowman & Fathead	32307	2022-05-12	0
Jakalope	32308	2022-05-12	0
The Classic Crime	32309	2022-05-12	0
Natur'Al & Lucia	32310	2022-05-12	0
Funky	32311	2022-05-12	0
Patrick Zigon	32312	2022-05-12	0
Swingin' Utters	32313	2022-05-12	0
Garnett Silk (feat. Tony Rebel)	32314	2022-05-12	0
Kristy Lee Cook	32315	2022-05-12	0
Atach Tatuq	32316	2022-05-12	0
Jerryl	32317	2022-05-12	0
Youth Brigade	32318	2022-05-12	0
The Workhouse	32319	2022-05-12	0
Dof	32320	2022-05-12	0
Collins_ Bootsy	32321	2022-05-12	0
Stereo MCs	32322	2022-05-12	0
Ulysses	32323	2022-05-12	0
David Guetta - Joachim Garraud	32324	2022-05-12	0
Pantha Du Prince	32325	2022-05-12	0
Playmates	32326	2022-05-12	0
Ill Lit	32327	2022-05-12	0
Chris Isaak	32328	2022-05-12	0
Jim Rivers	32329	2022-05-12	0
Daryll-Ann	32330	2022-05-12	0
Nathalie Tineo	32331	2022-05-12	0
Donnie Elbert	32332	2022-05-12	0
McMenace	32333	2022-05-12	0
Dan Brodie	32334	2022-05-12	0
Banco De Gaia	32335	2022-05-12	0
David Tao	32336	2022-05-12	0
ATB	32337	2022-05-12	0
Harry James & His Orchestra	32338	2022-05-12	0
Motek	32339	2022-05-12	0
Shrimp Boat	32340	2022-05-12	0
FOREVER LIKE RED	32341	2022-05-12	0
7th Heaven	32342	2022-05-12	0
Doves	32343	2022-05-12	0
The Heavenly States	32344	2022-05-12	0
UNKLE Feat. Josh Homme	32345	2022-05-12	0
Aura	32346	2022-05-12	0
Clannad	32347	2022-05-12	0
Kellie Pickler	32348	2022-05-12	0
Billy Porter	32349	2022-05-12	0
Andi Vax & Sergi Bits	32350	2022-05-12	0
Seija Simola	32351	2022-05-12	0
Kai Winding	32352	2022-05-12	0
Os Gaiteiros de Soutelo	32353	2022-05-12	0
Afu-Ra	32354	2022-05-12	0
Chymera	32355	2022-05-12	0
Chambers Brothers	32356	2022-05-12	0
Allen Ginsberg	32357	2022-05-12	0
Esmerine	32358	2022-05-12	0
Curious	32359	2022-05-12	0
Menno De Jong & Leon Bolier	32360	2022-05-12	0
Ace Moreland	32361	2022-05-12	0
The Bluestation	32362	2022-05-12	0
Perception	32363	2022-05-12	0
Juanes	32364	2022-05-12	0
Michael Salgado	32365	2022-05-12	0
Johnny Lee	32366	2022-05-12	0
Siria	32367	2022-05-12	0
Little Claw	32368	2022-05-12	0
Tara Perdida	32369	2022-05-12	0
Lester Flatt / Earl Scruggs / The Foggy Mountain Boys	32370	2022-05-12	0
Tin Machine	32371	2022-05-12	0
Jorge Ben	32372	2022-05-12	0
Surface (feat. Tony Prescott)	32373	2022-05-12	0
Lunasicc	32374	2022-05-12	0
Buraka Som Sistema featuring Pongolove	32375	2022-05-12	0
Bernard Lavilliers	32376	2022-05-12	0
Luca Antolini_ Marzio Dance	32377	2022-05-12	0
Too $hort featuring Devin The Dude & Cutty Cartel	32378	2022-05-12	0
Balligomingo	32379	2022-05-12	0
The Twinkle Brothers	32380	2022-05-12	0
Thomas 'Fats' Waller	32381	2022-05-12	0
Brahim	32382	2022-05-12	0
Yngwie Malmsteen	32383	2022-05-12	0
The Melismatics	32384	2022-05-12	0
The Adolescents	32385	2022-05-12	0
Plank!	32386	2022-05-12	0
Taking Dawn	32387	2022-05-12	0
Kieran Goss	32388	2022-05-12	0
Satin Whale	32389	2022-05-12	0
Tony Mathews	32390	2022-05-12	0
Jackyl	32391	2022-05-12	0
Sleeping Beauty	32392	2022-05-12	0
Seelenkrank	32393	2022-05-12	0
Anton Dvorák	32394	2022-05-12	0
HORKYZE SLIZE	32395	2022-05-12	0
We Five	32396	2022-05-12	0
Ike Turner & The Kings Of Rhythm	32397	2022-05-12	0
Laurie Sargent	32398	2022-05-12	0
The Jive Turkeys	32399	2022-05-12	0
Cara Dillon	32400	2022-05-12	0
Todd Wolfe	32401	2022-05-12	0
Clann Zu	32402	2022-05-12	0
California Oranges	32403	2022-05-12	0
Frederik	32404	2022-05-12	0
Enuff Z'Nuff	32405	2022-05-12	0
Zegunder	32406	2022-05-12	0
Roger Chapman	32407	2022-05-12	0
Satish Vyas	32408	2022-05-12	0
Shenandoah	32409	2022-05-12	0
TR	32410	2022-05-12	0
Cypress Hill	32411	2022-05-12	0
Leon Berry	32412	2022-05-12	0
Vincenzo & Joel Mull	32413	2022-05-12	0
Doug Folkins	32414	2022-05-12	0
Les Baxter	32415	2022-05-12	0
Capitol Eye	32416	2022-05-12	0
G-Dub	32417	2022-05-12	0
Juice & Molemen	32418	2022-05-12	0
Jean Jacques Perrey	32419	2022-05-12	0
Don Diablo	32420	2022-05-12	0
Bjørn Svin	32421	2022-05-12	0
Moraes Moreira	32422	2022-05-12	0
Deportees	32423	2022-05-12	0
The Priscillas	32424	2022-05-12	0
Cherie	32425	2022-05-12	0
Red Nichols and His 5 Pennies	32426	2022-05-12	0
Louis Armstrong Hot Seven;Carroll Dickerson Orchestra	32427	2022-05-12	0
Martha Redbone	32428	2022-05-12	0
Tim O'Reagan	32429	2022-05-12	0
The Donnas	32430	2022-05-12	0
Bell X1	32431	2022-05-12	0
DJ Cutlass Supreme	32432	2022-05-12	0
Junior Wells	32433	2022-05-12	0
Strauss	32434	2022-05-12	0
Da Youngsta's	32435	2022-05-12	0
Universal Poplab	32436	2022-05-12	0
Diabolical Masquerade	32437	2022-05-12	0
The O'Jays	32438	2022-05-12	0
Software	32439	2022-05-12	0
Jelly Roll Morton	32440	2022-05-12	0
999	32441	2022-05-12	0
Eden Brent	32442	2022-05-12	0
Letoya	32443	2022-05-12	0
Los Straitjackets	32444	2022-05-12	0
East To West	32445	2022-05-12	0
infinity	32446	2022-05-12	0
B³+	32447	2022-05-12	0
Omarion	32448	2022-05-12	0
Ryukyu Underground	32449	2022-05-12	0
Funky DL	32450	2022-05-12	0
Angélica María	32451	2022-05-12	0
Pat McGee	32452	2022-05-12	0
The Original Mark Edwards	32453	2022-05-12	0
Conjunto Mar Azul	32454	2022-05-12	0
The Curses	32455	2022-05-12	0
Life Without Buildings	32456	2022-05-12	0
Miguel de los Reyes - José Manuel Roldán	32457	2022-05-12	0
Jay Pérez	32458	2022-05-12	0
Pucho & His Latin Soul Brothers	32459	2022-05-12	0
Jimmy Dawkins	32460	2022-05-12	0
Kristian Beck	32461	2022-05-12	0
Bachman-Turner Overdrive	32462	2022-05-12	0
2 much!	32463	2022-05-12	0
Bitter End	32464	2022-05-12	0
Adam Ray	32465	2022-05-12	0
The House Of Love	32466	2022-05-12	0
Spacecat Vs Dj Dede	32467	2022-05-12	0
Los Humildes	32468	2022-05-12	0
Johnny Thunders & The Heartbreakers	32469	2022-05-12	0
Michelle Tumes_ Susan Ashton And Christine Dente	32470	2022-05-12	0
Guitar Slim	32471	2022-05-12	0
Harry Choo Choo Romero And Juan Diaz	32472	2022-05-12	0
PIERPOLJAK	32473	2022-05-12	0
Arthur Crudup	32474	2022-05-12	0
Carter USM	32475	2022-05-12	0
George Vemag	32476	2022-05-12	0
Lester Bowie_ Ari Brown_ Art Matthews_ Fred Williams_ Phillip Wilson_ Fontella Bass_ David Peaston	32477	2022-05-12	0
Groove Junkies feat. TC Moses	32478	2022-05-12	0
Oneiroid Psychosis	32479	2022-05-12	0
Dan Le Sac vs Scroobius Pip	32480	2022-05-12	0
Meganoidi	32481	2022-05-12	0
Aztec Camera	32482	2022-05-12	0
Mouthus	32483	2022-05-12	0
Red House Painters	32622	2022-05-12	0
Marshmallow Coast	32623	2022-05-12	0
Del Tha Funkee Homosapien feat. Q-Tip of A Tribe Called Quest & Peplove of Peplove & Jay-Biz	32484	2022-05-12	0
Denez Prigent	32485	2022-05-12	0
Brew Ramson	32486	2022-05-12	0
Wibutee	32487	2022-05-12	0
Clouseau	32488	2022-05-12	0
Dead Kennedys	32489	2022-05-12	0
Head Hits Concrete	32490	2022-05-12	0
Sharam Jey	32491	2022-05-12	0
Galahad	32492	2022-05-12	0
Depswa	32493	2022-05-12	0
Climax	32494	2022-05-12	0
Nailbomb	32495	2022-05-12	0
Mike Mikhjian	32496	2022-05-12	0
Felipe Dylon	32497	2022-05-12	0
Misery Speaks	32498	2022-05-12	0
The Romantics	32499	2022-05-12	0
The Supermen Lovers	32500	2022-05-12	0
The Metros	32501	2022-05-12	0
Mink DeVille	32502	2022-05-12	0
No Cash	32503	2022-05-12	0
Def Squad	32504	2022-05-12	0
The Letter Black	32505	2022-05-12	0
Palov & Mishkin	32506	2022-05-12	0
Mucc	32507	2022-05-12	0
Milos	32508	2022-05-12	0
Shout Wellington Air Force	32509	2022-05-12	0
Monotones	32510	2022-05-12	0
Carpathian Forest	32511	2022-05-12	0
Akcent	32512	2022-05-12	0
UGK featuring Kool Ace & Too Short	32513	2022-05-12	0
Frantic Bleep	32514	2022-05-12	0
Spor	32515	2022-05-12	0
Anata	32516	2022-05-12	0
Henrik Olesen	32517	2022-05-12	0
Mr Knightowl	32518	2022-05-12	0
Lesbians On Ecstasy	32519	2022-05-12	0
Monty Alexander / Ray Brown / Herb Ellis	32520	2022-05-12	0
HorrorPops	32521	2022-05-12	0
Buell Kazee	32522	2022-05-12	0
Ivan Ferreiro	32523	2022-05-12	0
Amon Amarth	32524	2022-05-12	0
Danny Byrd Featuring ReDD	32525	2022-05-12	0
Gianna Nannini	32526	2022-05-12	0
Ivor Slaney	32527	2022-05-12	0
Madcon	32528	2022-05-12	0
Uncle Tupelo	32529	2022-05-12	0
David Essex	32530	2022-05-12	0
Jimmy Webb	32531	2022-05-12	0
LA Guns	32532	2022-05-12	0
Gimmel	32533	2022-05-12	0
Eric Carmen	32534	2022-05-12	0
Darren Tate	32535	2022-05-12	0
Fernando Samalea	32536	2022-05-12	0
The O.A.O.T's	32537	2022-05-12	0
Memória do Samba Paulista	32538	2022-05-12	0
Kingspade	32539	2022-05-12	0
Louie Austen	32540	2022-05-12	0
Spike Jones & His City Slickers	32541	2022-05-12	0
Scottish Chamber Orchestra	32542	2022-05-12	0
Alexandroid	32543	2022-05-12	0
Cannonball Adderley Quintet	32544	2022-05-12	0
Newtown Neurotics	32545	2022-05-12	0
112	32546	2022-05-12	0
Longview	32547	2022-05-12	0
Spencer Brewer	32548	2022-05-12	0
Kleiton & Kledir	32549	2022-05-12	0
K.ommando Toxik	32550	2022-05-12	0
Asphalt Jungle	32551	2022-05-12	0
Astrud Gilberto with Stanley Turrentine	32552	2022-05-12	0
Johnny Long	32553	2022-05-12	0
Heavy D	32554	2022-05-12	0
Joe Strummer And The Mescaleros	32555	2022-05-12	0
Sebastien Schuller	32556	2022-05-12	0
Zen Guerrilla	32557	2022-05-12	0
Moqui Marbles feat. Pyranja	32558	2022-05-12	0
Hatiras_ DJ Dan Feat. Mandy J	32559	2022-05-12	0
Small Facers	32560	2022-05-12	0
Rachel Stevens	32561	2022-05-12	0
Lester Flatt & Earl Scruggs	32562	2022-05-12	0
Ninth Circle	32563	2022-05-12	0
Mic Geronimo	32564	2022-05-12	0
Patty Loveless	32565	2022-05-12	0
Alexander Robotnick	32566	2022-05-12	0
Mechanical Cabaret	32567	2022-05-12	0
Solitaire Feat. Shena	32568	2022-05-12	0
Drag-On Featuring Baby and TQ	32569	2022-05-12	0
Show Of Hands	32570	2022-05-12	0
Laura Voutilainen	32571	2022-05-12	0
Steve Harvey	32572	2022-05-12	0
Compulsive Gamblers	32573	2022-05-12	0
Marc Ford	32574	2022-05-12	0
Sammi Smith	32575	2022-05-12	0
Bola De Nieve	32576	2022-05-12	0
Edie Brickell	32577	2022-05-12	0
Little Junior's Blue Flames	32578	2022-05-12	0
Alexia	32579	2022-05-12	0
Swingfly	32580	2022-05-12	0
Didier Sinclair & Chris Pi	32581	2022-05-12	0
Cud	32582	2022-05-12	0
Magnatiz	32583	2022-05-12	0
Argy Bargy	32584	2022-05-12	0
Van Halen	32585	2022-05-12	0
The Redwalls	32586	2022-05-12	0
Trueby Trio	32587	2022-05-12	0
The Color Morale	32588	2022-05-12	0
Enrico Macias	32589	2022-05-12	0
Saccharine Trust	32590	2022-05-12	0
Coolio	32591	2022-05-12	0
Bill Quinn	32592	2022-05-12	0
Os Travessos	32593	2022-05-12	0
Cardenales del Exito	32594	2022-05-12	0
Pulp Victim	32595	2022-05-12	0
A-Zone	32596	2022-05-12	0
Phonat	32597	2022-05-12	0
Move D & Benjamin Brunn	32598	2022-05-12	0
Art Lande_ Jan Garbarek	32599	2022-05-12	0
Laurent & Lewis_ Aaron-Carl	32600	2022-05-12	0
Anna Abreu	32601	2022-05-12	0
SUCH A SURGE	32602	2022-05-12	0
Riley Puckett	32603	2022-05-12	0
Trudy Lynn	32604	2022-05-12	0
Our Last Night	32605	2022-05-12	0
Cimarons	32606	2022-05-12	0
Rip Van Hippy	32607	2022-05-12	0
Smash hit combo	32608	2022-05-12	0
Lemon	32609	2022-05-12	0
Kristian Leontiou	32610	2022-05-12	0
David Evans	32611	2022-05-12	0
Rockabye Baby!	32612	2022-05-12	0
Noisuf-X	32613	2022-05-12	0
Junk Science	32614	2022-05-12	0
The Glorious Unseen	32615	2022-05-12	0
Transient Waves	32616	2022-05-12	0
Brigitte Fontaine	32617	2022-05-12	0
Th' Legendary Shack-Shakers	32618	2022-05-12	0
Spoken	32619	2022-05-12	0
Francis Lai	32620	2022-05-12	0
Adriana Evans	32621	2022-05-12	0
Anita Lipnicka	32624	2022-05-12	0
Flanders	32625	2022-05-12	0
Mutual Admiration Society	32626	2022-05-12	0
The Dirty Ones	32627	2022-05-12	0
Hanson	32628	2022-05-12	0
American Hi-Fi	32629	2022-05-12	0
The Honley Male Voice Choir/The Band Of HM Royal Marines	32630	2022-05-12	0
Northside	32631	2022-05-12	0
Stage Bottles	32632	2022-05-12	0
Shelleyan Orphan	32633	2022-05-12	0
Dying Fetus	32634	2022-05-12	0
Pedro Padilla Y Su Conjunto	32635	2022-05-12	0
Ocelot	32636	2022-05-12	0
Distant Soundz vs. Disko Punks	32637	2022-05-12	0
Roll Deep	32638	2022-05-12	0
Camper Van Beethoven	32639	2022-05-12	0
Jo Boxers	32640	2022-05-12	0
Lal Chand Yamla Jatt	32641	2022-05-12	0
Shabazz The Disciple	32642	2022-05-12	0
Titus Andronicus	32643	2022-05-12	0
Frøya	32644	2022-05-12	0
Martine Girault	32645	2022-05-12	0
Zoot Woman	32646	2022-05-12	0
Chiasm	32647	2022-05-12	0
Grand Ulena	32648	2022-05-12	0
Reaxion Guerrilla	32649	2022-05-12	0
BumBum	32650	2022-05-12	0
Roger Daltrey	32651	2022-05-12	0
Kirsty MacColl	32652	2022-05-12	0
Peter Sarstedt	32653	2022-05-12	0
Seymour	32654	2022-05-12	0
The Bridal Shop	32655	2022-05-12	0
David Hudson	32656	2022-05-12	0
Johnny Gill	32657	2022-05-12	0
Kool Savas & Mr. Man	32658	2022-05-12	0
Sea of Green	32659	2022-05-12	0
D-12 / Eminem	32660	2022-05-12	0
Edwin Starr	32661	2022-05-12	0
The Hollies	32662	2022-05-12	0
Electro Mode Inc.	32663	2022-05-12	0
2Fabiola	32664	2022-05-12	0
Kokomo Arnold	32665	2022-05-12	0
Roger Miller	32666	2022-05-12	0
Simon Cooper	32667	2022-05-12	0
Kitaro	32668	2022-05-12	0
Vicente Amigo	32669	2022-05-12	0
Robert Calvert	32670	2022-05-12	0
Edith Piaf	32671	2022-05-12	0
Younger Brother	32672	2022-05-12	0
Combichrist	32673	2022-05-12	0
Minuta Ticha	32674	2022-05-12	0
DJ Orkidea	32675	2022-05-12	0
Sylvia Striplin	32676	2022-05-12	0
Brixx & Casus Belli	32677	2022-05-12	0
Les Blérots De R.A.V.E.L	32678	2022-05-12	0
Hipsway	32679	2022-05-12	0
James Getzoff	32680	2022-05-12	0
The High Wire	32681	2022-05-12	0
Chief Kamachi and the Ju Ju mob	32682	2022-05-12	0
Sirius Isness	32683	2022-05-12	0
Ché-Fu	32684	2022-05-12	0
Daniel Chan	32685	2022-05-12	0
Donald Byrd	32686	2022-05-12	0
Machines Don't Care	32687	2022-05-12	0
Groundation	32688	2022-05-12	0
Melody Gardot	32689	2022-05-12	0
Aventuras De Kirlian	32690	2022-05-12	0
Material	32691	2022-05-12	0
Barren Cross	32692	2022-05-12	0
Peaches & Herb	32693	2022-05-12	0
Son Of Dork	32694	2022-05-12	0
Deepak Ram	32695	2022-05-12	0
Skitzo	32696	2022-05-12	0
Front 242	32697	2022-05-12	0
Black Sheep	32698	2022-05-12	0
Wires On Fire	32699	2022-05-12	0
Oz Noy	32700	2022-05-12	0
David Scott	32701	2022-05-12	0
Massive Attack	32702	2022-05-12	0
Mike Doughty	32703	2022-05-12	0
Forbidden	32704	2022-05-12	0
Rip Rig & Panic	32705	2022-05-12	0
Hawkwind	32706	2022-05-12	0
King Curtis with Jack Dupree	32707	2022-05-12	0
Egor Boss	32708	2022-05-12	0
Derek & Clive	32709	2022-05-12	0
Jesse McCartney	32710	2022-05-12	0
The Bluebells	32711	2022-05-12	0
Luis Enrique	32712	2022-05-12	0
Connee Boswell & Sy Oliver Orchestra	32713	2022-05-12	0
Rui Veloso	32714	2022-05-12	0
Hepcat	32715	2022-05-12	0
The Misfits	32716	2022-05-12	0
The RH Factor feat. Reuben Hoch	32717	2022-05-12	0
Nina Sky / Betty Wright	32718	2022-05-12	0
Swing Out Sister	32719	2022-05-12	0
Tramaine Hawkins	32720	2022-05-12	0
Suff Daddy feat. Miles Bonny	32721	2022-05-12	0
Marc Marberg With Kyau & Albert	32722	2022-05-12	0
Lucien	32723	2022-05-12	0
Lee Dorsey	32724	2022-05-12	0
George Formby	32725	2022-05-12	0
Moderat	32726	2022-05-12	0
Joe Glazer	32727	2022-05-12	0
Henry Rollins	32728	2022-05-12	0
Mothergroove	32729	2022-05-12	0
Chris Connor	32730	2022-05-12	0
The Awesome Machine	32731	2022-05-12	0
Wilshire	32732	2022-05-12	0
Magneto	32733	2022-05-12	0
Dinah Shore_ Harry Zimmerman Orchestra	32734	2022-05-12	0
Deadlock	32735	2022-05-12	0
Chris Brown featuring Kanye West	32736	2022-05-12	0
Don Yute	32737	2022-05-12	0
Kriipis Tulo	32738	2022-05-12	0
The Shapeshifters	32739	2022-05-12	0
The Disco Boys	32740	2022-05-12	0
Bass Factory 808	32741	2022-05-12	0
Lloyd Spiegel	32742	2022-05-12	0
The Pooh Sticks	32743	2022-05-12	0
Billy Bremner	32744	2022-05-12	0
Mista Bourne	32745	2022-05-12	0
Wasted Youth	32746	2022-05-12	0
Course Of Nature	32747	2022-05-12	0
Texas Faggott	32748	2022-05-12	0
A.B. Quintanilla's All Starz	32749	2022-05-12	0
Snog	32750	2022-05-12	0
Descend To Rise	32751	2022-05-12	0
The Lovemakers	32752	2022-05-12	0
K Spécial	32753	2022-05-12	0
Max Steiner	32754	2022-05-12	0
Brontosaurus Chorus	32755	2022-05-12	0
Loleatta Holloway	32756	2022-05-12	0
Adolf & The Piss Artists	32757	2022-05-12	0
DJ Solano	32758	2022-05-12	0
Captain Barkey	32759	2022-05-12	0
Michal Urbaniak	32760	2022-05-12	0
Love Joys	32761	2022-05-12	0
Heinrich Ignaz Franz von Biber	32762	2022-05-12	0
The Disposable Heroes Of Hiphoprisy	32763	2022-05-12	0
Midi Miliz	32764	2022-05-12	0
Juliet Roberts	32765	2022-05-12	0
Fondo Flamenco	32766	2022-05-12	0
EPMD / Redman / Keith Murray	32767	2022-05-12	0
The Strange Fruit Project	32768	2022-05-12	0
Francis Chan	32769	2022-05-12	0
My Little Pony	32770	2022-05-12	0
New Philharmonia Orchestra	32771	2022-05-12	0
Kalafut_Fygle	32772	2022-05-12	0
Sean Finn And Miss Candy Featuring Lucille	32773	2022-05-12	0
Nappy Roots [featuring Marcos of P.O.D.]	32774	2022-05-12	0
Debbie Deb	32775	2022-05-12	0
Doctor (Peter) Clayton	32776	2022-05-12	0
Mario Rosenstock	32777	2022-05-12	0
Maurizio Pollini	32778	2022-05-12	0
Demis Roussos	32779	2022-05-12	0
Expresión Joven	32780	2022-05-12	0
Niños Mutantes	32781	2022-05-12	0
Diana Navarro	32782	2022-05-12	0
Race Horses	32783	2022-05-12	0
B.C. Camplight	32784	2022-05-12	0
Sivuca	32785	2022-05-12	0
Jackie Davis	32786	2022-05-12	0
Magic Sam	32787	2022-05-12	0
Hoods	32788	2022-05-12	0
Dorothy Love Coates_ The Original Gospel Harmonettes	32789	2022-05-12	0
Brownstone	32790	2022-05-12	0
Neil Innes	32791	2022-05-12	0
The Way-Goners	32792	2022-05-12	0
Dynamo Productions	32793	2022-05-12	0
Hutch Hensle	32794	2022-05-12	0
Over The Edge	32795	2022-05-12	0
Wild Strawberries	32796	2022-05-12	0
Funkmaster Flex / Big Kap / The Ruff Ryders	32797	2022-05-12	0
Barry Goldberg	32798	2022-05-12	0
Dumas	32799	2022-05-12	0
Missus Beastly	32800	2022-05-12	0
Pawtuckets	32801	2022-05-12	0
Bluezeum	32802	2022-05-12	0
Ivete Sangalo / Saulo Fernandes	32803	2022-05-12	0
cirKus feat. Neneh Cherry	32804	2022-05-12	0
Noize Suppressor	32805	2022-05-12	0
Hausmarke	32806	2022-05-12	0
Disgorge	32807	2022-05-12	0
Crosby_ Stills & Nash	32808	2022-05-12	0
Barry McGuire	32809	2022-05-12	0
Rondellus	32810	2022-05-12	0
Roj	32811	2022-05-12	0
Cool cavemen	32812	2022-05-12	0
Young Jeezy	32813	2022-05-12	0
Robert Leroy	32814	2022-05-12	0
Pterodactyl	32815	2022-05-12	0
Wide Awake	32816	2022-05-12	0
Sido Feat. Shizoe	32817	2022-05-12	0
Jaybird Coleman	32818	2022-05-12	0
The Cambridge Singers / John Rutter	32819	2022-05-12	0
Babe Ruth	32820	2022-05-12	0
Girlschool	32821	2022-05-12	0
Emilie Simon	32822	2022-05-12	0
Branford Marsalis Trio	32823	2022-05-12	0
Call To Preserve	32824	2022-05-12	0
John Gorka	32825	2022-05-12	0
Music Explosion	32826	2022-05-12	0
Kathy Mattea	32827	2022-05-12	0
Herbie Mann	32828	2022-05-12	0
Carlene Davis	32829	2022-05-12	0
Ann Beretta	32830	2022-05-12	0
July For Kings	32831	2022-05-12	0
The Fort Mudge Memorial Dump	32832	2022-05-12	0
Sainkho Namtchylak	32833	2022-05-12	0
Modeselektor Feat. Paul St. Hillaire	32834	2022-05-12	0
The Crash Motive	32835	2022-05-12	0
Weezer	32836	2022-05-12	0
Keri Leigh & The Blue Devils	32837	2022-05-12	0
Billy Currington	32838	2022-05-12	0
Aida Cuevas	32839	2022-05-12	0
Celia Cruz Y Sonora Matancera	32840	2022-05-12	0
Richard Nate	32841	2022-05-12	0
Lee Rocker	32842	2022-05-12	0
Bleep	32843	2022-05-12	0
Luca Carboni	32844	2022-05-12	0
Dr. Hook	32845	2022-05-12	0
Os Catalepticos	32846	2022-05-12	0
Endless Summer feat. Nikki	32847	2022-05-12	0
Million Dan	32848	2022-05-12	0
Dokken	32849	2022-05-12	0
Zucchero	32850	2022-05-12	0
Lalo Schifrin	32851	2022-05-12	0
Marc Antoine	32852	2022-05-12	0
Nestor Torres	32853	2022-05-12	0
The Aces	32854	2022-05-12	0
Neotropic	32855	2022-05-12	0
Sugafree featuring Sharon	32856	2022-05-12	0
Aarne Tenkanen	32857	2022-05-12	0
The Jessica Fletchers	32858	2022-05-12	0
Burnski	32859	2022-05-12	0
Hatebreed (int License)	32860	2022-05-12	0
Tim Besamusca featuring Three Faces	32861	2022-05-12	0
Lisa Loeb	32862	2022-05-12	0
Jane Morgan	32863	2022-05-12	0
Dinah Washington / Max Richter	32864	2022-05-12	0
Alaska In Winter	32865	2022-05-12	0
Obie Trice	32866	2022-05-12	0
my robot friend	32867	2022-05-12	0
Rise Ashen	32868	2022-05-12	0
Kurt Elling	32869	2022-05-12	0
Darker My Love	32870	2022-05-12	0
Voodoo & Serano	32871	2022-05-12	0
Johnny Pacheco	32872	2022-05-12	0
Modest Mussorgsky	32873	2022-05-12	0
B.O.B.	32874	2022-05-12	0
Los Indios Paraguayos	32875	2022-05-12	0
The Ronettes	32876	2022-05-12	0
Blue Mountain	32877	2022-05-12	0
Luigi Tenco	32878	2022-05-12	0
Niacin	32879	2022-05-12	0
Modern English	32880	2022-05-12	0
Swans	32881	2022-05-12	0
Six Feet Under	32882	2022-05-12	0
De Souza Feat. Shena	32883	2022-05-12	0
Tim Buckley	32884	2022-05-12	0
Don Henley	32885	2022-05-12	0
Sleepy Brown	32886	2022-05-12	0
Runrig	32887	2022-05-12	0
Metropolis	32888	2022-05-12	0
M83	32889	2022-05-12	0
Crown Heights	32890	2022-05-12	0
Keni Burke	32891	2022-05-12	0
Five Foot Thick	32892	2022-05-12	0
Iron And Wine	32893	2022-05-12	0
Noel	32894	2022-05-12	0
Wild Bunch	32895	2022-05-12	0
Vince Neil	32896	2022-05-12	0
David Arnold	32897	2022-05-12	0
Jag Panzer	32898	2022-05-12	0
Nia Peeples	32899	2022-05-12	0
The John Scofield Band	32900	2022-05-12	0
Plastic Boy	32901	2022-05-12	0
Joan Of Arc	32902	2022-05-12	0
Diana Ross	32903	2022-05-12	0
Ramon Tapia	32904	2022-05-12	0
Cedric Brooks	32905	2022-05-12	0
Garou	32906	2022-05-12	0
Killswitch Engage	32907	2022-05-12	0
Beatnik Termites	32908	2022-05-12	0
The Hope Conspiracy	32909	2022-05-12	0
We Are The Fallen	32910	2022-05-12	0
Giovanni Allevi	32911	2022-05-12	0
El Otro Yo	32912	2022-05-12	0
Barthezz	32913	2022-05-12	0
Mother Gong	32914	2022-05-12	0
Dubstar	32915	2022-05-12	0
Shelby Flint	32916	2022-05-12	0
Some Velvet Morning	32917	2022-05-12	0
All-4-One	32918	2022-05-12	0
Mighty Diamonds	32919	2022-05-12	0
Paolo Meneguzzi	32920	2022-05-12	0
The Philip Glass Ensemble	32921	2022-05-12	0
Aaron Lines	32922	2022-05-12	0
Kathy Kallick & The Little Big Band	32923	2022-05-12	0
Suns Of Arqa	32924	2022-05-12	0
Kari Bremnes & Ola Bremnes	32925	2022-05-12	0
Eurythmics	32926	2022-05-12	0
Art Zoyd	32927	2022-05-12	0
Sean Finn and Gipsy Brothers	32928	2022-05-12	0
Juan Valentin	32929	2022-05-12	0
Mother	32930	2022-05-12	0
Doyle Bramhall II & Smokestack	32931	2022-05-12	0
Tha Eastsidaz	32932	2022-05-12	0
Cirith Ungol	32933	2022-05-12	0
Etta James	32934	2022-05-12	0
Primitive Calculators	32935	2022-05-12	0
Buddha on the moon	32936	2022-05-12	0
Joe Lovano	32937	2022-05-12	0
IMMORTAL	32938	2022-05-12	0
Osibisa	32939	2022-05-12	0
Mathias Schaffhäuser feat. Rob Taylor	32940	2022-05-12	0
Twenty 4 Seven	32941	2022-05-12	0
Charlie Hall	32942	2022-05-12	0
Louis Hayes	32943	2022-05-12	0
Wavves	32944	2022-05-12	0
David & Steve Gordon	32945	2022-05-12	0
Cheryl Wheeler	32946	2022-05-12	0
Savath Y Savalas	32947	2022-05-12	0
Tom Ovans	32948	2022-05-12	0
Papa San	32949	2022-05-12	0
J.B.O.	32950	2022-05-12	0
Bernard Allison	32951	2022-05-12	0
Into Eternity	32952	2022-05-12	0
Radio Moscow	32953	2022-05-12	0
Razorlight	32954	2022-05-12	0
Room Eleven	32955	2022-05-12	0
Rene Ablaze	32956	2022-05-12	0
Sonny Simmons	32957	2022-05-12	0
The Jackson Southernaires	32958	2022-05-12	0
Vakill	32959	2022-05-12	0
Swirlies	32960	2022-05-12	0
Yanou feat. Liz	32961	2022-05-12	0
N-Dubz	32962	2022-05-12	0
The Sundays	32963	2022-05-12	0
SEX MACHINEGUNS	32964	2022-05-12	0
Danny Howells	32965	2022-05-12	0
Quantic	32966	2022-05-12	0
D*Note	32967	2022-05-12	0
Ben Weaver	32968	2022-05-12	0
Rob Zombie	32969	2022-05-12	0
Delete	32970	2022-05-12	0
Victimas Del Dr Cerebro	32971	2022-05-12	0
H-Bomb Ferguson	32972	2022-05-12	0
Jackie Leven	32973	2022-05-12	0
Motion Man feat KutMasta Kurt	32974	2022-05-12	0
The Primeridian	32975	2022-05-12	0
Danni Leigh	32976	2022-05-12	0
Stonegard	32977	2022-05-12	0
Backdraft	32978	2022-05-12	0
Plies	32979	2022-05-12	0
Billo's Caracas Boys	32980	2022-05-12	0
Strangelove	32981	2022-05-12	0
Sergio Franchi	32982	2022-05-12	0
Ignition Technition	32983	2022-05-12	0
Gerald Levert	32984	2022-05-12	0
Sergio Vargas	32985	2022-05-12	0
Esser	32986	2022-05-12	0
Glorior Belli	32987	2022-05-12	0
Five for Fighting	32988	2022-05-12	0
El Último Ke Zierre	32989	2022-05-12	0
Malina	32990	2022-05-12	0
Krista Detor	32991	2022-05-12	0
Cledus T. Judd	32992	2022-05-12	0
Cobra Verde	32993	2022-05-12	0
Snow Patrol	32994	2022-05-12	0
Stinking Lizaveta	32995	2022-05-12	0
Joe Derrane_ Frankie Gavin_ Brian McGrath	32996	2022-05-12	0
Cheryl Ann Fulton	32997	2022-05-12	0
Culture Beat	32998	2022-05-12	0
The Stone Poneys	32999	2022-05-12	0
Jeremy Fisher	33000	2022-05-12	0
Chuy Chavez	33001	2022-05-12	0
Ligeia	33002	2022-05-12	0
Loredana	33003	2022-05-12	0
Doc Gynéco - Janik	33004	2022-05-12	0
Los Wawanco	33005	2022-05-12	0
Luiz Bonfa	33006	2022-05-12	0
tobyMac	33007	2022-05-12	0
Feist	33008	2022-05-12	0
Hiroaki Iizuka	33009	2022-05-12	0
Jeffrey Scot Wills	33010	2022-05-12	0
Dine et Déon	33011	2022-05-12	0
Jimmy Witherspoon	33012	2022-05-12	0
Koopsta Knicca	33013	2022-05-12	0
Birdy Nam Nam	33014	2022-05-12	0
Cathal Coughlan	33015	2022-05-12	0
Academy of Ancient Music & Richard Egarr	33016	2022-05-12	0
Mental Overdrive	33017	2022-05-12	0
Vision of Disorder	33018	2022-05-12	0
John Michael Montgomery	33019	2022-05-12	0
Devlin & David	33020	2022-05-12	0
T.I.	33021	2022-05-12	0
Goldie	33022	2022-05-12	0
Tony Furtado	33023	2022-05-12	0
Massimo fr Gabba & Javier Garcia MUSIC4US	33024	2022-05-12	0
Ricky Nelson	33025	2022-05-12	0
Li'l Cap'n Travis	33026	2022-05-12	0
The Souther-Hillman-Furay Band	33027	2022-05-12	0
El Tren de los Sueños	33028	2022-05-12	0
Soul Quality Quartet	33029	2022-05-12	0
Birmingham Jubilee Singers	33030	2022-05-12	0
Solitune	33031	2022-05-12	0
The Mantovani Orchestra	33032	2022-05-12	0
Moon Mullican	33033	2022-05-12	0
Chris Unck & The Black Roses	33034	2022-05-12	0
Voice Of The Beehive	33035	2022-05-12	0
Paul Mauriat And His Orchestra	33036	2022-05-12	0
Neurosis	33037	2022-05-12	0
India	33038	2022-05-12	0
The Popes	33039	2022-05-12	0
Under The Influence Of Giants	33040	2022-05-12	0
BK & Associates and KJ-52	33041	2022-05-12	0
The Whitest Kids U' Know	33042	2022-05-12	0
Secret Oyster	33043	2022-05-12	0
David Bisbal	33044	2022-05-12	0
Placebo	33045	2022-05-12	0
Cypher	33046	2022-05-12	0
Pete Escovedo / Sheila Escovedo	33047	2022-05-12	0
Danny Byrd Feat. Liquid	33048	2022-05-12	0
The Carla Bley Band	33049	2022-05-12	0
N.O.R.E. / Dwnlzy	33050	2022-05-12	0
Boston	33051	2022-05-12	0
The Bonzo Dog Band	33052	2022-05-12	0
Flare-Up	33053	2022-05-12	0
Joey Riot Feat. Angel Eyez	33054	2022-05-12	0
Steve Roach	33055	2022-05-12	0
David Holmes	33056	2022-05-12	0
Joaquin Sabina Y Viceversa	33057	2022-05-12	0
Carpenters	33058	2022-05-12	0
Magical Power Mako	33059	2022-05-12	0
One 21	33060	2022-05-12	0
Michael Monroe	33061	2022-05-12	0
Fireworks	33062	2022-05-12	0
Graeme Revell_ Robert Rodriguez	33063	2022-05-12	0
Emperor	33064	2022-05-12	0
Marlena Shaw	33065	2022-05-12	0
Nikos Kourkoulis	33066	2022-05-12	0
Sean Simmons (ft. Mel Buckley)	33067	2022-05-12	0
Aerospace	33068	2022-05-12	0
Contemporary Noise Quintet	33069	2022-05-12	0
Los Embajadores Vallenatos	33070	2022-05-12	0
Tre Allegri Ragazzi Morti	33071	2022-05-12	0
Ben Tankard	33072	2022-05-12	0
Militant Cheerleaders On The Move	33073	2022-05-12	0
Taj Mahal Trio	33074	2022-05-12	0
Rockin' Da North feat. Janina Frostell	33075	2022-05-12	0
Angelo Badalamenti / Keira Knightley	33076	2022-05-12	0
Merle Travis	33077	2022-05-12	0
Alix Perez & Icicle	33078	2022-05-12	0
Marvin Rainwater	33079	2022-05-12	0
Pigbag	33080	2022-05-12	0
The Clancy Brothers With Tommy Makem	33081	2022-05-12	0
Nicola Giunta	33082	2022-05-12	0
Yana Kay	33083	2022-05-12	0
Jeb Loy Nichols	33084	2022-05-12	0
Lifelike & Kris Menace	33085	2022-05-12	0
Justin	33086	2022-05-12	0
Marcia Griffiths	33087	2022-05-12	0
Dom	33088	2022-05-12	0
High Fashion	33089	2022-05-12	0
Judge Jules	33090	2022-05-12	0
Ben Folds Five	33091	2022-05-12	0
Endwell	33092	2022-05-12	0
Taking Back Sunday	33093	2022-05-12	0
I Giganti	33094	2022-05-12	0
Flying Lotus	33095	2022-05-12	0
Japanther	33096	2022-05-12	0
The Who	33097	2022-05-12	0
Petar Dundov	33098	2022-05-12	0
Warzone	33099	2022-05-12	0
Air	33100	2022-05-12	0
Will Smith / Snoop Dogg	33101	2022-05-12	0
Only Freak	33102	2022-05-12	0
Tally Hall	33103	2022-05-12	0
O Terco	33104	2022-05-12	0
Dr. Alban	33105	2022-05-12	0
Joe Diffie	33106	2022-05-12	0
Dave Gleason's Wasted Days	33107	2022-05-12	0
Henry Rollins & Mother Superior	33108	2022-05-12	0
The Sugarman 3 / Lee Fields	33109	2022-05-12	0
JK	33110	2022-05-12	0
The Main Ingredient featuring Cuba Gooding	33111	2022-05-12	0
The Mabels	33112	2022-05-12	0
George Cables	33113	2022-05-12	0
Bob B Soxx & The Blue Jeans	33114	2022-05-12	0
Plumb	33115	2022-05-12	0
Cheryl Cole	33116	2022-05-12	0
Sound And Fury	33117	2022-05-12	0
Atheist	33118	2022-05-12	0
Rosendo	33119	2022-05-12	0
Attack In Black	33120	2022-05-12	0
V3	33121	2022-05-12	0
Consumed	33122	2022-05-12	0
Virtuoso	33123	2022-05-12	0
Phyllis Hyman	33124	2022-05-12	0
Cold Mailman	33125	2022-05-12	0
Telefunka	33126	2022-05-12	0
Nobuo Uematsu	33127	2022-05-12	0
Thyrfing	33128	2022-05-12	0
Chomsky	33129	2022-05-12	0
Bratri Ebenove	33130	2022-05-12	0
Feargal Sharkey	33131	2022-05-12	0
Kings of Tomorrow	33132	2022-05-12	0
Youth Pictures Of Florence Henderson	33133	2022-05-12	0
Martin O'Donnell / Michael Salvatori	33134	2022-05-12	0
Eike Immel	33135	2022-05-12	0
Bah Samba	33136	2022-05-12	0
Santa's Little Helpers	33137	2022-05-12	0
DJ Pope	33138	2022-05-12	0
Vernon & DaCosta featuring Ingrid Hakanson	33139	2022-05-12	0
We Are Scientists	33140	2022-05-12	0
Kriegsfall-U	33141	2022-05-12	0
Dharma Bums_ The	33142	2022-05-12	0
Belinda Bruce	33143	2022-05-12	0
Maurizio Mastrini	33144	2022-05-12	0
Charlie  Shavers	33145	2022-05-12	0
Jori Hulkkonen	33146	2022-05-12	0
Maestroes	33147	2022-05-12	0
AutoVaughn	33148	2022-05-12	0
Dela Dap	33149	2022-05-12	0
Hazel O'Connor	33150	2022-05-12	0
William Simpson	33151	2022-05-12	0
Thomas Penton & Thee-O	33152	2022-05-12	0
Dizmas	33153	2022-05-12	0
Darryl Worley	33154	2022-05-12	0
Heidi Montag	33155	2022-05-12	0
Kerri Chandler	33156	2022-05-12	0
Porcas borboletas	33157	2022-05-12	0
Elia Cmiral	33158	2022-05-12	0
Iron Horse	33159	2022-05-12	0
Keimzeit	33160	2022-05-12	0
Premonitions Of War	33161	2022-05-12	0
Ocote Soul Sounds and Adrian Quesada	33162	2022-05-12	0
Greg Giraldo	33163	2022-05-12	0
Firehouse	33164	2022-05-12	0
Boy Hits Car	33165	2022-05-12	0
Solaris Heights	33166	2022-05-12	0
Victoria & Jacob	33167	2022-05-12	0
Mark Foggo's Skasters	33168	2022-05-12	0
Kevin Kern	33169	2022-05-12	0
Orlando Pops Orchestra	33170	2022-05-12	0
Bentley Rhythm Ace	33171	2022-05-12	0
Urban Species / Imogen Heap	33172	2022-05-12	0
Inspectah Deck featuring La the Darkman_ Barretta 9_ Killa Sin_ Street Life	33173	2022-05-12	0
The Shamen	33174	2022-05-12	0
Eric Carter	33175	2022-05-12	0
Jessica Robinson	33176	2022-05-12	0
Diesel	33177	2022-05-12	0
The Exies	33178	2022-05-12	0
Star Fucking Hipsters	33179	2022-05-12	0
Mad Heads XL	33180	2022-05-12	0
Brandon Schott	33181	2022-05-12	0
Dr.Sound_ Henry Pass	33182	2022-05-12	0
Daniel Powter	33183	2022-05-12	0
Tiga	33184	2022-05-12	0
The Fabulous Thunderbirds	33185	2022-05-12	0
NG ²	33186	2022-05-12	0
Ekkohaus	33187	2022-05-12	0
Kamil Polner	33188	2022-05-12	0
Boyd Jarvis	33189	2022-05-12	0
Delta Goodrem	33190	2022-05-12	0
Jaki Graham	33191	2022-05-12	0
The Plimsouls	33192	2022-05-12	0
The Mantis Chapter	33193	2022-05-12	0
Nicola Arigliano	33194	2022-05-12	0
Jimmy LaFave	33195	2022-05-12	0
Paul Hindemith/Philharmonia Orchestra	33196	2022-05-12	0
Jason Ringenberg	33197	2022-05-12	0
Adam Faith	33198	2022-05-12	0
debbie rockt!	33199	2022-05-12	0
Kiddus I	33200	2022-05-12	0
Gillian Hills	33201	2022-05-12	0
The Hunches	33202	2022-05-12	0
Javier Krahe	33203	2022-05-12	0
Tiny Tim	33204	2022-05-12	0
Russill Paul	33205	2022-05-12	0
Prism	33206	2022-05-12	0
Break Bread	33207	2022-05-12	0
Angus & Julia Stone	33208	2022-05-12	0
The Scourge Of The Sea	33209	2022-05-12	0
Rogue's March	33210	2022-05-12	0
Faye Adams	33211	2022-05-12	0
Abd Al Malik	33212	2022-05-12	0
Philippe Eidel	33213	2022-05-12	0
Maria McKee	33214	2022-05-12	0
David Johansen	33215	2022-05-12	0
The (International) Noise Conspiracy	33216	2022-05-12	0
Patra	33217	2022-05-12	0
Joel Frederiksen	33218	2022-05-12	0
Program the Dead	33219	2022-05-12	0
Tony Trischka	33220	2022-05-12	0
Kim Sozzi	33221	2022-05-12	0
Clementina De Jesus	33222	2022-05-12	0
Cyndi Seui	33223	2022-05-12	0
Falling Up	33224	2022-05-12	0
George Nooks	33225	2022-05-12	0
Forrest Fang	33226	2022-05-12	0
Barbara Lynn	33227	2022-05-12	0
Passi Falsi	33228	2022-05-12	0
Tracy Chapman / Luciano Pavarotti / Orchestra Sinfonica Italiana / José Molina	33229	2022-05-12	0
Marnie Stern	33230	2022-05-12	0
Matisyahu	33231	2022-05-12	0
Ronnie Dawson	33232	2022-05-12	0
StoneBridge feat. Therese	33233	2022-05-12	0
Kid 606 Vs Dalek	33234	2022-05-12	0
Woody Guthrie	33235	2022-05-12	0
Brett Anderson	33236	2022-05-12	0
Mikael Ramel	33237	2022-05-12	0
El Poder del Norte	33238	2022-05-12	0
Billy Fury	33239	2022-05-12	0
Outlie	33240	2022-05-12	0
Jay Chou	33241	2022-05-12	0
Pearls Before Swine	33242	2022-05-12	0
Stephane Grappelli	33243	2022-05-12	0
André Herman Düne	33244	2022-05-12	0
DevilDriver	33245	2022-05-12	0
Arsenal	33246	2022-05-12	0
Detsishi Ensemble	33247	2022-05-12	0
1200 Mics	33248	2022-05-12	0
Midnight Juggernauts	33249	2022-05-12	0
Hollow Tip	33250	2022-05-12	0
Alex Swings Oscar Sings!	33251	2022-05-12	0
Transmission0	33252	2022-05-12	0
Jeanie Bryson	33253	2022-05-12	0
Creaming Jesus	33254	2022-05-12	0
2nd II None Featuring AMG & James DeBarge	33255	2022-05-12	0
Zoot Sims - Bob Brookmeyer	33256	2022-05-12	0
Bloodjunkies	33257	2022-05-12	0
Duke Ellington / Coleman Hawkins	33258	2022-05-12	0
L-Kan	33259	2022-05-12	0
Pete Molinari	33260	2022-05-12	0
Don Diablo & Example	33261	2022-05-12	0
Median	33262	2022-05-12	0
Malcolm X	33263	2022-05-12	0
Dik Dik	33264	2022-05-12	0
Kenny G	33265	2022-05-12	0
Khetzal	33266	2022-05-12	0
Decadence	33267	2022-05-12	0
Ruby Dee and The Snakehandlers	33268	2022-05-12	0
Jade Warrior	33269	2022-05-12	0
Belly Dance	33270	2022-05-12	0
Salem	33271	2022-05-12	0
The Code	33272	2022-05-12	0
General Degree	33273	2022-05-12	0
Koordinate Of Wonders	33274	2022-05-12	0
Marty Haugen	33275	2022-05-12	0
The Astors	33276	2022-05-12	0
Jesus Christ Superstar - 20th Anniversary Cast	33277	2022-05-12	0
Prisonshake	33278	2022-05-12	0
Frank Spilker Gruppe	33279	2022-05-12	0
Cash Box Kings	33280	2022-05-12	0
Worth Dying For	33281	2022-05-12	0
Absolute Beginner	33282	2022-05-12	0
Lee Andrews_ The Hearts	33283	2022-05-12	0
New Adventures	33284	2022-05-12	0
Marte Wulff	33285	2022-05-12	0
The Clancy Brothers_ Tommy Makem	33286	2022-05-12	0
Herman Finkers	33287	2022-05-12	0
Greg MacPherson	33288	2022-05-12	0
Tom Novy	33289	2022-05-12	0
The Coldspot 8	33290	2022-05-12	0
Cherrelle	33291	2022-05-12	0
Commodores	33292	2022-05-12	0
Shimon	33293	2022-05-12	0
FourPlay String Quartet	33294	2022-05-12	0
Jimmy McCracklin	33295	2022-05-12	0
Maurizio Solieri	33296	2022-05-12	0
James Jackson Toth	33297	2022-05-12	0
Will To Power	33298	2022-05-12	0
The Fairfield Four	33299	2022-05-12	0
Delegation	33300	2022-05-12	0
2 BMF	33301	2022-05-12	0
Max De Castro	33302	2022-05-12	0
Tod Dockstader	33303	2022-05-12	0
Cobra Killer	33304	2022-05-12	0
Tom Salta	33305	2022-05-12	0
Rob De Nijs	33306	2022-05-12	0
The Demon Boyz	33307	2022-05-12	0
R.I.O.	33308	2022-05-12	0
Nice Monster	33309	2022-05-12	0
Iva	33310	2022-05-12	0
xbxrx	33311	2022-05-12	0
Johnny Thunders and The Heartbreakers	33312	2022-05-12	0
The Doc Watson Family	33313	2022-05-12	0
Kimera - Victoria	33314	2022-05-12	0
Dream	33315	2022-05-12	0
Bang! Bang!	33316	2022-05-12	0
The Peelers	33317	2022-05-12	0
Stars of Track and Field	33318	2022-05-12	0
Bad English	33319	2022-05-12	0
Bourbon Princess	33320	2022-05-12	0
Exilia	33321	2022-05-12	0
The Stoner	33322	2022-05-12	0
Fat Larry's Band	33323	2022-05-12	0
Milburn	33324	2022-05-12	0
Strachy Na Lachy	33325	2022-05-12	0
Ed Bolduc	33326	2022-05-12	0
John Davis	33327	2022-05-12	0
Tunsi	33328	2022-05-12	0
Duane Eddy	33329	2022-05-12	0
Charlie Brown Jr.	33330	2022-05-12	0
Riton feat. The uber audio bros.	33331	2022-05-12	0
Charlie Haden & Chris Anderson	33332	2022-05-12	0
T-Rock	33333	2022-05-12	0
Bananarama	33334	2022-05-12	0
Jel	33335	2022-05-12	0
Ali Akbar Khan	33336	2022-05-12	0
Bill Haley And The Comets	33337	2022-05-12	0
Agent X	33338	2022-05-12	0
Doddy Dobson	33339	2022-05-12	0
Mrs. Miller	33340	2022-05-12	0
Osanna	33341	2022-05-12	0
George Strait	33342	2022-05-12	0
Stereo Mutants	33343	2022-05-12	0
Talent	33344	2022-05-12	0
Josephine Foster	33345	2022-05-12	0
Miguel Calo	33346	2022-05-12	0
Dianne Reeves & Lou Rawls	33347	2022-05-12	0
Motorpsycho	33348	2022-05-12	0
Sippie Wallace_ Little Brother Montgomery_ Jack Myers_ Freddie Below	33349	2022-05-12	0
Totó La Momposina	33350	2022-05-12	0
Caterina Valente	33351	2022-05-12	0
Ismael Serrano	33352	2022-05-12	0
Karamelo Santo	33353	2022-05-12	0
Juno Reactor	33354	2022-05-12	0
Whiplash	33355	2022-05-12	0
Five Bolt Main	33356	2022-05-12	0
Kendall Payne	33357	2022-05-12	0
Joshua Bell;James Newton Howard	33358	2022-05-12	0
Vanilla Fudge	33359	2022-05-12	0
Cola	33360	2022-05-12	0
The Derek Trucks Band featuring Ruben Blades	33361	2022-05-12	0
Midlake	33362	2022-05-12	0
Garnet Silk	33363	2022-05-12	0
Autopsy	33364	2022-05-12	0
Drop Trio	33365	2022-05-12	0
Matt Wertz	33366	2022-05-12	0
Ernie Ranglin	33367	2022-05-12	0
Close Combat	33368	2022-05-12	0
Daisy Chainsaw	33369	2022-05-12	0
Jane Siberry	33370	2022-05-12	0
Valkyrend Varieté	33371	2022-05-12	0
The Jazz Butcher Conspiracy	33372	2022-05-12	0
Oro Solido	33373	2022-05-12	0
Fefe Dobson	33374	2022-05-12	0
Emma Kirkby / The Academy of Ancient Music / Christopher Hogwood	33375	2022-05-12	0
Domenico Modugno	33376	2022-05-12	0
Wynn Stewart	33377	2022-05-12	0
STEVE CAMP	33378	2022-05-12	0
Lugo	33379	2022-05-12	0
Hecuba	33380	2022-05-12	0
Dawn of Relic	33381	2022-05-12	0
Martin Carthy	33382	2022-05-12	0
Badfinger	33383	2022-05-12	0
Meav Ni Mhaolchatha	33384	2022-05-12	0
Garageland	33385	2022-05-12	0
Alborosie [feat. The Tamlins]	33386	2022-05-12	0
Causey Way	33387	2022-05-12	0
Richter	33388	2022-05-12	0
Pink Anderson	33389	2022-05-12	0
Jimmie Spheeris	33390	2022-05-12	0
Bjorn Berge	33391	2022-05-12	0
Brian Eno	33392	2022-05-12	0
Marco Di Marco	33393	2022-05-12	0
Oh My God	33394	2022-05-12	0
Satan_ The Dark Prince	33395	2022-05-12	0
Armin van Buuren	33396	2022-05-12	0
Jean Knight	33397	2022-05-12	0
Kate Mc Gregor	33398	2022-05-12	0
Pere Ubu	33399	2022-05-12	0
McGuffey Lane	33400	2022-05-12	0
Robertinho Silva	33401	2022-05-12	0
Army Of Terror	33402	2022-05-12	0
Gene Walk Group	33403	2022-05-12	0
Italoboyz	33404	2022-05-12	0
Tosch featuring Sonic Monkey	33405	2022-05-12	0
David Byrne	33406	2022-05-12	0
The Ocean Blue	33407	2022-05-12	0
Tennessee Ernie Ford	33408	2022-05-12	0
Johnny Vicious Featuring Judy Albanese	33409	2022-05-12	0
Carnivore	33410	2022-05-12	0
The Gerbils	33411	2022-05-12	0
The Oscar Peterson Trio	33412	2022-05-12	0
Neil Norman And His Cosmic Orchestra	33413	2022-05-12	0
The Bongos	33414	2022-05-12	0
Shirley & Lee	33415	2022-05-12	0
We Versus The Shark	33416	2022-05-12	0
Kuti	33417	2022-05-12	0
Theo Tams	33418	2022-05-12	0
Guru Guru	33419	2022-05-12	0
Solid Gold	33420	2022-05-12	0
Duke Robillard	33421	2022-05-12	0
English Chamber Orchestra/Daniel Barenboim	33422	2022-05-12	0
Holiday Instrumentals	33423	2022-05-12	0
Steve Riley & The Mamou Playboys	33424	2022-05-12	0
James Taylor	33425	2022-05-12	0
Pitch Black featuring KP	33426	2022-05-12	0
The Dreem Teem Vs Neneh Cherry	33427	2022-05-12	0
Me First And The Gimme Gimmes	33428	2022-05-12	0
Mike Viola and the Candy Butchers	33429	2022-05-12	0
Ronan	33430	2022-05-12	0
Jamie Woon	33431	2022-05-12	0
Westbam	33432	2022-05-12	0
Manual	33433	2022-05-12	0
Bodies Of Water	33434	2022-05-12	0
La Rue Ketanou	33435	2022-05-12	0
Marcel Mouloudji	33436	2022-05-12	0
Addison Groove Project	33437	2022-05-12	0
Krid P	33438	2022-05-12	0
Detonautas	33439	2022-05-12	0
Lucybell	33440	2022-05-12	0
Unkle Bob	33441	2022-05-12	0
Guillaume & The Coutu Dumonts	33442	2022-05-12	0
Hamish Imlach	33443	2022-05-12	0
Shout Out Out Out Out	33444	2022-05-12	0
The Tokens	33445	2022-05-12	0
Reverend Horton Heat	33446	2022-05-12	0
David Ford	33447	2022-05-12	0
Bonafide	33448	2022-05-12	0
Ragga Oktay	33449	2022-05-12	0
Polytechnic	33450	2022-05-12	0
The Blue Nile	33451	2022-05-12	0
Juice Leskinen	33452	2022-05-12	0
Coughs	33453	2022-05-12	0
Finn Brothers	33454	2022-05-12	0
Electric Universe	33455	2022-05-12	0
Bellmer Dolls	33456	2022-05-12	0
Emerson Drive	33457	2022-05-12	0
When The Empire Falls	33458	2022-05-12	0
Cursive	33459	2022-05-12	0
Engelbert Humperdinck	33460	2022-05-12	0
Oomph!	33461	2022-05-12	0
Electrixx	33462	2022-05-12	0
LOWKEY & KARDINAL	33463	2022-05-12	0
Usual Suspects	33464	2022-05-12	0
Savoy-Doucet Cajun Band	33465	2022-05-12	0
REO Speedwagon	33466	2022-05-12	0
Higgins	33467	2022-05-12	0
Barbara Carr	33468	2022-05-12	0
Ayreon	33469	2022-05-12	0
Plume Latraverse	33470	2022-05-12	0
Satan Takes A Holiday	33471	2022-05-12	0
Andrew Bennett feat. Kirsty Hawkshaw	33472	2022-05-12	0
Immundus	33473	2022-05-12	0
IIIRD Tyme Out	33474	2022-05-12	0
Aterciopelados	33475	2022-05-12	0
Pippo Franco	33476	2022-05-12	0
Soulsearcher	33477	2022-05-12	0
The Ritchie Family	33478	2022-05-12	0
Drop Nineteens	33479	2022-05-12	0
The Holiday Plan	33480	2022-05-12	0
The Distillers	33481	2022-05-12	0
Daniel Bedingfield	33482	2022-05-12	0
Bullys Wit Fullys	33483	2022-05-12	0
Monika Kruse@Voodooamt	33484	2022-05-12	0
Big Youth	33485	2022-05-12	0
Warehouse	33486	2022-05-12	0
Piccola Bottega Baltazar	33487	2022-05-12	0
Bye Bye Bicycle	33488	2022-05-12	0
Concretes	33489	2022-05-12	0
Yazz / The Plastic Population	33490	2022-05-12	0
Ramona Falls	33491	2022-05-12	0
The Jazz Butcher	33492	2022-05-12	0
Medwyn Goodall	33493	2022-05-12	0
Chew Lips	33494	2022-05-12	0
Los Dynamite	33495	2022-05-12	0
Tokyo Rose	33496	2022-05-12	0
Funk D' Void	33497	2022-05-12	0
Cyrus Faryar	33498	2022-05-12	0
Primus	33499	2022-05-12	0
Deee-Lite	33500	2022-05-12	0
Jan Howard	33501	2022-05-12	0
Intensive Care	33502	2022-05-12	0
Kostia	33503	2022-05-12	0
Roy Brown	33504	2022-05-12	0
The Lucksmiths	33505	2022-05-12	0
Pharrell featuring Jay-Z	33506	2022-05-12	0
The Dogs D'Amour	33507	2022-05-12	0
Emmanuel Moire	33508	2022-05-12	0
Beber & Tamra	33509	2022-05-12	0
Christina Milian / Shawnna	33510	2022-05-12	0
Lemur Voice	33511	2022-05-12	0
Bo Hansson	33512	2022-05-12	0
Tanya Tomkins and Eric Zivian	33513	2022-05-12	0
Adrenaline	33514	2022-05-12	0
Pedestrian	33515	2022-05-12	0
W:AX	33516	2022-05-12	0
Big Rich	33517	2022-05-12	0
D-Shot	33518	2022-05-12	0
Rev. James Moore	33519	2022-05-12	0
Gene Kelly	33520	2022-05-12	0
Susie Suh	33521	2022-05-12	0
STFU	33522	2022-05-12	0
Orchestra	33523	2022-05-12	0
Typhoon	33524	2022-05-12	0
T-Bone Burnett	33525	2022-05-12	0
Special EFX	33526	2022-05-12	0
Nôze	33527	2022-05-12	0
Democustico	33528	2022-05-12	0
NATASCHA SOHL	33529	2022-05-12	0
Paco Buggin & Joy Marquez	33530	2022-05-12	0
Slowride	33531	2022-05-12	0
Emma Tricca	33532	2022-05-12	0
Dolcenera	33533	2022-05-12	0
The Bloody Hollies	33534	2022-05-12	0
Interstate Blues	33535	2022-05-12	0
Totta Näslund/Kajsa Grytt	33536	2022-05-12	0
Add N To (X)	33537	2022-05-12	0
DJs@Work	33538	2022-05-12	0
Sweet Billy Pilgrim	33539	2022-05-12	0
Luke Dzierzek	33540	2022-05-12	0
Depeche Mode	33541	2022-05-12	0
Reflekt ft. Delline Bass	33542	2022-05-12	0
Martin Stenmarck	33543	2022-05-12	0
Rachael Yamagata	33544	2022-05-12	0
Gary P. Nunn	33545	2022-05-12	0
Lene Marlin	33546	2022-05-12	0
Cocoa Tea & Josey Wales	33547	2022-05-12	0
The Eternal Afflict	33548	2022-05-12	0
Gigi D'Alessio	33549	2022-05-12	0
José Luis Duval	33550	2022-05-12	0
Mark Farner	33551	2022-05-12	0
Axel Karakasis	33552	2022-05-12	0
Project:Komakino	33553	2022-05-12	0
Manhattan Brothers	33554	2022-05-12	0
Bobby McFerrin	33555	2022-05-12	0
Blind Melon	33556	2022-05-12	0
Atomic Swing	33557	2022-05-12	0
Al Green	33558	2022-05-12	0
Flash	33559	2022-05-12	0
Augie March	33560	2022-05-12	0
Lio	33561	2022-05-12	0
Costumbre	33562	2022-05-12	0
Daddy Freddy	33563	2022-05-12	0
Tri Sestry	33564	2022-05-12	0
The Almost	33565	2022-05-12	0
Larry Norman	33566	2022-05-12	0
Pulling Teeth	33567	2022-05-12	0
Ornella Vanoni	33568	2022-05-12	0
Bernard Herrmann	33569	2022-05-12	0
Ethel Merman	33570	2022-05-12	0
Fearless Iranians From Hell	33571	2022-05-12	0
Jackie McLean	33572	2022-05-12	0
AGATHODAIMON	33573	2022-05-12	0
Red Bennies	33574	2022-05-12	0
The Scary Bitches	33575	2022-05-12	0
King of Prussia	33576	2022-05-12	0
Melanie Fiona	33577	2022-05-12	0
René Aubry	33578	2022-05-12	0
Brakes	33579	2022-05-12	0
Edo Maajka	33580	2022-05-12	0
Corpus Delicti	33581	2022-05-12	0
Vital Remains	33582	2022-05-12	0
Jugendstil	33583	2022-05-12	0
Mighty Mighty Bosstones	33584	2022-05-12	0
Qualude	33585	2022-05-12	0
Luigi Masi	33586	2022-05-12	0
Ill Harmonics	33587	2022-05-12	0
No Doubt	33588	2022-05-12	0
Cooly's Hot Box	33589	2022-05-12	0
Bellowhead	33590	2022-05-12	0
Channel Live	33591	2022-05-12	0
Nomads of Dub	33592	2022-05-12	0
Lotte Lenya	33593	2022-05-12	0
Jesse Ed Davis	33594	2022-05-12	0
Fury In The Slaughterhouse	33595	2022-05-12	0
Machinae Supremacy	33596	2022-05-12	0
Stereo Palma	33597	2022-05-12	0
Sean Kingston and Justin Bieber	33598	2022-05-12	0
Steve Wariner	33599	2022-05-12	0
Gusto	33600	2022-05-12	0
Earl Sixteen	33601	2022-05-12	0
VOTA	33602	2022-05-12	0
Jami Smith	33603	2022-05-12	0
Lina Margy	33604	2022-05-12	0
Amarfis_ La Banda De Atakke	33605	2022-05-12	0
Gucci Crew II	33606	2022-05-12	0
The Cyrkle	33607	2022-05-12	0
Omnium Gatherum	33608	2022-05-12	0
John Berry	33609	2022-05-12	0
Mr. De'	33610	2022-05-12	0
Vyvienne Long	33611	2022-05-12	0
The Orlons	33612	2022-05-12	0
Ljiljana Petkovic Orchestra	33613	2022-05-12	0
Joachim Witt	33614	2022-05-12	0
Nasum	33615	2022-05-12	0
Tony Bellus	33616	2022-05-12	0
High Tone	33617	2022-05-12	0
Redbone	33618	2022-05-12	0
üNN	33619	2022-05-12	0
Kapaikos (aka Kapajkos)	33620	2022-05-12	0
Theodore Unit feat. Trife	33621	2022-05-12	0
Dillinger	33622	2022-05-12	0
Marilyn Horne	33623	2022-05-12	0
Fetchin' Bones	33624	2022-05-12	0
Quantum Leap	33625	2022-05-12	0
Pepe Pinto	33626	2022-05-12	0
Hepburn	33627	2022-05-12	0
Phoenix Mourning	33628	2022-05-12	0
Quietdrive	33629	2022-05-12	0
Charlie Ace / The Upsetters	33630	2022-05-12	0
Datarock	33631	2022-05-12	0
Christian Burkhardt	33632	2022-05-12	0
Ali / Nelly / Murphy Lee / Kyjuan	33633	2022-05-12	0
Eddie Beram	33634	2022-05-12	0
Carole Pope	33635	2022-05-12	0
Gregor Salto	33636	2022-05-12	0
Mario Lopez	33637	2022-05-12	0
Pink Floyd Tribute	33638	2022-05-12	0
Catupecu Machu	33639	2022-05-12	0
Lykke Li	33640	2022-05-12	0
Josete	33641	2022-05-12	0
Saint Etienne	33642	2022-05-12	0
PCP	33643	2022-05-12	0
Four Letter Lie	33644	2022-05-12	0
Natalia Oreiro	33645	2022-05-12	0
Tonic	33646	2022-05-12	0
Geri Allen	33647	2022-05-12	0
Trio Irakitan	33648	2022-05-12	0
One Way Letter	33649	2022-05-12	0
T.Rex	33650	2022-05-12	0
Michio	33651	2022-05-12	0
Josh Groban (Featuring The Corrs)	33652	2022-05-12	0
Commander Cody And His Lost Planet Airmen	33653	2022-05-12	0
Toni Braxton	33654	2022-05-12	0
Kleerup featuring Sweptaways	33655	2022-05-12	0
Benny Mardones	33656	2022-05-12	0
Alejandro Filio	33657	2022-05-12	0
Avril Lavigne featuring Lil Mama	33658	2022-05-12	0
Shades of Al Davis	33659	2022-05-12	0
Paco Fernández	33660	2022-05-12	0
LMNO	33661	2022-05-12	0
Barrabas	33662	2022-05-12	0
Artanker Convoy	33663	2022-05-12	0
Sixième Aks	33664	2022-05-12	0
Charley Patton	33665	2022-05-12	0
Retard-O-Bot	33666	2022-05-12	0
The Supremes	33667	2022-05-12	0
overlord	33668	2022-05-12	0
Main Flow	33669	2022-05-12	0
Patrick Eudeline	33670	2022-05-12	0
Mikaela's Fiend	33671	2022-05-12	0
Third Day	33672	2022-05-12	0
Countach	33673	2022-05-12	0
The Invisibl Skratch Piklz	33674	2022-05-12	0
Gwen Sebastian	33675	2022-05-12	0
Midge Ure	33676	2022-05-12	0
Myrlla Muniz	33677	2022-05-12	0
Marcus Intalex	33678	2022-05-12	0
Krzysztof Krawczyk & Goran Bregovic	33679	2022-05-12	0
Onra_ Quetzal	33680	2022-05-12	0
Bianca	33681	2022-05-12	0
Ococo	33682	2022-05-12	0
Alberto Cortez	33683	2022-05-12	0
Tall Dwarfs	33684	2022-05-12	0
White Rose Transmission	33685	2022-05-12	0
Sara Bareilles	33686	2022-05-12	0
Bigg Snoop Dogg	33687	2022-05-12	0
Craig David	33688	2022-05-12	0
Paul Taylor	33689	2022-05-12	0
Brotherly	33690	2022-05-12	0
Moubaraka	33691	2022-05-12	0
Shameless	33692	2022-05-12	0
Karin Ruckerbauer	33693	2022-05-12	0
Duo Soma	33694	2022-05-12	0
Donald Fagen	33695	2022-05-12	0
Jane's Addiction	33696	2022-05-12	0
The Matthew Herbert Big Band	33697	2022-05-12	0
De Lancaster	33698	2022-05-12	0
Baaba Maal_ Mansour Seck	33699	2022-05-12	0
Loess	33700	2022-05-12	0
Kontrafakt	33701	2022-05-12	0
Kraftwerk	33702	2022-05-12	0
Brando	33703	2022-05-12	0
Stone Gods	33704	2022-05-12	0
Camilo Sesto;Guillermo Anton;Charly Chausson;Coro	33705	2022-05-12	0
Radio Futura	33706	2022-05-12	0
MC Lars (featuring Paul Gilbert and Parry Gripp)	33707	2022-05-12	0
Kristinia DeBarge	33708	2022-05-12	0
Sluggy Ranks	33709	2022-05-12	0
The Chordettes	33710	2022-05-12	0
Tin Hat Trio	33711	2022-05-12	0
The Radiants	33712	2022-05-12	0
Medeski_ Martin & Wood/Sa Ra Creative Partners	33713	2022-05-12	0
Glenn Morrison	33714	2022-05-12	0
Roudoudou	33715	2022-05-12	0
The Electric Hellfire Club	33716	2022-05-12	0
The Field	33717	2022-05-12	0
Bing Crosby & Grace Kelly	33718	2022-05-12	0
Sly Fox	33719	2022-05-12	0
Steve Morley	33720	2022-05-12	0
Colleen	33721	2022-05-12	0
Ragga Twins	33722	2022-05-12	0
Troop	33723	2022-05-12	0
Jupiter Rising	33724	2022-05-12	0
In-Flight Safety	33725	2022-05-12	0
Jah Wobble	33726	2022-05-12	0
Harvey Danger	33727	2022-05-12	0
Faithless	33728	2022-05-12	0
Shuttlecock	33729	2022-05-12	0
US Army Field Band Jazz Ambassadors	33730	2022-05-12	0
DESPERADO	33731	2022-05-12	0
Wham!	33732	2022-05-12	0
31 Knots	33733	2022-05-12	0
Jeff And Sheri Easter	33734	2022-05-12	0
Hitomi Yaida	33735	2022-05-12	0
Mark Lanegan	33736	2022-05-12	0
Field Mob	33737	2022-05-12	0
Morning Glory	33738	2022-05-12	0
Beatsteaks	33739	2022-05-12	0
Naseebo Lal	33740	2022-05-12	0
Totos	33741	2022-05-12	0
DJ Quicksilver	33742	2022-05-12	0
Sammy Davis Jr.	33743	2022-05-12	0
Keith Hudson	33744	2022-05-12	0
Califone	33745	2022-05-12	0
Splender	33746	2022-05-12	0
Chick Webb And His Orchestra	33747	2022-05-12	0
Ivete Sangalo & Juan Luis Guerra	33748	2022-05-12	0
Charly Black	33749	2022-05-12	0
Controlled Fusion	33750	2022-05-12	0
Eric Alexander	33751	2022-05-12	0
Mister Calypson	33752	2022-05-12	0
Buddy Rich	33753	2022-05-12	0
Steely Dan	33754	2022-05-12	0
Styx	33755	2022-05-12	0
Athlete	33756	2022-05-12	0
KATAKLYSM	33757	2022-05-12	0
Scheme	33758	2022-05-12	0
Almanac Singers	33759	2022-05-12	0
Claude Vincent	33760	2022-05-12	0
Scred Connexion	33761	2022-05-12	0
Samy Deluxe	33762	2022-05-12	0
Dorit Reuveni	33763	2022-05-12	0
James Curd	33764	2022-05-12	0
Deep Voices	33765	2022-05-12	0
Kenny "Babyface" Edmonds	33766	2022-05-12	0
Hermeto Pascoal	33767	2022-05-12	0
Barbara Jones	33768	2022-05-12	0
Marie Miller	33769	2022-05-12	0
Trader Horne	33770	2022-05-12	0
Marine Girls	33771	2022-05-12	0
The Weegs	33772	2022-05-12	0
Triple Bounce	33773	2022-05-12	0
Florian Gasperini	33774	2022-05-12	0
Razzia	33775	2022-05-12	0
Alex Britti	33776	2022-05-12	0
William Bell	33777	2022-05-12	0
Jose Zaragoza	33778	2022-05-12	0
Avant	33779	2022-05-12	0
Julio Preciado	33780	2022-05-12	0
Sarah Blasko	33781	2022-05-12	0
Elizabeth Daily	33782	2022-05-12	0
Arild Andersen	33783	2022-05-12	0
High Rankin	33784	2022-05-12	0
Escape The Fate	33785	2022-05-12	0
Shaye	33786	2022-05-12	0
Moonforce & Mark Versluis feat. Sunstate	33787	2022-05-12	0
Benjamin Zephaniah/Eliza Carthy/Trans-Global Underground/Simon Emmerson	33788	2022-05-12	0
Simon Wynberg	33789	2022-05-12	0
Torcuato Mariano	33790	2022-05-12	0
Telecast	33791	2022-05-12	0
Catalyst	33792	2022-05-12	0
Call And Response	33793	2022-05-12	0
Carcass	33794	2022-05-12	0
ZO2	33795	2022-05-12	0
Peg Leg Sam featuring Louisiana Red	33796	2022-05-12	0
Black 'N Blue	33797	2022-05-12	0
Sonny Clark	33798	2022-05-12	0
MZ.412	33799	2022-05-12	0
Billy Higgins	33800	2022-05-12	0
Dan Zanes Feat. Donald Saaf and The Rocket Ship Singers	33801	2022-05-12	0
Damon Aaron	33802	2022-05-12	0
Sutton Foster	33803	2022-05-12	0
Wisdom In Chains	33804	2022-05-12	0
The Plasmatics	33805	2022-05-12	0
Everlight	33806	2022-05-12	0
Tom Stephan	33807	2022-05-12	0
Los Patita De Perro	33808	2022-05-12	0
The Japonize Elephants	33809	2022-05-12	0
Asd	33810	2022-05-12	0
M People	33811	2022-05-12	0
Advocatus Diaboli	33812	2022-05-12	0
Clit 45	33813	2022-05-12	0
Primal Scream	33814	2022-05-12	0
Ultramagnetic MCs	33815	2022-05-12	0
James Newton Howard/The Postman Soundtrack	33816	2022-05-12	0
Gun	33817	2022-05-12	0
Al Hibbler	33818	2022-05-12	0
Evidence	33819	2022-05-12	0
Bombshell Rocks	33820	2022-05-12	0
Dempsey	33821	2022-05-12	0
Daggermouth	33822	2022-05-12	0
Dear Nora	33823	2022-05-12	0
Extreme	33824	2022-05-12	0
Kaze & 9th Wonder	33825	2022-05-12	0
Ute	33826	2022-05-12	0
Umberto Tozzi	33827	2022-05-12	0
The Photos	33828	2022-05-12	0
Fu Manchu	33829	2022-05-12	0
Eldridge Holmes	33830	2022-05-12	0
Black My Heart	33831	2022-05-12	0
The Adult Net	33832	2022-05-12	0
Richie Rich	33833	2022-05-12	0
Chris and Mike	33834	2022-05-12	0
Rebecca Pidgeon	33835	2022-05-12	0
The Tiki Tones	33836	2022-05-12	0
Jeremy Enigk	33837	2022-05-12	0
Number One Son	33838	2022-05-12	0
Spray	33839	2022-05-12	0
Alex Harvey Band	33840	2022-05-12	0
Country Gentlemen	33841	2022-05-12	0
La Harissa	33842	2022-05-12	0
Gaudi	33843	2022-05-12	0
Laura Nyro;LaBelle	33844	2022-05-12	0
Asure	33845	2022-05-12	0
Leif Garrett	33846	2022-05-12	0
Tearjerkers	33847	2022-05-12	0
Eric Burdon & War	33848	2022-05-12	0
Weeping Willows	33849	2022-05-12	0
At The Throne Of Judgment	33850	2022-05-12	0
Kealii Reichel	33851	2022-05-12	0
DJ Sequenza	33852	2022-05-12	0
Adams_ Baartmans & Oostindie	33853	2022-05-12	0
Andy Andy	33854	2022-05-12	0
Tobias Schmidt	33855	2022-05-12	0
Klimperei	33856	2022-05-12	0
Megashira	33857	2022-05-12	0
Chick Corea	33858	2022-05-12	0
Alastair Moock	33859	2022-05-12	0
Ekkehard Ehlers	33860	2022-05-12	0
MC Eiht	33861	2022-05-12	0
Dschinghis Khan	33862	2022-05-12	0
Josh Rouse And Kurt Wagner	33863	2022-05-12	0
Rogue Wave	33864	2022-05-12	0
Estroe_ Sebastian Davidson	33865	2022-05-12	0
The Jam	33866	2022-05-12	0
Sub Focus	33867	2022-05-12	0
Antonio Orozco	33868	2022-05-12	0
Lil' Chris	33869	2022-05-12	0
Pop-Off Tuesday	33870	2022-05-12	0
A C Temple	33871	2022-05-12	0
Uniklubi	33872	2022-05-12	0
Les Ondes Martenot	33873	2022-05-12	0
Yo-Yo Ma;Isaac Stern;Jaime Laredo;Emanuel Ax	33874	2022-05-12	0
Da CIPHA	33875	2022-05-12	0
The Breeze the Breath	33876	2022-05-12	0
Lemos	33877	2022-05-12	0
Unanimated	33878	2022-05-12	0
MRI	33879	2022-05-12	0
Mr. Blue	33880	2022-05-12	0
Prophet Posse	33881	2022-05-12	0
Van Cliburn	33882	2022-05-12	0
David Moleon	33883	2022-05-12	0
1208	33884	2022-05-12	0
New Project	33885	2022-05-12	0
Gare du Nord	33886	2022-05-12	0
US Air Force Band	33887	2022-05-12	0
Top Cat	33888	2022-05-12	0
Plus One	33889	2022-05-12	0
Bakers Dozen	33890	2022-05-12	0
Paul Webster Presents JPW	33891	2022-05-12	0
Substantial	33892	2022-05-12	0
XDisciplex A.D.	33893	2022-05-12	0
Medhy Custos	33894	2022-05-12	0
Tommy Shaw	33895	2022-05-12	0
Ludovico Einaudi / Marco Decimo	33896	2022-05-12	0
Ola Magnell	33897	2022-05-12	0
+44	33898	2022-05-12	0
Ayo	33899	2022-05-12	0
Thrice	33900	2022-05-12	0
Angelica Vale	33901	2022-05-12	0
Mr Scruff & Kaidi	33902	2022-05-12	0
Wynton Marsalis	33903	2022-05-12	0
Jeff Gauthier Goatette	33904	2022-05-12	0
Keny Arkana	33905	2022-05-12	0
Giant Robot	33906	2022-05-12	0
740 Boyz featuring Fulanito	33907	2022-05-12	0
Confetti's	33908	2022-05-12	0
Feltmann	33909	2022-05-12	0
Jump Little Children	33910	2022-05-12	0
La Barranca	33911	2022-05-12	0
BK-One	33912	2022-05-12	0
Afrosound	33913	2022-05-12	0
Arthur Lyman	33914	2022-05-12	0
Jim Jones / Max B	33915	2022-05-12	0
Canal Magdalena	33916	2022-05-12	0
Jim Brickman	33917	2022-05-12	0
Anekdoten	33918	2022-05-12	0
Remute	33919	2022-05-12	0
Cosmik Connection	33920	2022-05-12	0
Loosegoats	33921	2022-05-12	0
Chron Gen	33922	2022-05-12	0
Hala Strana	33923	2022-05-12	0
Kottonmouth Kings	33924	2022-05-12	0
Ismo Alanko	33925	2022-05-12	0
Mystery Machine	33926	2022-05-12	0
Nalin & Kane vs. Denis The Menace	33927	2022-05-12	0
Daren Callow	33928	2022-05-12	0
Philmore	33929	2022-05-12	0
Conjunto Primavera	33930	2022-05-12	0
John Boswell	33931	2022-05-12	0
Mustard Plug	33932	2022-05-12	0
O'Death	33933	2022-05-12	0
Winston Groovy	33934	2022-05-12	0
Dush Tray	33935	2022-05-12	0
Freddy Cannon	33936	2022-05-12	0
Nickel Creek	33937	2022-05-12	0
Madder Mortem	33938	2022-05-12	0
Clint Eastwood & General Saint	33939	2022-05-12	0
Triumph Of Lethargy Skinned Alive To Death	33940	2022-05-12	0
The Sun	33941	2022-05-12	0
Ghorwane	33942	2022-05-12	0
Rytmihäiriö	33943	2022-05-12	0
Buzzov¬"en	33944	2022-05-12	0
Golden Pig Electric Blues Band	33945	2022-05-12	0
Tim Green	33946	2022-05-12	0
Theatre Of Tragedy	33947	2022-05-12	0
Masterboy	33948	2022-05-12	0
Brian Littrell	33949	2022-05-12	0
M.C. Luscious	33950	2022-05-12	0
Der Mystik	33951	2022-05-12	0
Seu Jorge	33952	2022-05-12	0
Ivete Sangalo	33953	2022-05-12	0
Djam Karet	33954	2022-05-12	0
Ten Years After	33955	2022-05-12	0
John Eliot Gardiner	33956	2022-05-12	0
Andy Griggs	33957	2022-05-12	0
The Bled	33958	2022-05-12	0
Jerry Beeks feat. Jay Reyes	33959	2022-05-12	0
Kati Mac	33960	2022-05-12	0
Smash TV	33961	2022-05-12	0
Blind Blake & The Royal Victoria Hotel Calypsos	33962	2022-05-12	0
Elena Kats-Chernin	33963	2022-05-12	0
And So I Watch You From Afar_ And So I Watch You From Afar	33964	2022-05-12	0
Claude Young	33965	2022-05-12	0
Major Boys	33966	2022-05-12	0
Steve Perry	33967	2022-05-12	0
Boubacar Traoré_ Rokia Traoré	33968	2022-05-12	0
La Rocca	33969	2022-05-12	0
Tysondog	33970	2022-05-12	0
The Snake Corps	33971	2022-05-12	0
DJ Bitman	33972	2022-05-12	0
Jan Bradley	33973	2022-05-12	0
Hieroglyphic Being	33974	2022-05-12	0
Gregor Meyle	33975	2022-05-12	0
Jay-Z / Beanie Sigel / Scarface	33976	2022-05-12	0
Jazzanova	33977	2022-05-12	0
Dinky	33978	2022-05-12	0
H-Blockx	33979	2022-05-12	0
Angelo D'Onorio	33980	2022-05-12	0
Lys Assia	33981	2022-05-12	0
Death Sentence: Panda!	33982	2022-05-12	0
Rebecca Lynn Howard	33983	2022-05-12	0
Natalie MacMaster	33984	2022-05-12	0
Chet Baker	33985	2022-05-12	0
Johnny Rawls	33986	2022-05-12	0
Far From Finished	33987	2022-05-12	0
Scott Kennedy	33988	2022-05-12	0
Jason Miles	33989	2022-05-12	0
Reni	33990	2022-05-12	0
Elba Ramalho	33991	2022-05-12	0
Jasmine	33992	2022-05-12	0
Denise Ho	33993	2022-05-12	0
Republica	33994	2022-05-12	0
Abida Parveen	33995	2022-05-12	0
The Million Dollar Quartet	33996	2022-05-12	0
Project Pitchfork	33997	2022-05-12	0
Ben Westbeech	33998	2022-05-12	0
NITIN SAWHNEY	33999	2022-05-12	0
Joshua Redman Quartet	34000	2022-05-12	0
Alpha Consumer	34001	2022-05-12	0
Neon Philharmonic	34002	2022-05-12	0
Sub Bass Monster	34003	2022-05-12	0
Monty Python	34004	2022-05-12	0
Femi Kuti	34005	2022-05-12	0
Keijo	34006	2022-05-12	0
Boogaloo Joe Jones	34007	2022-05-12	0
Caniche Hara-Kiri	34008	2022-05-12	0
Pikku  feat. Sophie	34009	2022-05-12	0
Pancho Barraza	34010	2022-05-12	0
Addiction Crew	34011	2022-05-12	0
Bally Sagoo	34012	2022-05-12	0
Alexis & Fido	34013	2022-05-12	0
Wynona Carr	34014	2022-05-12	0
Karma To Burn	34015	2022-05-12	0
Huga Flame	34016	2022-05-12	0
Lotta Engbergs	34017	2022-05-12	0
Jon O'Bir	34018	2022-05-12	0
An Cafe	34019	2022-05-12	0
Cake	34020	2022-05-12	0
Jake Hess	34021	2022-05-12	0
Malkit Singh	34022	2022-05-12	0
Medeski_ Martin & Wood	34023	2022-05-12	0
Heinz Rudolf Kunze	34024	2022-05-12	0
Ewa Farna	34025	2022-05-12	0
Layaway Plan	34026	2022-05-12	0
Luiza Possi	34027	2022-05-12	0
Manic Street Preachers	34028	2022-05-12	0
Illinois Jacquet	34029	2022-05-12	0
Chris van Dutch meets Massmann	34030	2022-05-12	0
Wohnout	34031	2022-05-12	0
Reynaldo Armas	34032	2022-05-12	0
Ramón Vargas	34033	2022-05-12	0
Atmosphere	34034	2022-05-12	0
Xutos & Pontapés	34035	2022-05-12	0
Railroad Earth	34036	2022-05-12	0
Harry Connick_ Jr.	34037	2022-05-12	0
The Dismemberment Plan	34038	2022-05-12	0
Dolour	34039	2022-05-12	0
Abilene	34040	2022-05-12	0
Empirion	34041	2022-05-12	0
Sven Nielsen	34042	2022-05-12	0
Giorgos Tsalikis	34043	2022-05-12	0
Let 3	34044	2022-05-12	0
New Flesh Feat. Gift Of Gab From Blackalicious	34045	2022-05-12	0
KMC	34046	2022-05-12	0
Simple Minds	34047	2022-05-12	0
Nana Kitade	34048	2022-05-12	0
Ec8or	34049	2022-05-12	0
Arne Weinberg	34050	2022-05-12	0
Mícheál Ó Súilleabháin	34051	2022-05-12	0
Django Reinhardt;Quintette Du Hot Club de France	34052	2022-05-12	0
Joe Hlupheda Bayana	34053	2022-05-12	0
Norma Winstone_ Glauco Venier_ Klaus Gesing	34054	2022-05-12	0
Jazper featuring Picazzo	34055	2022-05-12	0
Alcoholic Faith Mission	34056	2022-05-12	0
Penal Colony	34057	2022-05-12	0
V V Brown	34058	2022-05-12	0
THE INK SPOTS	34059	2022-05-12	0
Maighread Ni Dhomhnaill	34060	2022-05-12	0
Point Of Recognition	34061	2022-05-12	0
Christian Wunsch	34062	2022-05-12	0
Dreem Teem Vs Artful Dodger Feat. Mz. May And Mc. Alistair	34063	2022-05-12	0
Jovenes Pordioseros	34064	2022-05-12	0
Unwrapped	34065	2022-05-12	0
Olibusta	34066	2022-05-12	0
Bob James	34067	2022-05-12	0
Mr. Sancho	34068	2022-05-12	0
Arco Iris	34069	2022-05-12	0
ERSKINE HAWKINS	34070	2022-05-12	0
The Last Resort	34071	2022-05-12	0
Ian Whitcomb	34072	2022-05-12	0
Ektomorf	34073	2022-05-12	0
Louise	34074	2022-05-12	0
Jaco Pastorius Big Band	34075	2022-05-12	0
Carole Samaha	34076	2022-05-12	0
Tune Robbers	34077	2022-05-12	0
Roy Orbison	34078	2022-05-12	0
Carl Doy	34079	2022-05-12	0
Lord Tariq & Peter Gunz	34080	2022-05-12	0
Otha Turner & The Afrossippi Allstars	34081	2022-05-12	0
Coquettish	34082	2022-05-12	0
Robert Le Magnifique	34083	2022-05-12	0
D.R.S.	34084	2022-05-12	0
Edvin Marton	34085	2022-05-12	0
Pointed Sticks	34086	2022-05-12	0
Lil Rob	34087	2022-05-12	0
Denver and the Mile High Orchestra	34088	2022-05-12	0
Hellmouth	34089	2022-05-12	0
The Rocky Athas Group	34090	2022-05-12	0
Frantic	34091	2022-05-12	0
Dekay	34092	2022-05-12	0
Big Noyd	34093	2022-05-12	0
Mosquito Spiral	34094	2022-05-12	0
Despina Vandi	34095	2022-05-12	0
Da Brat	34096	2022-05-12	0
Banda Maguey	34097	2022-05-12	0
Muff Potter	34098	2022-05-12	0
Coldcut	34099	2022-05-12	0
Colourfast	34100	2022-05-12	0
Johnny Burnette	34101	2022-05-12	0
Drew Nelson	34102	2022-05-12	0
David Martin	34103	2022-05-12	0
Bonobo	34104	2022-05-12	0
Elliott Carter	34105	2022-05-12	0
Anita Baker	34106	2022-05-12	0
Pier	34107	2022-05-12	0
Smut Peddlers	34108	2022-05-12	0
The Flying Bulgar Klezmer Band	34109	2022-05-12	0
Los Pasteles Del Perú	34110	2022-05-12	0
Icone Pres. Blue Manta	34111	2022-05-12	0
Stampin´ Ground	34112	2022-05-12	0
Ksir Makosa	34113	2022-05-12	0
Inimigos Da HP	34114	2022-05-12	0
Till Von Sein and Aera	34115	2022-05-12	0
Twelfth Night	34116	2022-05-12	0
Il Giardino Dei Semplici	34117	2022-05-12	0
Andrew Hill & Chico Hamilton	34118	2022-05-12	0
Sandy Rivera & Haze	34119	2022-05-12	0
Joe Williams & Count Basie	34120	2022-05-12	0
Kutt Calhoun	34121	2022-05-12	0
Colonel Claypool's Bucket Of Bernie Brains	34122	2022-05-12	0
Newham Generals	34123	2022-05-12	0
Sarah Nixey	34124	2022-05-12	0
Niña Pastori	34125	2022-05-12	0
The Scaramanga Six	34126	2022-05-12	0
Daniël Lohues	34127	2022-05-12	0
Mac Tyer feat. Kery James	34128	2022-05-12	0
Acid Mothers Temple	34129	2022-05-12	0
Pretty Girls Make Graves	34130	2022-05-12	0
The Barbarians	34131	2022-05-12	0
La Casa Azul	34132	2022-05-12	0
Avail	34133	2022-05-12	0
Salty Dog	34134	2022-05-12	0
Tunng	34135	2022-05-12	0
Kuldeep Manak	34136	2022-05-12	0
Ramesses	34137	2022-05-12	0
Nick Barker	34138	2022-05-12	0
Siiri Nordin	34139	2022-05-12	0
Kryptic Minds	34140	2022-05-12	0
Hey Monday	34141	2022-05-12	0
Dr. Ring-Ding & The Senior Allstars	34142	2022-05-12	0
Limi-T 21	34143	2022-05-12	0
Tau Factor	34144	2022-05-12	0
Mr. Scruff feat. Nke	34145	2022-05-12	0
Nestor Da Viola	34146	2022-05-12	0
One Dollar Short	34147	2022-05-12	0
King	34148	2022-05-12	0
Dday One	34149	2022-05-12	0
BarlowGirl	34150	2022-05-12	0
Icon Of Coil	34151	2022-05-12	0
Lô Borges	34152	2022-05-12	0
Larry Garner	34153	2022-05-12	0
Phil Coulter	34154	2022-05-12	0
Davis Redford Triad	34155	2022-05-12	0
Kabiyé Orchestras And Lithophones	34156	2022-05-12	0
The Rolling Stones	34157	2022-05-12	0
A3	34158	2022-05-12	0
Glenn Mercer	34159	2022-05-12	0
Bill Douglas	34160	2022-05-12	0
Cornershop	34161	2022-05-12	0
Blonker	34162	2022-05-12	0
W.A.S.P	34163	2022-05-12	0
Betty Curtis	34164	2022-05-12	0
Louisa-John Krol	34165	2022-05-12	0
Remy Ma	34166	2022-05-12	0
Sophie Ellis-Bextor	34167	2022-05-12	0
Eddie Henderson	34168	2022-05-12	0
DMX / L.O.X. / Mase	34169	2022-05-12	0
Ali Wilson & Vinylgroover AKA Scott Atrill	34170	2022-05-12	0
All My Friends	34171	2022-05-12	0
themselves	34172	2022-05-12	0
taylor deupree + christopher willits	34173	2022-05-12	0
Lispector	34174	2022-05-12	0
Joey Defrancesco	34175	2022-05-12	0
Velvet Crush	34176	2022-05-12	0
Karunesh	34177	2022-05-12	0
Reginaldo Bessa	34178	2022-05-12	0
Admiral Freebee	34179	2022-05-12	0
Yello	34180	2022-05-12	0
Jadakiss / Ghostface Killah / Raekwon	34181	2022-05-12	0
D-Unity	34182	2022-05-12	0
Mystikal featuring Butch Cassidy	34183	2022-05-12	0
Kenickie	34184	2022-05-12	0
Kanye West / Syleena Johnson	34185	2022-05-12	0
Les Garçons Bouchers	34186	2022-05-12	0
Ben Etheridge	34187	2022-05-12	0
Stare Dobre Malzenstwo	34188	2022-05-12	0
DJ Isis	34189	2022-05-12	0
The Pink Fairies	34190	2022-05-12	0
Determine	34191	2022-05-12	0
No One Is Innocent	34192	2022-05-12	0
Teatr Teney	34193	2022-05-12	0
Extasick	34194	2022-05-12	0
Howard Carpendale	34195	2022-05-12	0
Chihiro Yamanaka	34196	2022-05-12	0
Annie Lennox;Steven Lipson	34197	2022-05-12	0
Tata Young	34198	2022-05-12	0
Claude Debussy	34199	2022-05-12	0
Don Dinero	34200	2022-05-12	0
Cliff Eidelman	34201	2022-05-12	0
Adrian Lux	34202	2022-05-12	0
Gold Blade	34203	2022-05-12	0
Frida Hyvonen	34204	2022-05-12	0
Singing Melody	34205	2022-05-12	0
Jack McDuff	34206	2022-05-12	0
Racey	34207	2022-05-12	0
Cat Power	34208	2022-05-12	0
Peña Suazo Y Su Banda Gorda	34209	2022-05-12	0
Ewigkeit	34210	2022-05-12	0
Spread The Disease	34211	2022-05-12	0
Los Panchos	34212	2022-05-12	0
The Feeling	34213	2022-05-12	0
Mutemath	34214	2022-05-12	0
Carl A. Finlow	34215	2022-05-12	0
John Zorn	34216	2022-05-12	0
Frozen Plasma	34217	2022-05-12	0
Youthful Praise featuring J.J. Hairston	34218	2022-05-12	0
The Blues Magoos	34219	2022-05-12	0
Dem Franchize Boyz	34220	2022-05-12	0
Feadz	34221	2022-05-12	0
Irwin Goodman	34222	2022-05-12	0
Vanessa Paradis	34223	2022-05-12	0
Tommy Guerrero_ Chuck Treece	34224	2022-05-12	0
Roxx	34225	2022-05-12	0
Tilly & The Wall	34226	2022-05-12	0
Nacho Vegas & Christina Rosenvinge	34227	2022-05-12	0
Paul Wall	34228	2022-05-12	0
Jackpot	34229	2022-05-12	0
Tom Burbank	34230	2022-05-12	0
DJ OZMA	34231	2022-05-12	0
The Watersons	34232	2022-05-12	0
Vanity Fare	34233	2022-05-12	0
Petra Zieger	34234	2022-05-12	0
Anubian Lights	34235	2022-05-12	0
George Morgan	34236	2022-05-12	0
Florence	34237	2022-05-12	0
The Lost	34238	2022-05-12	0
Outkast Featuring Janelle Monae	34239	2022-05-12	0
Street Justice	34240	2022-05-12	0
Matt Molloy	34241	2022-05-12	0
Rauli Badding Somerjoki	34242	2022-05-12	0
Christoper Titus	34243	2022-05-12	0
Bootsy Collins	34244	2022-05-12	0
D:Fuse	34245	2022-05-12	0
Mirage	34246	2022-05-12	0
Antonio Aguilar	34247	2022-05-12	0
Heavy Merge	34248	2022-05-12	0
Sloppy Seconds	34249	2022-05-12	0
Mickey Mouse/Goofy/Pluto	34250	2022-05-12	0
Peloton	34251	2022-05-12	0
One For The Team	34252	2022-05-12	0
Susana Baca	34253	2022-05-12	0
Failsafe	34254	2022-05-12	0
Suffocate Faster	34255	2022-05-12	0
Peccatum	34256	2022-05-12	0
Pascal Obispo	34257	2022-05-12	0
Xiii. Stoleti	34258	2022-05-12	0
Josh Martinez	34259	2022-05-12	0
Lili Araujo	34260	2022-05-12	0
Tassilli Players	34261	2022-05-12	0
Meteors	34262	2022-05-12	0
Jose Luis Perales	34263	2022-05-12	0
P.o.d	34264	2022-05-12	0
Sidestepper	34265	2022-05-12	0
Venerea	34266	2022-05-12	0
Jean-Michel Bernard	34267	2022-05-12	0
Francesco De Gregori	34268	2022-05-12	0
PFR	34269	2022-05-12	0
Mongo Santamaria	34270	2022-05-12	0
Izzy Stradlin And The Ju Ju Hounds	34271	2022-05-12	0
Jon O Bir	34272	2022-05-12	0
Muse	34273	2022-05-12	0
Big Oso Loc	34274	2022-05-12	0
Holland-Dozier featuring Lamont Dozier	34275	2022-05-12	0
Kaya Project	34276	2022-05-12	0
Ken Stringfellow	34277	2022-05-12	0
Tall Paul	34278	2022-05-12	0
The wee djs	34279	2022-05-12	0
Archie Bell & The Drells	34280	2022-05-12	0
Irie Révoltés	34281	2022-05-12	0
Lay Low	34282	2022-05-12	0
Bluesmasters Featuring Mickey Thomas	34283	2022-05-12	0
Finger Eleven	34284	2022-05-12	0
Wild Cherry	34285	2022-05-12	0
Stephen Simmonds	34286	2022-05-12	0
Maarten Hercules	34287	2022-05-12	0
Defeated Sanity	34288	2022-05-12	0
James Horner	34289	2022-05-12	0
Joe Maphis	34290	2022-05-12	0
Two Lone Swordsmen	34291	2022-05-12	0
Hangar 18	34292	2022-05-12	0
Hear'Say	34293	2022-05-12	0
Sam Adams	34294	2022-05-12	0
Andy Williams	34295	2022-05-12	0
Los Amigos Invisibles	34296	2022-05-12	0
Patience Please	34297	2022-05-12	0
Hixxy	34298	2022-05-12	0
V'ro	34299	2022-05-12	0
Minor Majority	34300	2022-05-12	0
Daytonas	34301	2022-05-12	0
La Pina / Soul Kingdom	34302	2022-05-12	0
Naz Nomad And The Nightmares	34303	2022-05-12	0
I Am Spartacus	34304	2022-05-12	0
Makaton	34305	2022-05-12	0
Poncho K	34306	2022-05-12	0
Ayria	34307	2022-05-12	0
Saigon Kick	34308	2022-05-12	0
Bovea y sus Vallenatos	34309	2022-05-12	0
Tommy Körberg & Sissel Kyrkjebø	34310	2022-05-12	0
Nestor	34311	2022-05-12	0
Thomas Tantrum	34312	2022-05-12	0
Rick Ross	34313	2022-05-12	0
Modey Lemon	34314	2022-05-12	0
Rogue Traders	34315	2022-05-12	0
Paula Abdul	34316	2022-05-12	0
Presuntos Implicados	34317	2022-05-12	0
Jeru The Damaja	34318	2022-05-12	0
Taylor Dayne	34319	2022-05-12	0
Bergen Big Band	34320	2022-05-12	0
Eddie Cantor	34321	2022-05-12	0
Wardian	34322	2022-05-12	0
Jaime Urrutia	34323	2022-05-12	0
dub-L	34324	2022-05-12	0
Jo-El Sonnier	34325	2022-05-12	0
Raheem	34326	2022-05-12	0
Signal	34327	2022-05-12	0
The Champs	34328	2022-05-12	0
Blackwater	34329	2022-05-12	0
Luigi Alva/Rosanna Carteri/Orchestra del Teatro alla Scala_ Milano/Tullio Serafin	34330	2022-05-12	0
Griffin House	34331	2022-05-12	0
White Cowbell Oklahoma	34332	2022-05-12	0
3d5spd	34333	2022-05-12	0
The Maccabees	34334	2022-05-12	0
Dominoes	34335	2022-05-12	0
Colm Mac Con Iomaire	34336	2022-05-12	0
Activa	34337	2022-05-12	0
Biz Markie	34338	2022-05-12	0
Steinwolke	34339	2022-05-12	0
Alban Berg Quartett	34340	2022-05-12	0
Sakis Rouvas	34341	2022-05-12	0
Pinball	34342	2022-05-12	0
Mikhail Pletnev / Russian National Orchestra	34343	2022-05-12	0
Kaiser Souzai	34344	2022-05-12	0
Vortechtral Am And Benni Blanco	34345	2022-05-12	0
Ry Cooder & Manuel Galban	34346	2022-05-12	0
Trashlight Vision	34347	2022-05-12	0
Tahiti 80	34348	2022-05-12	0
Technologic	34349	2022-05-12	0
Cassettes Won't Listen	34350	2022-05-12	0
The Fontane Sisters	34351	2022-05-12	0
X (Australia)	34352	2022-05-12	0
Lisa Stansfield	34353	2022-05-12	0
Quique Gonzalez	34354	2022-05-12	0
Scared Straight	34355	2022-05-12	0
Magna-Fi	34356	2022-05-12	0
Local H	34357	2022-05-12	0
ISoul8	34358	2022-05-12	0
Brian Auger's Oblivion Express	34359	2022-05-12	0
Big Kuntry King	34360	2022-05-12	0
Norris Man	34361	2022-05-12	0
Harvey Milk	34362	2022-05-12	0
Grayson Capps	34363	2022-05-12	0
Leehom Wang	34364	2022-05-12	0
Queen Omega	34365	2022-05-12	0
Ilan Eshkeri / London Metropolitan Orchestra / Andy Brown	34366	2022-05-12	0
Freshlyground	34367	2022-05-12	0
Kinito Méndez	34368	2022-05-12	0
No Doubt / Bounty Killer	34369	2022-05-12	0
Vorny	34370	2022-05-12	0
Phoenix	34371	2022-05-12	0
Damien Jurado	34372	2022-05-12	0
Sonny Stitt	34373	2022-05-12	0
DJ Bes	34374	2022-05-12	0
Their Hearts Were Full Of Spring	34375	2022-05-12	0
Oberpichler	34376	2022-05-12	0
Herman's Hermits	34377	2022-05-12	0
The Gasman	34378	2022-05-12	0
Gandalf Murphy and The Slambovian Circus of Dreams	34379	2022-05-12	0
Epos	34380	2022-05-12	0
Asheru And Blue Black Of The Unspoken Heard	34381	2022-05-12	0
Oystein Sevâg	34382	2022-05-12	0
Louis Armstrong & His Orchestra	34383	2022-05-12	0
Tre Små Kinesere	34384	2022-05-12	0
The Panics	34385	2022-05-12	0
The Velvelettes	34386	2022-05-12	0
Darko Rundek & Hakuna Matata	34387	2022-05-12	0
Trafik	34388	2022-05-12	0
Antonio MacHin	34389	2022-05-12	0
Aikakone	34390	2022-05-12	0
Fire Ball	34391	2022-05-12	0
Lisandro Aristimuno	34392	2022-05-12	0
Jadakiss	34393	2022-05-12	0
Elektrochemie LK	34394	2022-05-12	0
ERIC SARDINAS	34395	2022-05-12	0
The Soul Stirrers	34396	2022-05-12	0
Deerhunter	34397	2022-05-12	0
Haustor	34398	2022-05-12	0
Priessnitz	34399	2022-05-12	0
Robert Nighthawk / Robert "Ramblin Bob" Nighthawk	34400	2022-05-12	0
Broadcast	34401	2022-05-12	0
Three O'Clock	34402	2022-05-12	0
Santana	34403	2022-05-12	0
Sprachlabor	34404	2022-05-12	0
Keziah Jones	34405	2022-05-12	0
M.A.F.U. Crew	34406	2022-05-12	0
Ben Thornewill	34407	2022-05-12	0
The Alternate Routes	34408	2022-05-12	0
Alec Empire & Merzbow	34409	2022-05-12	0
Deborah Conway	34410	2022-05-12	0
The Global Stage Orchestra	34411	2022-05-12	0
Miss Derringer	34412	2022-05-12	0
Morcheeba	34413	2022-05-12	0
Young-Holt Unlimited	34414	2022-05-12	0
D.O.W.N.	34415	2022-05-12	0
O Yuki Conjugate	34416	2022-05-12	0
Colombiafrica - The Mystic Orchestra	34417	2022-05-12	0
Triangle	34418	2022-05-12	0
Willy DeVille	34419	2022-05-12	0
Galwad Y Mynydd	34420	2022-05-12	0
Major Accident	34421	2022-05-12	0
Cassius Clay	34422	2022-05-12	0
Dry Kill Logic	34423	2022-05-12	0
Deicide	34424	2022-05-12	0
PMMP	34425	2022-05-12	0
multiplex	34426	2022-05-12	0
The Grits	34427	2022-05-12	0
Systematic	34428	2022-05-12	0
Noah Pred	34429	2022-05-12	0
Small Brown Bike_ The Casket Lottery	34430	2022-05-12	0
Eat Static	34431	2022-05-12	0
The Presets	34432	2022-05-12	0
Lower Forty-Eight	34433	2022-05-12	0
Evil Conduct	34434	2022-05-12	0
Le Temps	34435	2022-05-12	0
As Silence Falls	34436	2022-05-12	0
Terrence Dixon featuring The Meter	34437	2022-05-12	0
1349	34438	2022-05-12	0
Bratz	34439	2022-05-12	0
Andrew Bennett	34440	2022-05-12	0
Girls in Hawaii	34441	2022-05-12	0
Sir Victor Uwaifo & His Melody Maestroes	34442	2022-05-12	0
Hans Zimmer & James Newton Howard	34443	2022-05-12	0
Blk Jks	34444	2022-05-12	0
Tiller's Folly_ Bruce Coughlan	34445	2022-05-12	0
Los Enanitos Verdes	34446	2022-05-12	0
Traxamillion	34447	2022-05-12	0
Poison	34448	2022-05-12	0
Jean Goldkette	34449	2022-05-12	0
Waldeck	34450	2022-05-12	0
Tata Bojs	34451	2022-05-12	0
Robocop Kraus	34452	2022-05-12	0
Art Pepper + 11	34453	2022-05-12	0
Dionne Warwick / Cyndi Lauper	34454	2022-05-12	0
Royal S	34455	2022-05-12	0
Leng Tch'e	34456	2022-05-12	0
Alan Hawkshaw	34457	2022-05-12	0
The Hurt Process	34458	2022-05-12	0
This Computer Kills	34459	2022-05-12	0
Jinny	34460	2022-05-12	0
Shira Kammen	34461	2022-05-12	0
Graham Parker & The Rumour	34462	2022-05-12	0
New Birth Brass Band	34463	2022-05-12	0
Bill Laswell	34464	2022-05-12	0
Tony Rohr & Dietrich Schoenemann	34465	2022-05-12	0
Great American Taxi	34466	2022-05-12	0
I-20 Featuring Shawnna	34467	2022-05-12	0
Our Sleepless Forest	34468	2022-05-12	0
American Dog	34469	2022-05-12	0
Lil' Mo	34470	2022-05-12	0
Silicon Scally	34471	2022-05-12	0
Galliano	34472	2022-05-12	0
Georgia Cotton Pickers	34473	2022-05-12	0
Too Pure To Die	34474	2022-05-12	0
The Mighty Clouds Of Joy	34475	2022-05-12	0
Manuel Tur	34476	2022-05-12	0
Natural Born Hippies	34477	2022-05-12	0
Melotron	34478	2022-05-12	0
Shur-I-Kan feat. Alexander East	34479	2022-05-12	0
Ramon Zerano	34480	2022-05-12	0
Portico	34481	2022-05-12	0
Diam's	34482	2022-05-12	0
Nu:Tone	34483	2022-05-12	0
Sylvester	34484	2022-05-12	0
Joe Louis Walker	34485	2022-05-12	0
Madi Simmons	34486	2022-05-12	0
El Canto del Loco	34487	2022-05-12	0
The Love Language	34488	2022-05-12	0
Harlem Hustlers	34489	2022-05-12	0
Beherit	34490	2022-05-12	0
Dangerous Toys	34491	2022-05-12	0
Alien Ant Farm	34492	2022-05-12	0
Bad Habit Boys	34493	2022-05-12	0
Ghetto	34494	2022-05-12	0
Bavgate	34495	2022-05-12	0
Dimmu Borgir	34496	2022-05-12	0
Citizen Fish	34497	2022-05-12	0
Las Niñas	34498	2022-05-12	0
Corvus Corax	34499	2022-05-12	0
East Hundred	34500	2022-05-12	0
Dan Satch & His Atomic 8 Dance Band Of Aba	34501	2022-05-12	0
Dave Clarke	34502	2022-05-12	0
Kilo	34503	2022-05-12	0
Ulises Quintero	34504	2022-05-12	0
Johnny Horton	34505	2022-05-12	0
Whitney Cummings	34506	2022-05-12	0
Morel	34507	2022-05-12	0
Do Androids Dream Of Electric Sheep?	34508	2022-05-12	0
The Vogues	34509	2022-05-12	0
Inhale Exhale	34510	2022-05-12	0
Gianluca Motta	34511	2022-05-12	0
Epicurean	34512	2022-05-12	0
Milla Jovovich	34513	2022-05-12	0
3OH!3	34514	2022-05-12	0
No Me Pises Que Llevo Chanclas	34515	2022-05-12	0
Buy Now!	34516	2022-05-12	0
The Youngbloods	34517	2022-05-12	0
M.I.K.E.	34518	2022-05-12	0
Secret Cinema	34519	2022-05-12	0
Mark Fry	34520	2022-05-12	0
Mightyfools	34521	2022-05-12	0
Left	34522	2022-05-12	0
Revolutionaries	34523	2022-05-12	0
Graaf	34524	2022-05-12	0
Golden Bear	34525	2022-05-12	0
Carl-Johan Vallgren	34526	2022-05-12	0
Sid Bass	34527	2022-05-12	0
Vicki Anderson	34528	2022-05-12	0
Patrick Nuo	34529	2022-05-12	0
Chad & Jeremy	34530	2022-05-12	0
Light In Your Life	34531	2022-05-12	0
Natacha Atlas	34532	2022-05-12	0
Spider Rockets	34533	2022-05-12	0
Savage Grace	34534	2022-05-12	0
Rank Strangers	34535	2022-05-12	0
Hot Leg	34536	2022-05-12	0
City of Prague Philharmonic / Prague Philharmonic Choir / Fitzpatrick	34537	2022-05-12	0
The Urge	34538	2022-05-12	0
Matisse_ Jury Jet	34539	2022-05-12	0
Recorded Live By Alan Lomax	34540	2022-05-12	0
R. Dean Taylor	34541	2022-05-12	0
Nana Mouskouri	34542	2022-05-12	0
Erik Hassle	34543	2022-05-12	0
Anthony B.	34544	2022-05-12	0
The Escape Frame	34545	2022-05-12	0
Christy Nockels	34546	2022-05-12	0
Blash	34547	2022-05-12	0
The Statler Brothers	34548	2022-05-12	0
The Ark	34549	2022-05-12	0
Rufige Kru	34550	2022-05-12	0
Leatherwolf	34551	2022-05-12	0
Cornelis Vreeswijk	34552	2022-05-12	0
The Wedding Present	34553	2022-05-12	0
Use	34554	2022-05-12	0
Gary U.S. Bonds	34555	2022-05-12	0
Herb Eimerman	34556	2022-05-12	0
Pereza	34557	2022-05-12	0
Archie Bell and The Drells	34558	2022-05-12	0
The Creators feat. Consequence	34559	2022-05-12	0
Eric Metronome	34560	2022-05-12	0
Basswood Dollies	34561	2022-05-12	0
Duderstadt & Anita Kelsey	34562	2022-05-12	0
The Folk Band	34563	2022-05-12	0
Nana	34564	2022-05-12	0
The Monolith	34565	2022-05-12	0
Food For Animals	34566	2022-05-12	0
Laurent Voulzy	34567	2022-05-12	0
Michael Mantler_ Jack Bruce_ Marianne Faithfull_ Robert Wyatt	34568	2022-05-12	0
Abysmal Dawn	34569	2022-05-12	0
Uncle Kracker	34570	2022-05-12	0
Idaho	34571	2022-05-12	0
Yotoko	34572	2022-05-12	0
Chely Wright	34573	2022-05-12	0
Moguai	34574	2022-05-12	0
Endstand	34575	2022-05-12	0
Luke Haines & The Auteurs	34576	2022-05-12	0
Capdown	34577	2022-05-12	0
Yukmouth	34578	2022-05-12	0
Flotsam & Jetsam	34579	2022-05-12	0
Bigg Jus	34580	2022-05-12	0
Postal Service	34581	2022-05-12	0
William Basinski	34582	2022-05-12	0
Terry Butler	34583	2022-05-12	0
Sylvan	34584	2022-05-12	0
Victor Manuelle	34585	2022-05-12	0
Tommy Olivencia	34586	2022-05-12	0
Jamie Walters	34587	2022-05-12	0
Serge Devant	34588	2022-05-12	0
Asher D	34589	2022-05-12	0
The French Kicks	34590	2022-05-12	0
Estrella	34591	2022-05-12	0
Traindodge	34592	2022-05-12	0
Slonovski Bal	34593	2022-05-12	0
The Skatoons	34594	2022-05-12	0
Plasmic Honey	34595	2022-05-12	0
Red Light Company	34596	2022-05-12	0
Mysterio	34597	2022-05-12	0
Rhapsody of Fire	34598	2022-05-12	0
Margaret Becker	34599	2022-05-12	0
Neffa	34600	2022-05-12	0
Imiskoubria	34601	2022-05-12	0
The Chipmunks With David Seville	34602	2022-05-12	0
Pixel	34603	2022-05-12	0
Tehosekoitin	34604	2022-05-12	0
You Know	34605	2022-05-12	0
Dawn Landes	34606	2022-05-12	0
ST	34607	2022-05-12	0
Rappin' 4Tay	34608	2022-05-12	0
Youn Sun Nah	34609	2022-05-12	0
Kamelo Punto Semos	34610	2022-05-12	0
Why?	34611	2022-05-12	0
Enoch Light	34612	2022-05-12	0
zero dB	34613	2022-05-12	0
Last Days Of April	34614	2022-05-12	0
Lucinda Williams	34615	2022-05-12	0
Blessid Union Of Souls	34616	2022-05-12	0
The Four Aces feat. Al Roberts	34617	2022-05-12	0
Toshi Reagon	34618	2022-05-12	0
André Rieu	34619	2022-05-12	0
Tom Rush	34620	2022-05-12	0
PATY CANTU	34621	2022-05-12	0
Cliffhanger	34622	2022-05-12	0
Jenny Dee & The Deelinquents	34623	2022-05-12	0
Art Mengo	34624	2022-05-12	0
Björk	34625	2022-05-12	0
Noise Unit	34626	2022-05-12	0
Wilbert Harrison	34627	2022-05-12	0
Macy Gray	34628	2022-05-12	0
Soul Mekanik	34629	2022-05-12	0
Cyril Pahinui_ Bob Brozman	34630	2022-05-12	0
US Coast Guard Band	34631	2022-05-12	0
World (Brent Hunter vs Nina Ramsby)	34632	2022-05-12	0
The Aquabats	34633	2022-05-12	0
Rishi Rich	34634	2022-05-12	0
Blutengel	34635	2022-05-12	0
Soprano	34636	2022-05-12	0
KALYLIVEDUB	34637	2022-05-12	0
Gregor Tresher	34638	2022-05-12	0
This Day & Age	34639	2022-05-12	0
Noemí	34640	2022-05-12	0
Tri Atma	34641	2022-05-12	0
Barbecue Bob	34642	2022-05-12	0
Robert Scott Thompson	34643	2022-05-12	0
Sidsel Endresen & Bugge Wesseltoft	34644	2022-05-12	0
Renegade Soundwave	34645	2022-05-12	0
Triple Fast Action	34646	2022-05-12	0
Al Rapone	34647	2022-05-12	0
Pressure 4-5	34648	2022-05-12	0
Humate	34649	2022-05-12	0
Jonah Jones Quartet	34650	2022-05-12	0
Thomas Trouble vs. Paul Grogan	34651	2022-05-12	0
Fort Knox Five featuring Afrika Bambaataa & King Kamonzi	34652	2022-05-12	0
Will Holland vs. Six Senses	34653	2022-05-12	0
Pride Tiger	34654	2022-05-12	0
SolAce	34655	2022-05-12	0
Jack Johnson / Matt Costa	34656	2022-05-12	0
Yob	34657	2022-05-12	0
Mercury Rain	34658	2022-05-12	0
Six Organs Of Admittance	34659	2022-05-12	0
Djelimady Tounkara	34660	2022-05-12	0
Keba	34661	2022-05-12	0
Marcus Miller	34662	2022-05-12	0
Black Box Recorder	34663	2022-05-12	0
Mylo featuring Freeform Five	34664	2022-05-12	0
Wreckless Eric	34665	2022-05-12	0
Hampton Hawes	34666	2022-05-12	0
Triple C	34667	2022-05-12	0
Bury Your Dead	34668	2022-05-12	0
Hubert Kah	34669	2022-05-12	0
Knobody	34670	2022-05-12	0
Shades of Rhythm	34671	2022-05-12	0
Lisa Lynne	34672	2022-05-12	0
Ride Your Bike	34673	2022-05-12	0
Ogogo	34674	2022-05-12	0
Porter Wagoner & Dolly Parton	34675	2022-05-12	0
Now It's Overhead	34676	2022-05-12	0
Pussy Dub Foundation	34677	2022-05-12	0
Loveland Feat. The Voice Of Rachel McFarlene/ Sandy B/ Sybil	34678	2022-05-12	0
Etienne De Crécy	34679	2022-05-12	0
Syria	34680	2022-05-12	0
Space Buddha	34681	2022-05-12	0
The Toxic Avenger	34682	2022-05-12	0
The Jazz Masters	34683	2022-05-12	0
The Foreign Exchange	34684	2022-05-12	0
Terry Ganzie (feat. Josey Wales)	34685	2022-05-12	0
Ed Calle / Arturo Sandoval / Jim Gasior	34686	2022-05-12	0
Vanden Plas	34687	2022-05-12	0
Shawn Mullins	34688	2022-05-12	0
The Mission District	34689	2022-05-12	0
Dog Fashion Disco	34690	2022-05-12	0
Electric Light Orchestra	34691	2022-05-12	0
Neil Sedaka	34692	2022-05-12	0
Usurp Synapse	34693	2022-05-12	0
FM Einheit_ Gry	34694	2022-05-12	0
Annette Funicello	34695	2022-05-12	0
Headless Heroes	34696	2022-05-12	0
Speedstar*	34697	2022-05-12	0
Shitdisco	34698	2022-05-12	0
Alcohol Funnycar	34699	2022-05-12	0
Meet Me In St Louis	34700	2022-05-12	0
Giovanni	34701	2022-05-12	0
The Field Mice	34702	2022-05-12	0
July	34703	2022-05-12	0
The Charlie Daniels Band	34704	2022-05-12	0
Easily Influenced	34705	2022-05-12	0
Sun Ra And The Year 2000 Myth Science Arkestra	34706	2022-05-12	0
Benny Benassi vs. Iggy Pop	34707	2022-05-12	0
Generation X	34708	2022-05-12	0
Música Dispersa	34709	2022-05-12	0
Matthew Herbert	34710	2022-05-12	0
Kalibas	34711	2022-05-12	0
Horace Silver	34712	2022-05-12	0
Martriden	34713	2022-05-12	0
Crimson	34714	2022-05-12	0
James Scott	34715	2022-05-12	0
Cricco Castelli	34716	2022-05-12	0
Pamelo Mounk'a	34717	2022-05-12	0
CANDLEMASS	34718	2022-05-12	0
Nadia Batson	34719	2022-05-12	0
Flux of Pink Indians	34720	2022-05-12	0
Operation Ivy	34721	2022-05-12	0
Trio Of Doom	34722	2022-05-12	0
Plej	34723	2022-05-12	0
Cloud One	34724	2022-05-12	0
Nu Shooz	34725	2022-05-12	0
Helen Humes	34726	2022-05-12	0
SubArachnoid Space	34727	2022-05-12	0
Omar Pene_ Super Diamono	34728	2022-05-12	0
Terrestrial Tones	34729	2022-05-12	0
Najee	34730	2022-05-12	0
Thomas P.Heckmann	34731	2022-05-12	0
June Star	34732	2022-05-12	0
Carl Thomas	34733	2022-05-12	0
Jon Oliva's Pain	34734	2022-05-12	0
Los Cojones	34735	2022-05-12	0
Juelz Santana / Young Jeezy / Lil Wayne	34736	2022-05-12	0
Solid Globe	34737	2022-05-12	0
Ol' Dirty Bastard	34738	2022-05-12	0
War Tapes	34739	2022-05-12	0
Alfred Newman	34740	2022-05-12	0
Venice	34741	2022-05-12	0
Dead Voices On Air	34742	2022-05-12	0
Ivana Santilli	34743	2022-05-12	0
Kingston Trio	34744	2022-05-12	0
Ephel Duath	34745	2022-05-12	0
Mishi Donovan	34746	2022-05-12	0
Alvin And The Chipmunks	34747	2022-05-12	0
Ricky Zaziky + die Holidays	34748	2022-05-12	0
Ultra Bidé	34749	2022-05-12	0
TSOL	34750	2022-05-12	0
Outkast & Slimm Cutta-Calhoun	34751	2022-05-12	0
Trapt	34752	2022-05-12	0
Crimson Spectre	34753	2022-05-12	0
Max Pezzali /883	34754	2022-05-12	0
Pako Parisi	34755	2022-05-12	0
Alien Breed	34756	2022-05-12	0
Audio Two	34757	2022-05-12	0
Denise Jannah	34758	2022-05-12	0
Spoonfed Hybrid	34759	2022-05-12	0
Ella Mae Morse	34760	2022-05-12	0
Memphis La Blusera	34761	2022-05-12	0
DAY26	34762	2022-05-12	0
Riltons Vänner	34763	2022-05-12	0
Charles Wright & The Watts 103rd. Street Rhythm Band	34764	2022-05-12	0
Marcos Hernandez	34765	2022-05-12	0
DLG (Dark Latin Groove)	34766	2022-05-12	0
La Costa Brava	34767	2022-05-12	0
The Fold	34768	2022-05-12	0
Lexie Mountain Boys	34769	2022-05-12	0
Maria-João Pires	34770	2022-05-12	0
Ed Rush & Optical ft. Ryme Tyme & MC Darrison	34771	2022-05-12	0
Nasio Fontaine	34772	2022-05-12	0
Mack and Jamie	34773	2022-05-12	0
Johnnie Taylor	34774	2022-05-12	0
Kabát	34775	2022-05-12	0
The Last Vegas	34776	2022-05-12	0
Altmodisch	34777	2022-05-12	0
New York Philharmonic;Pierre Boulez	34778	2022-05-12	0
Andrea	34779	2022-05-12	0
John Holt	34780	2022-05-12	0
Stephen Pearcy (of RATT)	34781	2022-05-12	0
Mutabaruka	34782	2022-05-12	0
Tunnel Rats	34783	2022-05-12	0
Farewell	34784	2022-05-12	0
Prodigy	34785	2022-05-12	0
True West	34786	2022-05-12	0
Richard "Groove" Holmes	34787	2022-05-12	0
Skin Area	34788	2022-05-12	0
Herbstrock	34789	2022-05-12	0
Color Humano	34790	2022-05-12	0
Leaether Strip	34791	2022-05-12	0
Jacynthe	34792	2022-05-12	0
Janina	34793	2022-05-12	0
Anonymous 4;Netherlands Radio Choir;Netherlands Radio Philharmonic;Steven Mercurio	34794	2022-05-12	0
Dead Man Ray	34795	2022-05-12	0
Alicia Keys	34796	2022-05-12	0
T.Rextasy	34797	2022-05-12	0
Paul Mauriat	34798	2022-05-12	0
Ed Rush & Optical	34799	2022-05-12	0
Kenny Garrett	34800	2022-05-12	0
Natalia Lafourcade	34801	2022-05-12	0
Anal Cunt	34802	2022-05-12	0
Chris Bailey	34803	2022-05-12	0
Spanish Harlem Orchestra	34804	2022-05-12	0
Solar Quest	34805	2022-05-12	0
SULA	34806	2022-05-12	0
Grace Jones	34807	2022-05-12	0
Children Of Bodom	34808	2022-05-12	0
K.C. Douglas	34809	2022-05-12	0
Seine	34810	2022-05-12	0
Swollen Members	34811	2022-05-12	0
VANESSA & THE O'S	34812	2022-05-12	0
Mose Allison	34813	2022-05-12	0
Eden Weint Im Grab	34814	2022-05-12	0
Shunza	34815	2022-05-12	0
Sidney Bechet	34816	2022-05-12	0
Mike Nichol	34817	2022-05-12	0
New Bruises	34818	2022-05-12	0
Barrett Strong	34819	2022-05-12	0
The Grown-Ups	34820	2022-05-12	0
The Dykeenies	34821	2022-05-12	0
The Thrills	34822	2022-05-12	0
Gaskin	34823	2022-05-12	0
Matthew Wilder	34824	2022-05-12	0
Counting Crows	34825	2022-05-12	0
Coffin Break	34826	2022-05-12	0
Artist Unknown	34827	2022-05-12	0
The Sleepover Disaster	34828	2022-05-12	0
Christina Milian / Young Jeezy	34829	2022-05-12	0
Laura Pausini	34830	2022-05-12	0
Mistress	34831	2022-05-12	0
American Head Charge	34832	2022-05-12	0
Rock Plaza Central	34833	2022-05-12	0
Mohsen Namjoo	34834	2022-05-12	0
Havana Black	34835	2022-05-12	0
Ralph Sliwinski	34836	2022-05-12	0
Chava Alberstein	34837	2022-05-12	0
Graziano Galatone;Rosalia Misseri;Attilio Fontana	34838	2022-05-12	0
The New Seekers	34839	2022-05-12	0
Ryan Banks	34840	2022-05-12	0
Hansi Lang	34841	2022-05-12	0
Omar & The Howlers	34842	2022-05-12	0
The Reunion	34843	2022-05-12	0
Omni Trio	34844	2022-05-12	0
Flowin Immo et Les Freaqz	34845	2022-05-12	0
Pitbull	34846	2022-05-12	0
Black Eyed Peas / Chali 2na	34847	2022-05-12	0
Katrina & The Waves	34848	2022-05-12	0
Flávio José	34849	2022-05-12	0
Red Nichols	34850	2022-05-12	0
Maher Shahal Hash Baz	34851	2022-05-12	0
Alex Bleeker_ The Freaks	34852	2022-05-12	0
Nick Moss_ The Flip Tops	34853	2022-05-12	0
Ben Polack & His Orchestra	34854	2022-05-12	0
Jim Nabors	34855	2022-05-12	0
Rocko Schamoni	34856	2022-05-12	0
Bruce Haack	34857	2022-05-12	0
Vangelis	34858	2022-05-12	0
Scott Ainslie	34859	2022-05-12	0
Joel Grey	34860	2022-05-12	0
João Donato	34861	2022-05-12	0
Jacob Miller	34862	2022-05-12	0
Hacride	34863	2022-05-12	0
Das Oath	34864	2022-05-12	0
Sheer Terror	34865	2022-05-12	0
Tierney Sutton	34866	2022-05-12	0
Seattle Symphony	34867	2022-05-12	0
Salvatore Licitra	34868	2022-05-12	0
Module	34869	2022-05-12	0
Danuel Tate	34870	2022-05-12	0
Because of Ghosts	34871	2022-05-12	0
Silver Apples	34872	2022-05-12	0
Leon Payne	34873	2022-05-12	0
Fritz Wunderlich;Alois Melichar	34874	2022-05-12	0
100 Proof Aged in Soul	34875	2022-05-12	0
Europeans	34876	2022-05-12	0
Fra'n'Kie	34877	2022-05-12	0
Long Distance Calling	34878	2022-05-12	0
Mone	34879	2022-05-12	0
Eddy Grant	34880	2022-05-12	0
Whiskeytown	34881	2022-05-12	0
Widespread Bloodshed	34882	2022-05-12	0
McKinley Mitchell	34883	2022-05-12	0
Martha And The Muffins	34884	2022-05-12	0
Vincent Vallières	34885	2022-05-12	0
Count Dee's Silver Disco Explosion	34886	2022-05-12	0
Obszön Geschöpf	34887	2022-05-12	0
Dave Graney 'N' The Coral Snakes	34888	2022-05-12	0
Billy May & His Orchestra	34889	2022-05-12	0
Septeto Nacional De Ignacio Pineiro	34890	2022-05-12	0
Staffan Linzatti	34891	2022-05-12	0
Nagisa Ni Te	34892	2022-05-12	0
El Combo De Las Estrellas	34893	2022-05-12	0
Scars Of Tomorrow	34894	2022-05-12	0
The Michael Schenker Group	34895	2022-05-12	0
Mory Kanté	34896	2022-05-12	0
Raumpatrouille	34897	2022-05-12	0
Immortal Technique	34898	2022-05-12	0
Paul Miller & Estigma	34899	2022-05-12	0
I Hate You	34900	2022-05-12	0
Tania Maria	34901	2022-05-12	0
The Killer Barbies	34902	2022-05-12	0
Markus Törmälä & FBI Beat	34903	2022-05-12	0
Sheb Wooley	34904	2022-05-12	0
Mayday Parade	34905	2022-05-12	0
Bruce Mitchell	34906	2022-05-12	0
Tara Putra	34907	2022-05-12	0
Foreignland	34908	2022-05-12	0
Jeff Danna_ Mychael Danna	34909	2022-05-12	0
Francis Dunnery	34910	2022-05-12	0
Paul Di'Anno	34911	2022-05-12	0
DJ Paul of Three 6 Mafia	34912	2022-05-12	0
Killa Kyleon_ Lil Boss_ Lil C_ & OG Avery	34913	2022-05-12	0
Ultraman	34914	2022-05-12	0
Funk D'Void	34915	2022-05-12	0
Skeletons And The Kings Of All Cities	34916	2022-05-12	0
Endless Hallway	34917	2022-05-12	0
Terrorvision	34918	2022-05-12	0
Eddy Clearwater	34919	2022-05-12	0
Dungen	34920	2022-05-12	0
Riot	34921	2022-05-12	0
Nickodemus	34922	2022-05-12	0
Nomber 5s	34923	2022-05-12	0
Barbra Streisand;Donna Summer	34924	2022-05-12	0
Mac Dre Presents	34925	2022-05-12	0
Dennis Ferrer	34926	2022-05-12	0
Lightnin' Hopkins	34927	2022-05-12	0
Lewis Parker	34928	2022-05-12	0
Eoghan Heaslip	34929	2022-05-12	0
Bashy	34930	2022-05-12	0
Jean-Pierre Mader	34931	2022-05-12	0
Pony Club	34932	2022-05-12	0
Cassie	34933	2022-05-12	0
Leon Redbone	34934	2022-05-12	0
The Poets;Troels Bech;Lars K. Andersen;Birgitte Bang;Mads Frederik;Torben Engberg;Colin Wilkinson	34935	2022-05-12	0
Steve Chou	34936	2022-05-12	0
Lemon and Kijahman	34937	2022-05-12	0
Nguru	34938	2022-05-12	0
Los Invasores De Nuevo Leon	34939	2022-05-12	0
Born Ruffians	34940	2022-05-12	0
Faye Wong	34941	2022-05-12	0
Danu	34942	2022-05-12	0
Dédé Saint Prix_ Pakatak	34943	2022-05-12	0
Budapest String Quartet	34944	2022-05-12	0
David Byrne & Fatboy Slim feat. Cyndi Lauper	34945	2022-05-12	0
Wheatus	34946	2022-05-12	0
Machinemade God	34947	2022-05-12	0
Dinah Washington / Brook Benton	34948	2022-05-12	0
Swearing At Motorists	34949	2022-05-12	0
2 Eivissa	34950	2022-05-12	0
Eden's Curse	34951	2022-05-12	0
Lucas Prata feat. George LaMond	34952	2022-05-12	0
Nemhain	34953	2022-05-12	0
Compay Segundo	34954	2022-05-12	0
Oscar Brown Jr.	34955	2022-05-12	0
Limp Bizkit	34956	2022-05-12	0
Cuatro Gatos	34957	2022-05-12	0
Marlene Dietrich	34958	2022-05-12	0
Deka	34959	2022-05-12	0
The O.C. Supertones	34960	2022-05-12	0
The Toys	34961	2022-05-12	0
Pepe Pinto - Manolo Caracol	34962	2022-05-12	0
Wide Mouth Mason	34963	2022-05-12	0
Shirley Horn	34964	2022-05-12	0
Earthsuit	34965	2022-05-12	0
Coolio featuring 6'9" & Headliner	34966	2022-05-12	0
Mike Koglin	34967	2022-05-12	0
Gregory Abbott	34968	2022-05-12	0
Rising Lion	34969	2022-05-12	0
Oxmo Puccino	34970	2022-05-12	0
The Crests	34971	2022-05-12	0
Pam Tillis	34972	2022-05-12	0
Sawt El Atlas	34973	2022-05-12	0
Los Delinqüentes	34974	2022-05-12	0
Yuri	34975	2022-05-12	0
Social Distortion	34976	2022-05-12	0
Jerry Ropero Featuring Cozi	34977	2022-05-12	0
Rose Chronicles	34978	2022-05-12	0
Say Hi	34979	2022-05-12	0
Servotron	34980	2022-05-12	0
Clay Crosse	34981	2022-05-12	0
Cerys Matthews	34982	2022-05-12	0
Audio Soul Project feat. Nathan Drew Larsen	34983	2022-05-12	0
Eva Braun	34984	2022-05-12	0
Hacken Lee	34985	2022-05-12	0
Kyoto Drive	34986	2022-05-12	0
Orquesta Reve	34987	2022-05-12	0
Marti Jones	34988	2022-05-12	0
Damita Jo	34989	2022-05-12	0
Biz Markie feat. Elephant Man	34990	2022-05-12	0
Vodka Collins	34991	2022-05-12	0
Carman	34992	2022-05-12	0
Lord Nelson	34993	2022-05-12	0
Misery Signals	34994	2022-05-12	0
Wild Billy Childish & The Musicians of the British Empire	34995	2022-05-12	0
Magna Carta	34996	2022-05-12	0
Dead Or Alive	34997	2022-05-12	0
B.O.S.C.H.	34998	2022-05-12	0
Mel Torme	34999	2022-05-12	0
FLO	35000	2022-05-12	0
The Paddingtons	35001	2022-05-12	0
Salomé De Bahia	35002	2022-05-12	0
Meth Teeth	35003	2022-05-12	0
HEATHEN	35004	2022-05-12	0
Lot Lorien	35005	2022-05-12	0
Moka Only	35006	2022-05-12	0
Jerry Boogie McCain	35007	2022-05-12	0
Up Hygh	35008	2022-05-12	0
Cheb Tarik	35009	2022-05-12	0
Mecanica Popular	35010	2022-05-12	0
The Alchemist	35011	2022-05-12	0
Foyer Des Arts	35012	2022-05-12	0
The Sons Of the Pioneers	35013	2022-05-12	0
Geoff Keezer	35014	2022-05-12	0
Johnny Tillotson	35015	2022-05-12	0
Ted Nugent	35016	2022-05-12	0
[a]pendics.shuffle	35017	2022-05-12	0
Angeline	35018	2022-05-12	0
Nelson Riddle And Orchestra	35019	2022-05-12	0
Dub War	35020	2022-05-12	0
Rilo Kiley	35021	2022-05-12	0
Edward Maya / Vika Jigulina	35022	2022-05-12	0
Dando Shaft	35023	2022-05-12	0
Jacek Sienkiewicz	35024	2022-05-12	0
Bata Illic	35025	2022-05-12	0
Etnica	35026	2022-05-12	0
Melpo Mene	35027	2022-05-12	0
Thunderbirds Are Now!	35028	2022-05-12	0
C-Bo	35029	2022-05-12	0
Judge Dreadd	35030	2022-05-12	0
Rational Youth	35031	2022-05-12	0
Kasey Anderson	35032	2022-05-12	0
Koby Israelite	35033	2022-05-12	0
Nacho Vegas	35034	2022-05-12	0
Jack's Mannequin	35035	2022-05-12	0
Scarlet	35036	2022-05-12	0
Blake Shelton	35037	2022-05-12	0
Jose Merce	35038	2022-05-12	0
Paul Overstreet	35039	2022-05-12	0
Protokoll	35040	2022-05-12	0
The Raveonettes	35041	2022-05-12	0
Slum Village	35042	2022-05-12	0
Para One	35043	2022-05-12	0
Lexy & K-Paul	35044	2022-05-12	0
A Hundred Birds	35045	2022-05-12	0
Phil Lynott	35046	2022-05-12	0
Boyd Raeburn	35047	2022-05-12	0
David Arkenstone	35048	2022-05-12	0
The All-American Rejects	35049	2022-05-12	0
Silicone Soul	35050	2022-05-12	0
Pastor Troy	35051	2022-05-12	0
Tritonal	35052	2022-05-12	0
Uko	35053	2022-05-12	0
Latyrx	35054	2022-05-12	0
Clinic	35055	2022-05-12	0
Gregory Isaacs & Dennis Brown	35056	2022-05-12	0
Antonio Bribiesca	35057	2022-05-12	0
Gavin Rossdale	35058	2022-05-12	0
Peter And Gordon	35059	2022-05-12	0
Bobby Vee	35060	2022-05-12	0
Francis Poulenc	35061	2022-05-12	0
Nena	35062	2022-05-12	0
Frank Lenz	35063	2022-05-12	0
Chris Botti; Vocal by Chris Botti	35064	2022-05-12	0
Marty Wilde	35065	2022-05-12	0
Larsen	35066	2022-05-12	0
Chow Nasty	35067	2022-05-12	0
Giuseppe Di Stefano	35068	2022-05-12	0
Lola Baï	35069	2022-05-12	0
Cherry Bomb	35070	2022-05-12	0
Lizzy Parks	35071	2022-05-12	0
John Gibbons	35072	2022-05-12	0
Anaconda	35073	2022-05-12	0
Shinobu	35074	2022-05-12	0
Amber feat. Sweet Rains	35075	2022-05-12	0
The Elders	35076	2022-05-12	0
Riger	35077	2022-05-12	0
Anthony Hamilton	35078	2022-05-12	0
Elysium	35079	2022-05-12	0
Manolo Sanlucar / Isidro Munoz Alcon / Los Rocieros	35080	2022-05-12	0
Black Box	35081	2022-05-12	0
Lokassa et Soukous Stars	35082	2022-05-12	0
Master Blaster	35083	2022-05-12	0
New Young Pony Club	35084	2022-05-12	0
Apollo 440	35085	2022-05-12	0
Tiziano Ferro	35086	2022-05-12	0
Tihuana	35087	2022-05-12	0
MGMT	35088	2022-05-12	0
Jim McNeely	35089	2022-05-12	0
The Kung Fu Girls	35090	2022-05-12	0
Dean Geyer	35091	2022-05-12	0
Matthew Good Band	35092	2022-05-12	0
Morthem Vlade Art	35093	2022-05-12	0
Darren Bailie	35094	2022-05-12	0
Llorca	35095	2022-05-12	0
Belleruche	35096	2022-05-12	0
Gym Class Heroes	35097	2022-05-12	0
MC Serch	35098	2022-05-12	0
Ferry Corsten	35099	2022-05-12	0
4hero	35100	2022-05-12	0
Format B	35101	2022-05-12	0
Rocio Jurado	35102	2022-05-12	0
The Unseen	35103	2022-05-12	0
Isabel Pantoja	35104	2022-05-12	0
Krishna Das	35105	2022-05-12	0
PlayRadioPlay!	35106	2022-05-12	0
Dzihan & Kamien	35107	2022-05-12	0
N'Dambi	35108	2022-05-12	0
Todd Rhodes and his Orchestra	35109	2022-05-12	0
Outer Circle	35110	2022-05-12	0
LaWanda Page	35111	2022-05-12	0
Mr. Easy & Baby Cham	35112	2022-05-12	0
Ely Guerra	35113	2022-05-12	0
Carl Craig	35114	2022-05-12	0
Chasen	35115	2022-05-12	0
Avishai Cohen Trio	35116	2022-05-12	0
Ricky Skaggs	35117	2022-05-12	0
The Bacon Brothers	35118	2022-05-12	0
Envy On The Coast	35119	2022-05-12	0
The Jim Yoshii Pile-up	35120	2022-05-12	0
Durrty Goodz	35121	2022-05-12	0
Arthur "Big Boy" Crudup	35122	2022-05-12	0
Ewa Firsowicz	35123	2022-05-12	0
Kool Keith	35124	2022-05-12	0
G-Unit	35125	2022-05-12	0
Spiller	35126	2022-05-12	0
Orquesta Aragon	35127	2022-05-12	0
April Stevens	35128	2022-05-12	0
The Joe Perry Project	35129	2022-05-12	0
Jagged Edge	35130	2022-05-12	0
Beenie Man	35131	2022-05-12	0
The Mountain Goats	35132	2022-05-12	0
Arab On Radar	35133	2022-05-12	0
Ahleuchatistas	35134	2022-05-12	0
Rita Lee	35135	2022-05-12	0
Pulp	35136	2022-05-12	0
Violet Columbus	35137	2022-05-12	0
Ultrabeat V Scott Brown	35138	2022-05-12	0
Beck And Allen	35139	2022-05-12	0
Jean Elan	35140	2022-05-12	0
Opus Akoben	35141	2022-05-12	0
Czech Chamber Philharmonic Orchestra_ Douglas Bostock	35142	2022-05-12	0
Stephanie Mills	35143	2022-05-12	0
Aynsley Lister	35144	2022-05-12	0
Dirty Deeds	35145	2022-05-12	0
Big L / Stan Spit	35146	2022-05-12	0
Tulipunaruusut	35147	2022-05-12	0
Blue Roses	35148	2022-05-12	0
Marco Bailey	35149	2022-05-12	0
Craze	35150	2022-05-12	0
The Cobalt Party Revolution	35151	2022-05-12	0
Michael Johnson	35152	2022-05-12	0
Molemen & Memo	35153	2022-05-12	0
Purple Schulz	35154	2022-05-12	0
IC 434	35155	2022-05-12	0
No More Lies	35156	2022-05-12	0
Charlie Wilson featuring T-Pain & Jamie Foxx	35157	2022-05-12	0
Telstar Ponies	35158	2022-05-12	0
Wisin & Yandel	35159	2022-05-12	0
Linus Loves	35160	2022-05-12	0
Joanna Wang	35161	2022-05-12	0
Daddy X	35162	2022-05-12	0
The Blues Brothers	35163	2022-05-12	0
FLASH & THE PAIN feat. Don Martin	35164	2022-05-12	0
Torture Killer	35165	2022-05-12	0
Burning Star Core	35166	2022-05-12	0
Soilwork	35167	2022-05-12	0
The Child Readers	35168	2022-05-12	0
RAMP	35169	2022-05-12	0
Single Bullet Theory	35170	2022-05-12	0
The Human Abstract	35171	2022-05-12	0
Bad Dreams Fancy Dress	35172	2022-05-12	0
Apocalyptica	35173	2022-05-12	0
Ammer - Einheit - Haage	35174	2022-05-12	0
Ruth Etting	35175	2022-05-12	0
Senses Fail	35176	2022-05-12	0
Yvette Horner	35177	2022-05-12	0
Shawn McDonald	35178	2022-05-12	0
Natalie Imbruglia	35179	2022-05-12	0
Timo Maas	35180	2022-05-12	0
Bunnygrunt	35181	2022-05-12	0
Blu Mar Ten	35182	2022-05-12	0
Jay & The Americans	35183	2022-05-12	0
Working Week	35184	2022-05-12	0
Lord Digga	35185	2022-05-12	0
Not Your Average Hippy	35186	2022-05-12	0
Daniela Romo	35187	2022-05-12	0
Kissing Book	35188	2022-05-12	0
Napoleon IIIrd	35189	2022-05-12	0
Chick Corea_ Gary Burton_ Ikwhan Bae_ Carol Shive_ Karen Dreyfus_ Fred Sherry	35190	2022-05-12	0
Six Finger Satellite	35191	2022-05-12	0
Soft Cell	35192	2022-05-12	0
P. R. Kantate	35193	2022-05-12	0
Delta 9	35194	2022-05-12	0
Thirteen Senses	35195	2022-05-12	0
The Brian Setzer Orchestra	35196	2022-05-12	0
Rudeboy Records	35197	2022-05-12	0
Tube-Tech	35198	2022-05-12	0
Warren Barfield	35199	2022-05-12	0
Kids In The Way	35200	2022-05-12	0
Duderstadt & Kirsty Hawkshaw	35201	2022-05-12	0
The Golden Age Orchestra_ Paul Summer 	35202	2022-05-12	0
The Douglas Fir	35203	2022-05-12	0
Random Rabbit	35204	2022-05-12	0
Tankard	35205	2022-05-12	0
Crash Romeo	35206	2022-05-12	0
Ludacris / Beanie Sigel / Pimp C / C-Murder	35207	2022-05-12	0
STORMWITCH	35208	2022-05-12	0
STIX	35209	2022-05-12	0
Donnie Fritts	35210	2022-05-12	0
Ian Broudie	35211	2022-05-12	0
Mindi Abair	35212	2022-05-12	0
Layzie Bone	35213	2022-05-12	0
Illegal Substance	35214	2022-05-12	0
Solomun & Stimming	35215	2022-05-12	0
Dubtribe Sound System	35216	2022-05-12	0
Dave Weckl Band	35217	2022-05-12	0
Ace Karaoke Productions	35218	2022-05-12	0
Ini Kamoze	35219	2022-05-12	0
Martina Topley Bird	35220	2022-05-12	0
The Blasters	35221	2022-05-12	0
Tyler Michaud	35222	2022-05-12	0
International Airport	35223	2022-05-12	0
The Rockingbirds	35224	2022-05-12	0
Golden Smog	35225	2022-05-12	0
Cuco Sánchez	35226	2022-05-12	0
Devon Russell & The Cultural Roots	35227	2022-05-12	0
Harry Choates	35228	2022-05-12	0
Manfred Mann's Earth Band	35229	2022-05-12	0
Jokeren / Anna David	35230	2022-05-12	0
Emma Deigman	35231	2022-05-12	0
The McGuire Sisters	35232	2022-05-12	0
Planetary Assault Systems	35233	2022-05-12	0
Raly Barrionuevo	35234	2022-05-12	0
Late Night Alumni	35235	2022-05-12	0
Wes Montgomery Trio	35236	2022-05-12	0
Nicon	35237	2022-05-12	0
Petey Pablo	35238	2022-05-12	0
Solar Fields	35239	2022-05-12	0
Alvin Lucier	35240	2022-05-12	0
nor elle	35241	2022-05-12	0
Poverty Stinks	35242	2022-05-12	0
Solar House*	35243	2022-05-12	0
DJ Markitos	35244	2022-05-12	0
Remembering Never	35245	2022-05-12	0
Pambo	35246	2022-05-12	0
Saving Aimee	35247	2022-05-12	0
Diplomats of Solid Sound	35248	2022-05-12	0
From Head To Toe	35249	2022-05-12	0
Gene Harris / The Philip Morris Superband	35250	2022-05-12	0
Spayroll	35251	2022-05-12	0
Out Of Order	35252	2022-05-12	0
The Breeders	35253	2022-05-12	0
Tim Love Lee	35254	2022-05-12	0
Any Trouble	35255	2022-05-12	0
Roy Wood	35256	2022-05-12	0
UGK (Underground Kingz)	35257	2022-05-12	0
Auditory Canvas	35258	2022-05-12	0
The Emergency	35259	2022-05-12	0
Sabrina Malheiros	35260	2022-05-12	0
Joe Walsh	35261	2022-05-12	0
Diego Carrasco	35262	2022-05-12	0
Kitbuilders	35263	2022-05-12	0
Eels	35264	2022-05-12	0
Lapsed	35265	2022-05-12	0
Cheap Czad	35266	2022-05-12	0
Rasmus Faber feat. Melo	35267	2022-05-12	0
Jah Shaka	35268	2022-05-12	0
Los Tres Ases	35269	2022-05-12	0
Vic Dana	35270	2022-05-12	0
Little Brother	35271	2022-05-12	0
James Chance & the Contortions	35272	2022-05-12	0
Seventh Star	35273	2022-05-12	0
Jannick Top	35274	2022-05-12	0
Studio Sound Group	35275	2022-05-12	0
Franco De Vita	35276	2022-05-12	0
Electric Company	35277	2022-05-12	0
Brauns & Wagner	35278	2022-05-12	0
Dave Bartholomew	35279	2022-05-12	0
Sadistik Exekution	35280	2022-05-12	0
Hanoi Rocks	35281	2022-05-12	0
Nancy Sinatra Featuring Hal Blaine	35282	2022-05-12	0
Ben Harper And The Innocent Criminals	35283	2022-05-12	0
Stream of Passion feat. Ayreon	35284	2022-05-12	0
Dr. John	35285	2022-05-12	0
Kevin Drumm/Prurient	35286	2022-05-12	0
Medeski Martin & Wood	35287	2022-05-12	0
FONZIE	35288	2022-05-12	0
Matia Bazar	35289	2022-05-12	0
Ken Parker	35290	2022-05-12	0
Love Sculpture	35291	2022-05-12	0
The Dukes Of Stratosphear	35292	2022-05-12	0
Maná	35293	2022-05-12	0
Nikki & The Corvettes	35294	2022-05-12	0
Pepe Deluxe	35295	2022-05-12	0
Core22	35296	2022-05-12	0
Brenda Fassie	35297	2022-05-12	0
Helmet	35298	2022-05-12	0
Peter and The Wolf	35299	2022-05-12	0
Jocco Abendroth	35300	2022-05-12	0
Timbiriche	35301	2022-05-12	0
Anastacia	35302	2022-05-12	0
Louise Attaque	35303	2022-05-12	0
The More I See	35304	2022-05-12	0
Luca Bassi	35305	2022-05-12	0
Dead Soul Tribe	35306	2022-05-12	0
Menswear	35307	2022-05-12	0
MIDI Lidi	35308	2022-05-12	0
Seigmen	35309	2022-05-12	0
Cristy Lane	35310	2022-05-12	0
Vince Guaraldi Trio	35311	2022-05-12	0
Zed	35312	2022-05-12	0
The Beautiful South	35313	2022-05-12	0
Bulgarian State Television Female Choir	35314	2022-05-12	0
La Rabia Del Milenio	35315	2022-05-12	0
John Butcher	35316	2022-05-12	0
Deep Dive Corp	35317	2022-05-12	0
New Boyz	35318	2022-05-12	0
V Sinizter	35319	2022-05-12	0
Be Bop Deluxe	35320	2022-05-12	0
Bjoern Stolpmann	35321	2022-05-12	0
The Gatlin Brothers	35322	2022-05-12	0
Lifetime	35323	2022-05-12	0
Dogs Of Peace	35324	2022-05-12	0
Robbie Robertson	35325	2022-05-12	0
Thomas Dybdahl	35326	2022-05-12	0
The Ponys	35327	2022-05-12	0
Cab Calloway And His Orchestra	35328	2022-05-12	0
Robyn Hitchcock and The Egyptians	35329	2022-05-12	0
Dr. Sapo	35330	2022-05-12	0
Pride Of Lions	35331	2022-05-12	0
Marlene Dietrich - Friedrich Hollaender und seine Jazz-Symphoniker	35332	2022-05-12	0
Riverside	35333	2022-05-12	0
Monobox	35334	2022-05-12	0
Hassaan Mackey	35335	2022-05-12	0
Attitude	35336	2022-05-12	0
Robert Lowery	35337	2022-05-12	0
Los Originales De San Juan	35338	2022-05-12	0
Nick Warren & Jimmy Van M	35339	2022-05-12	0
Len Barry	35340	2022-05-12	0
Olle Adolphson	35341	2022-05-12	0
Ghost Buffalo	35342	2022-05-12	0
Percy Faith	35343	2022-05-12	0
Jordan O'Jordan	35344	2022-05-12	0
ElectroVamp	35345	2022-05-12	0
Zeros	35346	2022-05-12	0
Glenn Yarbrough	35347	2022-05-12	0
The Davenports	35348	2022-05-12	0
Nathan Haines	35349	2022-05-12	0
Airborn Audio	35350	2022-05-12	0
Jazz Jamaica	35351	2022-05-12	0
John C. Reilly	35352	2022-05-12	0
Krypteria	35353	2022-05-12	0
Brad Mehldau Trio	35354	2022-05-12	0
Sergio Vega	35355	2022-05-12	0
Amil (featuring Beyoncé of Destiny's Child)	35356	2022-05-12	0
The Pussycat Dolls	35357	2022-05-12	0
Ludacris	35358	2022-05-12	0
Shirley Collins_ Dolly Collins	35359	2022-05-12	0
Guerilla Black	35360	2022-05-12	0
The Knights	35361	2022-05-12	0
Aphrodesia	35362	2022-05-12	0
Betty Carter	35363	2022-05-12	0
Daniel Kobialka	35364	2022-05-12	0
Ira Atari & Rampue	35365	2022-05-12	0
Body Count	35366	2022-05-12	0
Kalle Baah	35367	2022-05-12	0
RinneRadio	35368	2022-05-12	0
SP	35369	2022-05-12	0
Joey Heatherton	35370	2022-05-12	0
Miike Snow	35371	2022-05-12	0
Rosey	35372	2022-05-12	0
Peace 586	35373	2022-05-12	0
Andy Snitzer	35374	2022-05-12	0
Oblivians	35375	2022-05-12	0
Suicide	35376	2022-05-12	0
Yehudit Ravitz	35377	2022-05-12	0
Lasgo	35378	2022-05-12	0
Intenso	35379	2022-05-12	0
The Regents	35380	2022-05-12	0
We Were Promised Jetpacks	35381	2022-05-12	0
Pol_On	35382	2022-05-12	0
Buildings Breeding	35383	2022-05-12	0
Scott Matthews	35384	2022-05-12	0
Rookie Of The Year	35385	2022-05-12	0
Igneous Flame	35386	2022-05-12	0
The Brilliant Corners	35387	2022-05-12	0
Tommy James & The Shondells	35388	2022-05-12	0
Manu Katché_ Mathias Eick_ Trygve Seim_ Marcin Wasilewski_ Slawomir Kurkiewicz	35389	2022-05-12	0
Ashley Tisdale	35390	2022-05-12	0
Konrad Black	35391	2022-05-12	0
Andrew Weatherall	35392	2022-05-12	0
P. Diddy	35393	2022-05-12	0
Walter Griziotti	35394	2022-05-12	0
Reset	35395	2022-05-12	0
Carla Thomas	35396	2022-05-12	0
Chip Taylor_ Carrie Rodriguez	35397	2022-05-12	0
Mitchy Slick	35398	2022-05-12	0
Watchmaker	35399	2022-05-12	0
Hudson Bell	35400	2022-05-12	0
Dolly Parton / Raul Malo	35401	2022-05-12	0
Paul Thorn	35402	2022-05-12	0
Lms Feat. E.m.p.	35403	2022-05-12	0
The Grouch & Eligh	35404	2022-05-12	0
dEUS	35405	2022-05-12	0
I Was Totally Destroying It	35406	2022-05-12	0
The Somatics	35407	2022-05-12	0
Sub Version	35408	2022-05-12	0
Geoff Muldaur	35409	2022-05-12	0
I Wayne	35410	2022-05-12	0
Tony Thomas	35411	2022-05-12	0
Los Auténticos Decadentes	35412	2022-05-12	0
Salt	35413	2022-05-12	0
Manian	35414	2022-05-12	0
Prymary	35415	2022-05-12	0
Lee Lessack and Stephen Schwartz	35416	2022-05-12	0
World Party	35417	2022-05-12	0
Jean Claude Ades	35418	2022-05-12	0
Will Ackerman	35419	2022-05-12	0
Mallu Magalhães	35420	2022-05-12	0
The Planet Smashers	35421	2022-05-12	0
Mighty Joe Young	35422	2022-05-12	0
The Rippingtons	35423	2022-05-12	0
The Unkool Hillbillies	35424	2022-05-12	0
Peppino D'Agostino	35425	2022-05-12	0
Danny O'Keefe	35426	2022-05-12	0
Save As	35427	2022-05-12	0
Bonnie Tyler	35428	2022-05-12	0
La Banda Municipal del Polo Norte	35429	2022-05-12	0
Gabriel Yacoub	35430	2022-05-12	0
Geier Sturzflug	35431	2022-05-12	0
Underground Resistance	35432	2022-05-12	0
Johnny Otis Show	35433	2022-05-12	0
Joey DeFrancesco / Jimmy Smith	35434	2022-05-12	0
Overnite	35435	2022-05-12	0
Natalia Lafourcade;Julieta Venegas	35436	2022-05-12	0
2 LIVE CREW	35437	2022-05-12	0
The Dirty Backbeats	35438	2022-05-12	0
Chuck Willis	35439	2022-05-12	0
Patrick Andy	35440	2022-05-12	0
Elliot Easton	35441	2022-05-12	0
One Man Army And The Undead Quartet	35442	2022-05-12	0
Clyde Carson	35443	2022-05-12	0
Bram Vermeulen	35444	2022-05-12	0
Rafa Serna	35445	2022-05-12	0
A Hawk And A Hacksaw	35446	2022-05-12	0
Eric Matthews	35447	2022-05-12	0
Scud Mountain Boys	35448	2022-05-12	0
Balla et ses Balladins	35449	2022-05-12	0
Fermin Soto	35450	2022-05-12	0
Georg Friedrich Händel	35451	2022-05-12	0
I-20 Featuring Devin The Dude	35452	2022-05-12	0
The Grid	35453	2022-05-12	0
Celeste Carballo	35454	2022-05-12	0
Lorena	35455	2022-05-12	0
Stereophonic Space Sound Unlimited	35456	2022-05-12	0
Yoshihiro Hanno	35457	2022-05-12	0
Million Stylez	35458	2022-05-12	0
Bettie Serveert	35459	2022-05-12	0
American Princes	35460	2022-05-12	0
Swell Maps	35461	2022-05-12	0
In Extremo	35462	2022-05-12	0
Jovine	35463	2022-05-12	0
AUDIOSCAPE	35464	2022-05-12	0
Latin Breed	35465	2022-05-12	0
Voces Del Rancho	35466	2022-05-12	0
Luis Enriquez Bacalov	35467	2022-05-12	0
Carl B	35468	2022-05-12	0
Silvain Vanot	35469	2022-05-12	0
Morbid Angel	35470	2022-05-12	0
Shed Seven	35471	2022-05-12	0
Cripple Clarence Lofton	35472	2022-05-12	0
Millie Jackson	35473	2022-05-12	0
Last Autumn's Dream	35474	2022-05-12	0
Event Horizon	35475	2022-05-12	0
Elbow	35476	2022-05-12	0
Tummler	35477	2022-05-12	0
Ray Brown Trio / Ralph Moore	35478	2022-05-12	0
The Booked	35479	2022-05-12	0
Bob Evans	35480	2022-05-12	0
Holy Soldier	35481	2022-05-12	0
Alejandro Escovedo	35482	2022-05-12	0
Narkoi	35483	2022-05-12	0
Max Graham	35484	2022-05-12	0
Bescenta	35485	2022-05-12	0
Ben Folds	35486	2022-05-12	0
Babylonia	35487	2022-05-12	0
Freestyle	35488	2022-05-12	0
The Buff Medways	35489	2022-05-12	0
Joe Sample	35490	2022-05-12	0
Miss Napalm	35491	2022-05-12	0
Juliet Jonesin Sydan	35492	2022-05-12	0
Jerry Holland	35493	2022-05-12	0
Dot Dot Curve	35494	2022-05-12	0
Christine Anu	35495	2022-05-12	0
Johnny Dyer	35496	2022-05-12	0
Dédé Saint-Prix	35497	2022-05-12	0
Lemar	35498	2022-05-12	0
The Lords	35499	2022-05-12	0
Sylvester Palmer	35500	2022-05-12	0
Red Nichols & His Five Pennies	35501	2022-05-12	0
Jeff Healey	35502	2022-05-12	0
Johnny Van Zandt	35503	2022-05-12	0
Because	35504	2022-05-12	0
SemiBruce	35505	2022-05-12	0
Tove Styrke	35506	2022-05-12	0
THE TOM ROBINSON BAND	35507	2022-05-12	0
Jim Jones / Hell Rell	35508	2022-05-12	0
Peter Gallagher	35509	2022-05-12	0
Dawn Kinnard	35510	2022-05-12	0
John Lewis	35511	2022-05-12	0
Mandalay	35512	2022-05-12	0
2 In Da Bush	35513	2022-05-12	0
Marcel Et Son Orchestre	35514	2022-05-12	0
Midget Loco	35515	2022-05-12	0
Hardcore Superstar	35516	2022-05-12	0
Tim Hughes	35517	2022-05-12	0
Bad Cash Quartet	35518	2022-05-12	0
Mr Lee	35519	2022-05-12	0
El Tri	35520	2022-05-12	0
The Rewinds	35521	2022-05-12	0
Banco Del Mutuo Soccorso	35522	2022-05-12	0
Discotronic	35523	2022-05-12	0
Tila Tequila	35524	2022-05-12	0
The Dave Brubeck Quartet	35525	2022-05-12	0
The Flat Duo Jets	35526	2022-05-12	0
DJ SS	35527	2022-05-12	0
Cloudland Canyon	35528	2022-05-12	0
Sheik Tosado	35529	2022-05-12	0
Cut La Roc	35530	2022-05-12	0
Jazz Liberatorz	35531	2022-05-12	0
Silverchair	35532	2022-05-12	0
Family Fodder	35533	2022-05-12	0
Gunslingers	35534	2022-05-12	0
Phil Thornton	35535	2022-05-12	0
Nico	35536	2022-05-12	0
Junior Reid	35537	2022-05-12	0
Gregor Salto ft. Helena Mendes	35538	2022-05-12	0
Santana featuring Eric Clapton	35539	2022-05-12	0
JACK SAVORETTI	35540	2022-05-12	0
Once11	35541	2022-05-12	0
K-OS	35542	2022-05-12	0
Skarhead	35543	2022-05-12	0
Peixe:Avião	35544	2022-05-12	0
Greg Keelor	35545	2022-05-12	0
Tommy Johnson	35546	2022-05-12	0
Jah Cure	35547	2022-05-12	0
Sarah Dougher	35548	2022-05-12	0
John Mayer Tribute	35549	2022-05-12	0
A Forest Mighty Black	35550	2022-05-12	0
Red Peters	35551	2022-05-12	0
Joniveli	35552	2022-05-12	0
Screaming Trees	35553	2022-05-12	0
The Wildhearts	35554	2022-05-12	0
Familiar Faces	35555	2022-05-12	0
Bullwackies All Stars	35556	2022-05-12	0
Billy Ray Cyrus	35557	2022-05-12	0
Orange Goblin	35558	2022-05-12	0
Ranking Joe	35559	2022-05-12	0
Dalek I Love You	35560	2022-05-12	0
William Elliott Whitmore	35561	2022-05-12	0
Don Davis	35562	2022-05-12	0
DAMA	35563	2022-05-12	0
AG	35564	2022-05-12	0
The Florida Boys	35565	2022-05-12	0
Greg Lake	35566	2022-05-12	0
David Arkenstone/Kostia	35567	2022-05-12	0
RareForm	35568	2022-05-12	0
Pepe Marchena	35569	2022-05-12	0
Katia B	35570	2022-05-12	0
Special Forces	35571	2022-05-12	0
Friendly Fires	35572	2022-05-12	0
Flying Saucer Attack	35573	2022-05-12	0
Lucky cupids	35574	2022-05-12	0
The Undecided	35575	2022-05-12	0
Paul Anka	35576	2022-05-12	0
Bill Evans Quintet	35577	2022-05-12	0
Jefre Cantu-Ledesma	35578	2022-05-12	0
Randy Rogers Band	35579	2022-05-12	0
The Great American Main Street Band	35580	2022-05-12	0
Big Face	35581	2022-05-12	0
OJ Da Juiceman	35582	2022-05-12	0
Mark Stewart	35583	2022-05-12	0
Hail Of Bullets	35584	2022-05-12	0
Da Weasel	35585	2022-05-12	0
Michael Crawford	35586	2022-05-12	0
Hott 22	35587	2022-05-12	0
Silkk The Shocker Featuring Master P	35588	2022-05-12	0
Mariachi Vargas De Tecalitlán	35589	2022-05-12	0
Pigface	35590	2022-05-12	0
Days In December	35591	2022-05-12	0
Tony Mason-Cox	35592	2022-05-12	0
Jon-Jon Funk Phenomenon	35593	2022-05-12	0
Zentex	35594	2022-05-12	0
Sivert Höyem	35595	2022-05-12	0
Amos Lee	35596	2022-05-12	0
Blok 57	35597	2022-05-12	0
Phonique Feat. Erlend Oye	35598	2022-05-12	0
Anita O'Day	35599	2022-05-12	0
Frida	35600	2022-05-12	0
King Tubby / The Aggrovators	35601	2022-05-12	0
Cuentos Borgeanos	35602	2022-05-12	0
Die Antwort	35603	2022-05-12	0
CMX	35604	2022-05-12	0
Linear	35605	2022-05-12	0
Sheek Louch	35606	2022-05-12	0
Refused	35607	2022-05-12	0
Sebastian	35608	2022-05-12	0
Vex Red	35609	2022-05-12	0
Bronn Journey	35610	2022-05-12	0
Thistle	35611	2022-05-12	0
9th Prince	35612	2022-05-12	0
Slightly Stoopid	35613	2022-05-12	0
Heart Set Self Destruct	35614	2022-05-12	0
Jack Nitzsche	35615	2022-05-12	0
Bluetech	35616	2022-05-12	0
MC  SHY D	35617	2022-05-12	0
Solvent	35618	2022-05-12	0
Hamid El Shari	35619	2022-05-12	0
Stabilizers	35620	2022-05-12	0
Myriam	35621	2022-05-12	0
Besh O Drom	35622	2022-05-12	0
Haris C	35623	2022-05-12	0
Renz Julian	35624	2022-05-12	0
Radka Toneff	35625	2022-05-12	0
Sunset Project	35626	2022-05-12	0
Lamont Cranston Blues Band	35627	2022-05-12	0
Brother Firetribe	35628	2022-05-12	0
The Wild Tchoupitoulas	35629	2022-05-12	0
Marissa Nadler	35630	2022-05-12	0
OutKast	35631	2022-05-12	0
Jackhigh	35632	2022-05-12	0
Mecano	35633	2022-05-12	0
Funeral For A Friend	35634	2022-05-12	0
George McCrae	35635	2022-05-12	0
Massilia Sound System	35636	2022-05-12	0
The Smithereens	35637	2022-05-12	0
Nestor en Bloque	35638	2022-05-12	0
Sonique	35639	2022-05-12	0
Richard Hawley	35640	2022-05-12	0
Anne Murray	35641	2022-05-12	0
Anberlin	35642	2022-05-12	0
Johnny B. Moore	35643	2022-05-12	0
Los Limones	35644	2022-05-12	0
Big Tymers / Lac / Stone / Mikkey	35645	2022-05-12	0
Whiskey Daredevils	35646	2022-05-12	0
The Thousand Dollar Playboys	35647	2022-05-12	0
Eddie Jefferson	35648	2022-05-12	0
Atomic Pulse	35649	2022-05-12	0
Niels Frevert	35650	2022-05-12	0
Bim Sherman	35651	2022-05-12	0
Carlos Lyra	35652	2022-05-12	0
Let Loose	35653	2022-05-12	0
Moistboyz	35654	2022-05-12	0
I Teppisti dei Sogni	35655	2022-05-12	0
Henry Mancini And His Concert Orchestra	35656	2022-05-12	0
Styrofoam	35657	2022-05-12	0
The Ends	35658	2022-05-12	0
Bobby "Blue" Bland	35659	2022-05-12	0
Dark Fortress	35660	2022-05-12	0
Diamond Rio	35661	2022-05-12	0
La Hungara	35662	2022-05-12	0
Nina Hagen	35663	2022-05-12	0
Russ Freeman	35664	2022-05-12	0
Freshlyground / Freshlyground	35665	2022-05-12	0
Milez Benjiman	35666	2022-05-12	0
Tina Dico	35667	2022-05-12	0
Miss Pooja	35668	2022-05-12	0
Nathan Fake	35669	2022-05-12	0
Electric West	35670	2022-05-12	0
Claudio	35671	2022-05-12	0
Kenso	35672	2022-05-12	0
august engkilde	35673	2022-05-12	0
Vivid	35674	2022-05-12	0
Noe Venable	35675	2022-05-12	0
Gwyn Ashton	35676	2022-05-12	0
Raimundos	35677	2022-05-12	0
Fold Zandura	35678	2022-05-12	0
Swan Lake & The Nutcracker	35679	2022-05-12	0
Micropoint	35680	2022-05-12	0
Rafet El Roman	35681	2022-05-12	0
Woddy Herman	35682	2022-05-12	0
Logistics	35683	2022-05-12	0
Dolores Keane	35684	2022-05-12	0
Djedjotronic Feat. Spoek	35685	2022-05-12	0
Neal Hefti	35686	2022-05-12	0
Abe Duque and Gennaro Lefosse	35687	2022-05-12	0
Buck Howdy	35688	2022-05-12	0
Lord T & Eloise	35689	2022-05-12	0
Kris Kristofferson;Willie Nelson	35690	2022-05-12	0
SPL	35691	2022-05-12	0
Flying Pickets	35692	2022-05-12	0
Ricardo	35693	2022-05-12	0
Tanya Tucker	35694	2022-05-12	0
No Gravity	35695	2022-05-12	0
FESS WILLIAMS AND HIS ROYAL FLUSH ORCHESTRA	35696	2022-05-12	0
Guadalcanal Diary	35697	2022-05-12	0
Bouncing Souls_ The	35698	2022-05-12	0
Mae Moore	35699	2022-05-12	0
Rob Barbosa	35700	2022-05-12	0
Rasputina	35701	2022-05-12	0
Skyzoo	35702	2022-05-12	0
Bis	35703	2022-05-12	0
Paul James	35704	2022-05-12	0
MOZ	35705	2022-05-12	0
Coburn	35706	2022-05-12	0
Little Anthony and The Imperials	35707	2022-05-12	0
Johnny Foreigner	35708	2022-05-12	0
Tim Keegan	35709	2022-05-12	0
Son de la Frontera	35710	2022-05-12	0
Nikki Sudden	35711	2022-05-12	0
Alter Der Ruine	35712	2022-05-12	0
Sylk 130	35713	2022-05-12	0
Owen Temple	35714	2022-05-12	0
Zero Hour	35715	2022-05-12	0
Ólafur Arnalds	35716	2022-05-12	0
Liza Li	35717	2022-05-12	0
Eman & Doc Link	35718	2022-05-12	0
Joseph Suk	35719	2022-05-12	0
Wetdog	35720	2022-05-12	0
Painbastard	35721	2022-05-12	0
Late feat. Genesis Elijah_ Supar Novar & Manny Moscow	35722	2022-05-12	0
The Red Clay Ramblers with Fiddlin' Al McCanless	35723	2022-05-12	0
Wackies	35724	2022-05-12	0
Les Misérables	35725	2022-05-12	0
Smif-n-Wessun	35726	2022-05-12	0
Wally Lopez	35727	2022-05-12	0
Tenor Saw	35728	2022-05-12	0
Five Iron Frenzy	35729	2022-05-12	0
Ultrabeat vs Darren Styles	35730	2022-05-12	0
Kevon Edmonds	35731	2022-05-12	0
Olav Basoski	35732	2022-05-12	0
Philipp Poisel	35733	2022-05-12	0
DJ Joe K.	35734	2022-05-12	0
DnD	35735	2022-05-12	0
Bruno Pronsato	35736	2022-05-12	0
Sweetback	35737	2022-05-12	0
Rocio Durcal & Juan Gabriel	35738	2022-05-12	0
Red Simpson	35739	2022-05-12	0
King Orgasmus One feat. Bass Sultan Hengzt	35740	2022-05-12	0
Kevin Costner & Modern West	35741	2022-05-12	0
10 Years	35742	2022-05-12	0
Duderstadt vs. Store N Forward	35743	2022-05-12	0
Akira Kosemura	35744	2022-05-12	0
Michel Camilo / BBC Symphony Orchestra / Leonard Slatkin	35745	2022-05-12	0
Children On Stun	35746	2022-05-12	0
Prozak	35747	2022-05-12	0
Edson Gomes	35748	2022-05-12	0
Sileas	35749	2022-05-12	0
Richard Lloyd	35750	2022-05-12	0
sinKing	35751	2022-05-12	0
Face To Face	35752	2022-05-12	0
Breakbeat Era	35753	2022-05-12	0
Hocico	35754	2022-05-12	0
Mahalia Jackson	35755	2022-05-12	0
George Winston	35756	2022-05-12	0
Baker Gurvitz Army	35757	2022-05-12	0
Alan Moorhouse Band	35758	2022-05-12	0
Marni Nixon	35759	2022-05-12	0
Tolchock	35760	2022-05-12	0
Wet Wet Wet	35761	2022-05-12	0
Big Bud	35762	2022-05-12	0
Goksel Baktagir	35763	2022-05-12	0
Racoon	35764	2022-05-12	0
Naked Aggression	35765	2022-05-12	0
Contone	35766	2022-05-12	0
State Of Being	35767	2022-05-12	0
the Fear and the Yearning	35768	2022-05-12	0
Ricardo Tobar	35769	2022-05-12	0
Robedoor	35770	2022-05-12	0
Sebastian Brandt	35771	2022-05-12	0
Fionn Regan	35772	2022-05-12	0
Mix Speaker's_Inc.	35773	2022-05-12	0
Eastern Standard Time	35774	2022-05-12	0
Scott Krippayne	35775	2022-05-12	0
Pink Satellite	35776	2022-05-12	0
Big Punisher	35777	2022-05-12	0
Phunk Junkeez	35778	2022-05-12	0
The Gonads featuring Kid Punk	35779	2022-05-12	0
Ray Knox	35780	2022-05-12	0
Meindert Talma	35781	2022-05-12	0
The Slickers	35782	2022-05-12	0
Moving Hearts	35783	2022-05-12	0
Little Joe	35784	2022-05-12	0
Nice Face	35785	2022-05-12	0
Akhenaton	35786	2022-05-12	0
Poems For Laila	35787	2022-05-12	0
Annotations of an Autopsy	35788	2022-05-12	0
Arsen Shomakhov	35789	2022-05-12	0
Puerto Rican Power	35790	2022-05-12	0
Hilt	35791	2022-05-12	0
Four80East	35792	2022-05-12	0
Ronnie Laws And Pressure	35793	2022-05-12	0
Sussie 4	35794	2022-05-12	0
Flying Saucer Attack and Roy Montgomery	35795	2022-05-12	0
Wayne Newton	35796	2022-05-12	0
Russ Morgan And Eddie Wilser	35797	2022-05-12	0
Go-Kart Mozart	35798	2022-05-12	0
Nora Dean	35799	2022-05-12	0
Anneli Drecker	35800	2022-05-12	0
Commix	35801	2022-05-12	0
Julian Jay Savarin	35802	2022-05-12	0
De Dannan	35803	2022-05-12	0
Acoustic Strawbs	35804	2022-05-12	0
Verano	35805	2022-05-12	0
The Cheeky Girls	35806	2022-05-12	0
Wild Palms	35807	2022-05-12	0
Freeform	35808	2022-05-12	0
Terry Callier	35809	2022-05-12	0
Exodus	35810	2022-05-12	0
Rex Gildo	35811	2022-05-12	0
Cesária Évora	35812	2022-05-12	0
Omara Portuando	35813	2022-05-12	0
Audra McDonald;Kimberly JaJuan	35814	2022-05-12	0
Seru Giran	35815	2022-05-12	0
U. Brown	35816	2022-05-12	0
Art Ensemble Of Chicago	35817	2022-05-12	0
Bass Patrol	35818	2022-05-12	0
Billy Walker	35819	2022-05-12	0
Lucia Micarelli	35820	2022-05-12	0
Prisma	35821	2022-05-12	0
Edgar Froese	35822	2022-05-12	0
Plastiscines	35823	2022-05-12	0
Vuneny	35824	2022-05-12	0
Heidi Berry	35825	2022-05-12	0
Rachid Taha	35826	2022-05-12	0
Peter Van Hoesen	35827	2022-05-12	0
DJ Nehpets	35828	2022-05-12	0
Elle Belga	35829	2022-05-12	0
Rima	35830	2022-05-12	0
Big Mello	35831	2022-05-12	0
El Viejín	35832	2022-05-12	0
Haunted Garage	35833	2022-05-12	0
Palito Ortega	35834	2022-05-12	0
The Jacka feat E-40_ Mitchy Slick and Jynx	35835	2022-05-12	0
Kid Sensation	35836	2022-05-12	0
Built To Spill	35837	2022-05-12	0
Howard Goodall	35838	2022-05-12	0
Death SS	35839	2022-05-12	0
queen AaMinah	35840	2022-05-12	0
Proper Dos	35841	2022-05-12	0
L'S'K'	35842	2022-05-12	0
Nullskattesnylterne	35843	2022-05-12	0
Sir Douglas Quintet	35844	2022-05-12	0
Giannis Tassios	35845	2022-05-12	0
Randy Meisner	35846	2022-05-12	0
DL Incognito	35847	2022-05-12	0
Snoop Dogg ft. Ice T	35848	2022-05-12	0
Jaw	35849	2022-05-12	0
Mattias Alkberg BD	35850	2022-05-12	0
The Winstons	35851	2022-05-12	0
Chris Spedding	35852	2022-05-12	0
Aim	35853	2022-05-12	0
Kawasaki 3P	35854	2022-05-12	0
Lovemakers	35855	2022-05-12	0
Manuel Vallejo	35856	2022-05-12	0
Jan Jelinek + Computer Soup	35857	2022-05-12	0
Thomas Leer	35858	2022-05-12	0
Starbuck	35859	2022-05-12	0
Bob Welch	35860	2022-05-12	0
Roxy Music	35861	2022-05-12	0
The Heavy	35862	2022-05-12	0
Fused	35863	2022-05-12	0
Stacccato	35864	2022-05-12	0
Tish Hinojosa	35865	2022-05-12	0
Rihanna feat. J-Status	35866	2022-05-12	0
Mazz	35867	2022-05-12	0
X-Ray Spex	35868	2022-05-12	0
The Mother Goose Singers	35869	2022-05-12	0
Ralph Myerz And The Jack Herren Band	35870	2022-05-12	0
José Alfredo Jimenez	35871	2022-05-12	0
Kiko Navarro	35872	2022-05-12	0
Ashley Gearing	35873	2022-05-12	0
Violadores del Verso	35874	2022-05-12	0
Jah Wobble & The Invaders of the Heart	35875	2022-05-12	0
Cripple Bastards	35876	2022-05-12	0
Sebastien Grainger & The Mountains	35877	2022-05-12	0
The Loch Ness Mouse	35878	2022-05-12	0
Warumpi Band	35879	2022-05-12	0
Edmond Leung	35880	2022-05-12	0
Cosmic Rough Riders	35881	2022-05-12	0
Poney Poney	35882	2022-05-12	0
Shotta	35883	2022-05-12	0
Dario G	35884	2022-05-12	0
Curtis Mayfield	35885	2022-05-12	0
Art Blakey	35886	2022-05-12	0
Android Cartel	35887	2022-05-12	0
Blakfish	35888	2022-05-12	0
Alien's Cab	35889	2022-05-12	0
The Supernaturals	35890	2022-05-12	0
Corrupted Ideals	35891	2022-05-12	0
Everclear	35892	2022-05-12	0
Mike Shiver	35893	2022-05-12	0
Cosmic Gate feat. Aruna	35894	2022-05-12	0
The Coctails	35895	2022-05-12	0
The Steepwater Band	35896	2022-05-12	0
Soultourist	35897	2022-05-12	0
Drunk Horse	35898	2022-05-12	0
Claude King	35899	2022-05-12	0
The Everly Brothers with;Simon & Garfunkel	35900	2022-05-12	0
Anthony Evans	35901	2022-05-12	0
The Subtle Way	35902	2022-05-12	0
Samman	35903	2022-05-12	0
Situation 2wo	35904	2022-05-12	0
Joe Crepusculo	35905	2022-05-12	0
Destroyer 666	35906	2022-05-12	0
Anita Ellis	35907	2022-05-12	0
Eddy Howard	35908	2022-05-12	0
Santa And His Little Helpers	35909	2022-05-12	0
Kim English	35910	2022-05-12	0
Alex Neri & Federico Locchi	35911	2022-05-12	0
Hallucinogen	35912	2022-05-12	0
Yves Murasca feat. Kyra	35913	2022-05-12	0
Lionel Richie	35914	2022-05-12	0
Fury of the Headteachers	35915	2022-05-12	0
Eddie Calvert	35916	2022-05-12	0
Paul Haslinger	35917	2022-05-12	0
Amil	35918	2022-05-12	0
United Sounds	35919	2022-05-12	0
Sing It Loud	35920	2022-05-12	0
Baby Boy Da Prince	35921	2022-05-12	0
Nerf Herder	35922	2022-05-12	0
The Network	35923	2022-05-12	0
Razz	35924	2022-05-12	0
Kill Switch& Klick	35925	2022-05-12	0
The Dandy Warhols	35926	2022-05-12	0
Gene Loves Jezebel	35927	2022-05-12	0
KC And The Sunshine Band	35928	2022-05-12	0
Bikram Singh	35929	2022-05-12	0
Liberty Ellman	35930	2022-05-12	0
Perry Silverbird	35931	2022-05-12	0
Encre	35932	2022-05-12	0
The Mars Volta	35933	2022-05-12	0
Ne Luumaet	35934	2022-05-12	0
Miriodor	35935	2022-05-12	0
Sarah Chen	35936	2022-05-12	0
Gabardine	35937	2022-05-12	0
André van Duin	35938	2022-05-12	0
Ride The Blinds	35939	2022-05-12	0
Eternia	35940	2022-05-12	0
Bernd Begemann & die Befreiung	35941	2022-05-12	0
Duoteque	35942	2022-05-12	0
Eino Gron	35943	2022-05-12	0
Mr Oizo	35944	2022-05-12	0
Chuck Loeb	35945	2022-05-12	0
Stefan Grossman	35946	2022-05-12	0
Musica Antiqua Köln / Reinhard Goebel	35947	2022-05-12	0
Ed Johnson & Novo Tempo	35948	2022-05-12	0
Tiny Vipers	35949	2022-05-12	0
Eugene Hideaway Bridges	35950	2022-05-12	0
2econd Class Citizen	35951	2022-05-12	0
Cookies	35952	2022-05-12	0
I Haunt Wizards	35953	2022-05-12	0
Theatre of Hate	35954	2022-05-12	0
Davol	35955	2022-05-12	0
John Scofield	35956	2022-05-12	0
Rauschfaktor	35957	2022-05-12	0
Jay Lumen	35958	2022-05-12	0
Beyond Twilight	35959	2022-05-12	0
Five	35960	2022-05-12	0
Jets To Brazil	35961	2022-05-12	0
Hudson Mohawke	35962	2022-05-12	0
It Dies Today	35963	2022-05-12	0
Eddie C. Campbell	35964	2022-05-12	0
Lou Christie	35965	2022-05-12	0
Bronco	35966	2022-05-12	0
Whipping Boy	35967	2022-05-12	0
Naoki Kenji	35968	2022-05-12	0
Baby Buh	35969	2022-05-12	0
Infinite Livez Vs Stade	35970	2022-05-12	0
J-Live	35971	2022-05-12	0
Ray Brown	35972	2022-05-12	0
Lil Mark	35973	2022-05-12	0
Steady B	35974	2022-05-12	0
Robin Trower	35975	2022-05-12	0
Mad Caddies	35976	2022-05-12	0
Raimundo Amador / B.B. King	35977	2022-05-12	0
Soho	35978	2022-05-12	0
2 Belgen	35979	2022-05-12	0
The Black Noodle Project	35980	2022-05-12	0
Da Sunlounge	35981	2022-05-12	0
The Returners	35982	2022-05-12	0
Cream (Hong Kong)	35983	2022-05-12	0
Bass Alliance	35984	2022-05-12	0
The Cancer Conspiracy	35985	2022-05-12	0
The Aimless Never Miss	35986	2022-05-12	0
Love & Money	35987	2022-05-12	0
The Force	35988	2022-05-12	0
Monica Zetterlund	35989	2022-05-12	0
Raphaël	35990	2022-05-12	0
Altan	35991	2022-05-12	0
Hawk Nelson	35992	2022-05-12	0
2 Brothers On The 4th Floor	35993	2022-05-12	0
Letu Stuke	35994	2022-05-12	0
Buzzhorn	35995	2022-05-12	0
Gus Gus / Ian Brown	35996	2022-05-12	0
Marcelo Radulovich	35997	2022-05-12	0
Alice Cooper	35998	2022-05-12	0
El Inquilino Comunista	35999	2022-05-12	0
Grey Area	36000	2022-05-12	0
Whitney Houston featuring Akon	36001	2022-05-12	0
Billy Crockett	36002	2022-05-12	0
Danger Doom	36003	2022-05-12	0
Cursor Miner	36004	2022-05-12	0
Fiona Sit	36005	2022-05-12	0
Charlie Louvin	36006	2022-05-12	0
Plastic Noise Experience	36007	2022-05-12	0
Lamb	36008	2022-05-12	0
Acid King	36009	2022-05-12	0
Y Dyniadon Ynfyd Hirfelyn Tesog	36010	2022-05-12	0
Rachid Taha / Khaled / Faudel	36011	2022-05-12	0
Manuel	36012	2022-05-12	0
Activa Vs. Tom Colontonio	36013	2022-05-12	0
The Isley Brothers / Ronald Isley	36014	2022-05-12	0
Heartsrevolution	36015	2022-05-12	0
Joselito	36016	2022-05-12	0
Jill Cunniff	36017	2022-05-12	0
Onar	36018	2022-05-12	0
Rose Polenzani	36019	2022-05-12	0
The Swell Season	36020	2022-05-12	0
Gal Costa	36021	2022-05-12	0
The Wolfmen	36022	2022-05-12	0
The Primitives	36023	2022-05-12	0
I:Scintilla	36024	2022-05-12	0
Master P	36025	2022-05-12	0
Funeral Diner	36026	2022-05-12	0
J Nash	36027	2022-05-12	0
Tre'	36028	2022-05-12	0
Jana Hunter	36029	2022-05-12	0
Alphawezen	36030	2022-05-12	0
Jan Delay	36031	2022-05-12	0
Amici Forever	36032	2022-05-12	0
solo andata	36033	2022-05-12	0
Dragonwyck	36034	2022-05-12	0
Borodin Quartet	36035	2022-05-12	0
Novaspace	36036	2022-05-12	0
The Fight Between Frames	36037	2022-05-12	0
Bruce Springsteen & The E Street Band	36038	2022-05-12	0
SPICE 1	36039	2022-05-12	0
Ercola feat. Daniella	36040	2022-05-12	0
10_000 Maniacs	36041	2022-05-12	0
Gescom	36042	2022-05-12	0
Gemma Hayes	36043	2022-05-12	0
Devendra Banhart	36044	2022-05-12	0
Steps Ahead	36045	2022-05-12	0
Brasco_ Loko	36046	2022-05-12	0
Arma Blanca	36047	2022-05-12	0
Dragonforce	36048	2022-05-12	0
Even Tuell	36049	2022-05-12	0
Julee Cruise	36050	2022-05-12	0
Firetop Mountain	36051	2022-05-12	0
Hidden Logic pres. Luminary	36052	2022-05-12	0
Charlie Dore	36053	2022-05-12	0
Differnet	36054	2022-05-12	0
Sturm und Drang	36055	2022-05-12	0
E.T.A	36056	2022-05-12	0
Corona	36057	2022-05-12	0
Everything But The Girl	36058	2022-05-12	0
Grandmaster Flash & The Furious Five	36059	2022-05-12	0
Roger Waters	36060	2022-05-12	0
Graham Bonnet	36061	2022-05-12	0
The Spook	36062	2022-05-12	0
BigElf	36063	2022-05-12	0
Demise Of Eros	36064	2022-05-12	0
Hank Williams / The Drifting Cowboys	36065	2022-05-12	0
Terry Grant Feat. Katherine Hines	36066	2022-05-12	0
Busta Rhymes	36067	2022-05-12	0
Gordon Gano / Gordon Gano / Guy Hoffman / Pierre Henry / Brian Ritchie / Brian Ritchie	36068	2022-05-12	0
China Drum	36069	2022-05-12	0
DJ Benjamin Zane	36070	2022-05-12	0
Dave Attell	36071	2022-05-12	0
Lanae' Hale	36072	2022-05-12	0
Fragile State	36073	2022-05-12	0
Jade Leary	36074	2022-05-12	0
Martin Denny	36075	2022-05-12	0
Hand To Hand	36076	2022-05-12	0
Dub Trio	36077	2022-05-12	0
Plan K	36078	2022-05-12	0
Jerry Goldsmith	36079	2022-05-12	0
PANTyRAiD	36080	2022-05-12	0
P. J. Proby	36081	2022-05-12	0
Astream	36082	2022-05-12	0
Alexis HK	36083	2022-05-12	0
Finch	36084	2022-05-12	0
Connie Stevens	36085	2022-05-12	0
Voyager Series	36086	2022-05-12	0
FC Kahuna	36087	2022-05-12	0
The Apples In Stereo	36088	2022-05-12	0
N.W.A.	36089	2022-05-12	0
Tito Puente Jr.	36090	2022-05-12	0
Bertine Zetlitz/Ken Ring	36091	2022-05-12	0
Friday	36092	2022-05-12	0
The Jeremy Spencer Band	36093	2022-05-12	0
Peter Sommer	36094	2022-05-12	0
Marika	36095	2022-05-12	0
Patrick Rondat	36096	2022-05-12	0
Jerry Butler	36097	2022-05-12	0
Kingmaker	36098	2022-05-12	0
Gruntruck	36099	2022-05-12	0
Billy Childish and Sexton Ming	36100	2022-05-12	0
Juanita Bynum	36101	2022-05-12	0
The Levellers	36102	2022-05-12	0
The Techniques	36103	2022-05-12	0
Kid Spatula	36104	2022-05-12	0
Krosfyah Feat. Tony Bailey	36105	2022-05-12	0
El Chombo	36106	2022-05-12	0
Radio Free America	36107	2022-05-12	0
Kip Addotta	36108	2022-05-12	0
Arctic Monkeys	36109	2022-05-12	0
John Frizzell	36110	2022-05-12	0
Kool G Rap / Capone-N-Noreaga	36111	2022-05-12	0
Memphis Bleek	36112	2022-05-12	0
Zappacosta	36113	2022-05-12	0
Two Hoots And A Holler	36114	2022-05-12	0
Damita	36115	2022-05-12	0
Thumb	36116	2022-05-12	0
Mirco de Govia	36117	2022-05-12	0
Habakuk	36118	2022-05-12	0
Dominic Kirwan	36119	2022-05-12	0
Dead Man In Reno	36120	2022-05-12	0
Richie Furay	36121	2022-05-12	0
The Rhythmic State	36122	2022-05-12	0
Surkin	36123	2022-05-12	0
Smooth Generation	36124	2022-05-12	0
The Disco Brothers	36125	2022-05-12	0
Radka Toneff & Steve Dobrogosz	36126	2022-05-12	0
Pokolgép	36127	2022-05-12	0
Joshua Rifkin	36128	2022-05-12	0
Maynard Ferguson	36129	2022-05-12	0
Mani Spinx	36130	2022-05-12	0
Yesterdays Rising	36131	2022-05-12	0
Rabia Sorda	36132	2022-05-12	0
Gentleman Reg	36133	2022-05-12	0
Santa Sabina	36134	2022-05-12	0
Ray Okpara & The Autist	36135	2022-05-12	0
LU	36136	2022-05-12	0
The Builders and the Butchers	36137	2022-05-12	0
Harry J Allstars	36138	2022-05-12	0
A Static Lullaby	36139	2022-05-12	0
Spirit of the West	36140	2022-05-12	0
Teresa De Sio	36141	2022-05-12	0
JAY	36142	2022-05-12	0
Clifford T. Ward	36143	2022-05-12	0
Rotting Christ	36144	2022-05-12	0
Becoming The Archetype	36145	2022-05-12	0
Flink	36146	2022-05-12	0
Bohannon	36147	2022-05-12	0
Mothboy	36148	2022-05-12	0
Totalt Jävla Mörker	36149	2022-05-12	0
Terri Clark	36150	2022-05-12	0
Impaled	36151	2022-05-12	0
JUNIOR M.A.F.I.A. ft. Notorious B.I.G.	36152	2022-05-12	0
Manuel Donayre	36153	2022-05-12	0
IQ	36154	2022-05-12	0
Sam Sparro	36155	2022-05-12	0
Picco	36156	2022-05-12	0
Bernard Harris	36157	2022-05-12	0
Sonora Santanera	36158	2022-05-12	0
Pegz	36159	2022-05-12	0
Verbal Abuse	36160	2022-05-12	0
Nick Terranova & Austin Leeds	36161	2022-05-12	0
Rodney Hunter feat. Jay Sebag	36162	2022-05-12	0
Lone Star Ridaz	36163	2022-05-12	0
Les McCann	36164	2022-05-12	0
Driver Side Impact	36165	2022-05-12	0
Dr. Felix	36166	2022-05-12	0
Una Mae Carlisle	36167	2022-05-12	0
Southern Pacific	36168	2022-05-12	0
Hi-Posi	36169	2022-05-12	0
Chris Knight	36170	2022-05-12	0
Claire Martin	36171	2022-05-12	0
Alan Parsons (Feat. Shpongle)	36172	2022-05-12	0
Joe Lee Wilson	36173	2022-05-12	0
José Alfredo Jimenez Con Mariachi Vargas De Tecalitlan	36174	2022-05-12	0
Stimming	36175	2022-05-12	0
Quiet Life	36176	2022-05-12	0
Spongebob Squarepants	36177	2022-05-12	0
Jimmy Barnes	36178	2022-05-12	0
Crazy Penis	36179	2022-05-12	0
Buddy Ace	36180	2022-05-12	0
Duels	36181	2022-05-12	0
Midfield General	36182	2022-05-12	0
Lullatone	36183	2022-05-12	0
Jaydee	36184	2022-05-12	0
DJ Roland Kenzo	36185	2022-05-12	0
Hell Blues Choir	36186	2022-05-12	0
Ann Wilson / Wynonna	36187	2022-05-12	0
Earth_ Wind & Fire	36188	2022-05-12	0
Al Anderson	36189	2022-05-12	0
Gregg Allman	36190	2022-05-12	0
Our Brother The Native	36191	2022-05-12	0
Bow Wow Wow	36192	2022-05-12	0
Guillemots	36193	2022-05-12	0
X-Act	36194	2022-05-12	0
Lagartija Nick	36195	2022-05-12	0
Hot Banditoz	36196	2022-05-12	0
Evil Nine / Aesop Rock	36197	2022-05-12	0
David Houston	36198	2022-05-12	0
John Abercrombie & John Scofield	36199	2022-05-12	0
Metallic Falcons	36200	2022-05-12	0
Latin Playboys	36201	2022-05-12	0
Mr V feat. Miss Patty	36202	2022-05-12	0
D Black	36203	2022-05-12	0
The Pit That Became A Tower	36204	2022-05-12	0
Jessica Molaskey	36205	2022-05-12	0
Malente	36206	2022-05-12	0
Yuridia	36207	2022-05-12	0
Mott The Hoople	36208	2022-05-12	0
One Night Only	36209	2022-05-12	0
Mike Farris	36210	2022-05-12	0
Eddie Grant	36211	2022-05-12	0
Popular Workshop	36212	2022-05-12	0
DEATH ANGEL	36213	2022-05-12	0
Superchick	36214	2022-05-12	0
Mark Medlock	36215	2022-05-12	0
Wire Daisies	36216	2022-05-12	0
Zingale	36217	2022-05-12	0
Egberto Gismonti	36218	2022-05-12	0
Supafly Inc	36219	2022-05-12	0
Miou Miou	36220	2022-05-12	0
Faith Evans	36221	2022-05-12	0
Attitude Adjustment	36222	2022-05-12	0
The Rattles	36223	2022-05-12	0
Peter Baumann	36224	2022-05-12	0
Los Pumas Del Norte	36225	2022-05-12	0
Caedmon's Call	36226	2022-05-12	0
Cage The Elephant	36227	2022-05-12	0
Stan Ridgway	36228	2022-05-12	0
Tanita Tikaram	36229	2022-05-12	0
Mind.In.A.Box	36230	2022-05-12	0
Ghost of the Russian Empire	36231	2022-05-12	0
Electro Mode All Stars	36232	2022-05-12	0
Stevie B	36233	2022-05-12	0
Elza Soares	36234	2022-05-12	0
The Endellion String Quartet	36235	2022-05-12	0
Brendan Benson	36236	2022-05-12	0
Cradle Of Filth	36237	2022-05-12	0
Soulfly	36238	2022-05-12	0
Gitogito Hustler	36239	2022-05-12	0
The Drawing Room	36240	2022-05-12	0
Grupo Fundo De Quintal	36241	2022-05-12	0
Artful Dodger Feat Craig David	36242	2022-05-12	0
Noelia	36243	2022-05-12	0
Laurant Wolf Feat. Soni Dee	36244	2022-05-12	0
Mayor	36245	2022-05-12	0
Sundial Aeon	36246	2022-05-12	0
Mike Birbiglia	36247	2022-05-12	0
Hanno Muller-Brachmann	36248	2022-05-12	0
Eric Church	36249	2022-05-12	0
Maryla Rodowicz	36250	2022-05-12	0
Byron Cage	36251	2022-05-12	0
Gaby	36252	2022-05-12	0
Mystic Mood Orchestra	36253	2022-05-12	0
Dan Hicks	36254	2022-05-12	0
Doctor Nerve	36255	2022-05-12	0
Gene Ammons / Earl Coleman	36256	2022-05-12	0
Inner Circle & The Fatman Riddim Section	36257	2022-05-12	0
Esquivel & His Orchestra	36258	2022-05-12	0
Calvertron & Tallaght	36259	2022-05-12	0
Sunfreakz featuring Andrea Britton	36260	2022-05-12	0
I.M.P.	36261	2022-05-12	0
Orchestra Baobab	36262	2022-05-12	0
Michael Sembello	36263	2022-05-12	0
Artur Rubinstein	36264	2022-05-12	0
Under Construction	36265	2022-05-12	0
The Grateful Dead	36266	2022-05-12	0
Deathchain	36267	2022-05-12	0
We Are Standard	36268	2022-05-12	0
The Mentally Ill	36269	2022-05-12	0
Keola Beamer	36270	2022-05-12	0
Termanology	36271	2022-05-12	0
Sumeet	36272	2022-05-12	0
Vivian	36273	2022-05-12	0
Glamour To Kill	36274	2022-05-12	0
Vypsana Fixa	36275	2022-05-12	0
Final	36276	2022-05-12	0
Robin Guthrie	36277	2022-05-12	0
Maggie Reilly	36278	2022-05-12	0
Meanest Man Contest	36279	2022-05-12	0
Lefside & Esco	36280	2022-05-12	0
Dritte Wahl	36281	2022-05-12	0
Pinstripes	36282	2022-05-12	0
Lost Stories	36283	2022-05-12	0
Human Nature	36284	2022-05-12	0
Kuldip Manak	36285	2022-05-12	0
Master Joe	36286	2022-05-12	0
Mortal Treason	36287	2022-05-12	0
Avanar	36288	2022-05-12	0
Collective Soul	36289	2022-05-12	0
Funkdoobiest	36290	2022-05-12	0
Technikal	36291	2022-05-12	0
Darren Hayman	36292	2022-05-12	0
Slimy Nuggetz	36293	2022-05-12	0
Philip Chapman	36294	2022-05-12	0
Will Hoge	36295	2022-05-12	0
James Brown And His Famous Flames	36296	2022-05-12	0
We Are Wolves	36297	2022-05-12	0
Roots Radics Band	36298	2022-05-12	0
Fiona	36299	2022-05-12	0
Georges Brassens	36300	2022-05-12	0
Common / Bilal	36301	2022-05-12	0
Aquasky / Big Kwam / Scratch Perverts	36302	2022-05-12	0
Garden Variety	36303	2022-05-12	0
Revolution Smile	36304	2022-05-12	0
Marsha Raven	36305	2022-05-12	0
The Last Act	36306	2022-05-12	0
Volumia!	36307	2022-05-12	0
Los Pasteles Verdes	36308	2022-05-12	0
Lukid	36309	2022-05-12	0
Damu The Fudgemunk	36310	2022-05-12	0
Barbara Randolph	36311	2022-05-12	0
Vanessa Williams	36312	2022-05-12	0
Kane	36313	2022-05-12	0
Bebo Norman	36314	2022-05-12	0
The Rum Diary	36315	2022-05-12	0
Disco Drive	36316	2022-05-12	0
Stephen Duffy Featuring Nigel Kennedy	36317	2022-05-12	0
Bikini Machine	36318	2022-05-12	0
Future Beat Alliance	36319	2022-05-12	0
Micronauts	36320	2022-05-12	0
Blue Magic	36321	2022-05-12	0
Estrella Morente	36322	2022-05-12	0
In Blood We Trust	36323	2022-05-12	0
Mouth Of The Architect	36324	2022-05-12	0
Richard Clapton	36325	2022-05-12	0
Sean Watkins	36326	2022-05-12	0
Carlos Y Jose	36327	2022-05-12	0
Kenny Chesney	36328	2022-05-12	0
John Cooper Clarke	36329	2022-05-12	0
Fugu	36330	2022-05-12	0
Wa Wa Nee	36331	2022-05-12	0
DJ DLG	36332	2022-05-12	0
Headmix	36333	2022-05-12	0
Greg Adams	36334	2022-05-12	0
Tino Casal	36335	2022-05-12	0
Paley Brothers	36336	2022-05-12	0
Darden Smith	36337	2022-05-12	0
Goober Patrol	36338	2022-05-12	0
Adam F	36339	2022-05-12	0
Jay Selway	36340	2022-05-12	0
Corvos	36341	2022-05-12	0
Allan Edwall	36342	2022-05-12	0
Reload & E621	36343	2022-05-12	0
French Kicks	36344	2022-05-12	0
Kino Oko	36345	2022-05-12	0
Whole Sky Monitor	36346	2022-05-12	0
The Shakin' Apostles	36347	2022-05-12	0
The Housemartins	36348	2022-05-12	0
DJ Clue / Jay-Z / Ja Rule	36349	2022-05-12	0
Julio Iglesias duet with Frank Sinatra	36350	2022-05-12	0
Malú	36351	2022-05-12	0
On Trial	36352	2022-05-12	0
Vern Gosdin	36353	2022-05-12	0
Dead To Me	36354	2022-05-12	0
Deepak Dhillon	36355	2022-05-12	0
Karen Clark Sheard	36356	2022-05-12	0
Turbonegro	36357	2022-05-12	0
xLooking Forwardx	36358	2022-05-12	0
Kiuas	36359	2022-05-12	0
Technikal featuring Andy Farley	36360	2022-05-12	0
Signs	36361	2022-05-12	0
Lost Dogs	36362	2022-05-12	0
Ray Peterson	36363	2022-05-12	0
Speech	36364	2022-05-12	0
Walker Brothers	36365	2022-05-12	0
Neck	36366	2022-05-12	0
Foot Village	36367	2022-05-12	0
Ray J / Brandy	36368	2022-05-12	0
Kim Waters	36369	2022-05-12	0
Hollowblue	36370	2022-05-12	0
Natalie Cole	36371	2022-05-12	0
Neaera	36372	2022-05-12	0
Nether	36373	2022-05-12	0
Edda Schnittgard	36374	2022-05-12	0
Henry Gross	36375	2022-05-12	0
Infamous Mobb	36376	2022-05-12	0
Ahead to the sea	36377	2022-05-12	0
Goldfrapp	36378	2022-05-12	0
Brian Borcherdt	36379	2022-05-12	0
Caroline Henderson	36380	2022-05-12	0
Out Now!	36381	2022-05-12	0
Envy	36382	2022-05-12	0
Half Japanese	36383	2022-05-12	0
Blasphemy	36384	2022-05-12	0
King Geedorah	36385	2022-05-12	0
Kish Mauve	36386	2022-05-12	0
Mac Tyer	36387	2022-05-12	0
Spezializtz feat. Samy Deluxe	36388	2022-05-12	0
Jeff Wahl	36389	2022-05-12	0
Mesa (Portuguese Group)	36390	2022-05-12	0
Patti LuPone / Mandy Patinkin / Various Artists	36391	2022-05-12	0
Zenith & Velha Guarda da Mangueira	36392	2022-05-12	0
Raimundo Amador	36393	2022-05-12	0
Quincy Jones / James Moody / Brian McKnight / Take 6 / Rachelle Ferrell	36394	2022-05-12	0
Carmen Miranda	36395	2022-05-12	0
Heldon	36396	2022-05-12	0
Murs	36397	2022-05-12	0
Simon Bonney	36398	2022-05-12	0
ADJD	36399	2022-05-12	0
Railer	36400	2022-05-12	0
Trance Control	36401	2022-05-12	0
Edgar Winter	36402	2022-05-12	0
Adrian Legg	36403	2022-05-12	0
Lewis Taylor	36404	2022-05-12	0
Regenerator	36405	2022-05-12	0
Sum 41	36406	2022-05-12	0
José Alfredo Jimenez;Acompañamiento Del Mariachi Vargas De Tecalitlan	36407	2022-05-12	0
Kaolin	36408	2022-05-12	0
Dietrich Schoenemann	36409	2022-05-12	0
Chimp Beams	36410	2022-05-12	0
Watchmen	36411	2022-05-12	0
Lone Star	36412	2022-05-12	0
Saafi Brothers	36413	2022-05-12	0
Padraig O'Keefe	36414	2022-05-12	0
Lana Lane	36415	2022-05-12	0
Burton Cummings	36416	2022-05-12	0
Endymion / Quentin Poole_ conductor	36417	2022-05-12	0
John Farnham	36418	2022-05-12	0
The Cinematic Orchestra/London Metropolitan Orchestra	36419	2022-05-12	0
Saman	36420	2022-05-12	0
Jade Ell	36421	2022-05-12	0
New Zealand Symphony Orchestra	36422	2022-05-12	0
Mama Blues Project	36423	2022-05-12	0
Tim Finn	36424	2022-05-12	0
Scott H. Biram	36425	2022-05-12	0
Cordalis	36426	2022-05-12	0
John Smith	36427	2022-05-12	0
The Sisterhood of Convoluted Thinkers	36428	2022-05-12	0
Brent Lamb	36429	2022-05-12	0
Patrick Doyle	36430	2022-05-12	0
Gilby Clarke	36431	2022-05-12	0
Cheb Mami - Diam's	36432	2022-05-12	0
Muck and the Mires	36433	2022-05-12	0
Brazilian Girls / MSTRKRFT	36434	2022-05-12	0
General Levy & Ras Sherby & Patriot	36435	2022-05-12	0
Jneiro Jarel	36436	2022-05-12	0
NEEDTOBREATHE	36437	2022-05-12	0
The Wilkinsons	36438	2022-05-12	0
Tyrone Davis	36439	2022-05-12	0
Havalina Rail Company	36440	2022-05-12	0
Sweet	36441	2022-05-12	0
José Carreras	36442	2022-05-12	0
Brownsville Station	36443	2022-05-12	0
The Fugees	36444	2022-05-12	0
Loose Change	36445	2022-05-12	0
Mellow Mark feat. Criminal	36446	2022-05-12	0
LFO	36447	2022-05-12	0
Lavender Diamond	36448	2022-05-12	0
Bruce Katz  Band	36449	2022-05-12	0
Future Of The Left	36450	2022-05-12	0
The Grapes Of Wrath	36451	2022-05-12	0
Mick Karn	36452	2022-05-12	0
Sam Bush	36453	2022-05-12	0
Los Amantes De Lola	36454	2022-05-12	0
Flip & Fill	36455	2022-05-12	0
Lil' Zane	36456	2022-05-12	0
The Browns	36457	2022-05-12	0
Meat Loaf	36458	2022-05-12	0
Carolina Chocolate Drops	36459	2022-05-12	0
Ricky Van Shelton	36460	2022-05-12	0
Johnny Carver	36461	2022-05-12	0
Pepper	36462	2022-05-12	0
Brightblack Morning Light	36463	2022-05-12	0
Ritchie Blackmore	36464	2022-05-12	0
The Chantells	36465	2022-05-12	0
Little Arthur Duncan	36466	2022-05-12	0
A.R. Kane	36467	2022-05-12	0
Banda Pachuco	36468	2022-05-12	0
Hacienda feat. Caitlin Devlin - ELK	36469	2022-05-12	0
SSS	36470	2022-05-12	0
Rubén Blades	36471	2022-05-12	0
Bros	36472	2022-05-12	0
Mira	36473	2022-05-12	0
Moxy Fruvous	36474	2022-05-12	0
Lady G	36475	2022-05-12	0
The Ones	36476	2022-05-12	0
Ten Wheel Drive/ Genya Ravan	36477	2022-05-12	0
Wreckshop Records	36478	2022-05-12	0
Dominique Paris	36479	2022-05-12	0
Beenie Man (feat. Da Bush Babees)	36480	2022-05-12	0
Aaron Shust	36481	2022-05-12	0
Lonesome River Band	36482	2022-05-12	0
K1	36483	2022-05-12	0
Accessory	36484	2022-05-12	0
APOSTLE	36485	2022-05-12	0
Marshall_ Susan	36486	2022-05-12	0
David Banner / Jim Jones	36487	2022-05-12	0
Gatemouth Brown	36488	2022-05-12	0
The Casualties	36489	2022-05-12	0
John LaPorta	36490	2022-05-12	0
Múm	36491	2022-05-12	0
Kwest Tha Madd Lad	36492	2022-05-12	0
Larry Donn	36493	2022-05-12	0
DJ Sneak	36494	2022-05-12	0
Mono & Nikitaman	36495	2022-05-12	0
Timothy B. Schmit	36496	2022-05-12	0
Hockey Night	36497	2022-05-12	0
The Lotus Eaters	36498	2022-05-12	0
Antonio Vega	36499	2022-05-12	0
Lack Of Limits	36500	2022-05-12	0
Odd Logic	36501	2022-05-12	0
800 Octane	36502	2022-05-12	0
Aidons La Norvege	36503	2022-05-12	0
Cosmic Baby	36504	2022-05-12	0
George Thorogood	36505	2022-05-12	0
Return To Forever	36506	2022-05-12	0
Fight Like Apes	36507	2022-05-12	0
Galaxie 500	36508	2022-05-12	0
Tiller's Folly	36509	2022-05-12	0
Melissa Larkin	36510	2022-05-12	0
La Fouine	36511	2022-05-12	0
My Life Story	36512	2022-05-12	0
Lucho Gatica	36513	2022-05-12	0
Inishkea	36514	2022-05-12	0
Kim Wilde	36515	2022-05-12	0
RKL	36516	2022-05-12	0
Vaselines	36517	2022-05-12	0
Number 9	36518	2022-05-12	0
The Pretty Things	36519	2022-05-12	0
Matt Belsante	36520	2022-05-12	0
Liquid Soul	36521	2022-05-12	0
MARTIN TAYLOR	36522	2022-05-12	0
The Memphis Jug Band	36523	2022-05-12	0
Higher Ground	36524	2022-05-12	0
Kante	36525	2022-05-12	0
Al-D	36526	2022-05-12	0
Sammi Cheng	36527	2022-05-12	0
Backyard Tire Fire	36528	2022-05-12	0
Thee Hypnotics	36529	2022-05-12	0
Quilapayun	36530	2022-05-12	0
Dissident	36531	2022-05-12	0
Barry White	36532	2022-05-12	0
Fair Warning	36533	2022-05-12	0
Conjunto Clasico	36534	2022-05-12	0
VAST	36535	2022-05-12	0
Blamstrain	36536	2022-05-12	0
Scan X	36537	2022-05-12	0
Pierre Aderne	36538	2022-05-12	0
Dash Rip Rock	36539	2022-05-12	0
Etta Jones	36540	2022-05-12	0
Brand New Heavies_ The	36541	2022-05-12	0
Agoraphobic Nosebleed	36542	2022-05-12	0
Quadrant	36543	2022-05-12	0
Forza	36544	2022-05-12	0
Black Science Orchestra	36545	2022-05-12	0
Sonny Boy Williamson	36546	2022-05-12	0
Erma Franklin	36547	2022-05-12	0
The Russell Family	36548	2022-05-12	0
No Age	36549	2022-05-12	0
Butterfly Temple	36550	2022-05-12	0
Linda Eder	36551	2022-05-12	0
Hope Of The States	36552	2022-05-12	0
3rd Moon	36553	2022-05-12	0
Johnny Paycheck	36554	2022-05-12	0
Johnathan Rice	36555	2022-05-12	0
Sean Slaughter	36556	2022-05-12	0
Sylvia Telles	36557	2022-05-12	0
Clint Black	36558	2022-05-12	0
Jessy Bulbo	36559	2022-05-12	0
Catch 22	36560	2022-05-12	0
Masta Killa	36561	2022-05-12	0
Version	36562	2022-05-12	0
Samson	36563	2022-05-12	0
The Ballistic Brothers	36564	2022-05-12	0
Ibio	36565	2022-05-12	0
Something About Vampires And Sluts	36566	2022-05-12	0
Beulah	36567	2022-05-12	0
Lambda	36568	2022-05-12	0
Grizzly Bear	36569	2022-05-12	0
Sissy Spacek	36570	2022-05-12	0
Utah Jazz	36571	2022-05-12	0
Alec Empire	36572	2022-05-12	0
Elefant	36573	2022-05-12	0
Suicidal Angels	36574	2022-05-12	0
XRS Land	36575	2022-05-12	0
Thrushes	36576	2022-05-12	0
TALAMASCA	36577	2022-05-12	0
Nellie Lutcher	36578	2022-05-12	0
Estonian Philharmonic Chamber Choir	36579	2022-05-12	0
Los Muecas	36580	2022-05-12	0
Daara J / China	36581	2022-05-12	0
The Melodians	36582	2022-05-12	0
Luar Na Lubre	36583	2022-05-12	0
Controlled Dissonance	36584	2022-05-12	0
LaVerne Baker	36585	2022-05-12	0
A Perfect Friend	36586	2022-05-12	0
Lylas	36587	2022-05-12	0
Christian Falk feat. Robyn	36588	2022-05-12	0
Vinicio Capossela	36589	2022-05-12	0
Dorothy Squires	36590	2022-05-12	0
Frenk Dj_ Marco Magrini	36591	2022-05-12	0
Cheikha Rimitti	36592	2022-05-12	0
Riccardo Sabatini	36593	2022-05-12	0
Brian Dullaghan	36594	2022-05-12	0
Ernie Fields	36595	2022-05-12	0
Delly Ranx	36596	2022-05-12	0
Prins Thomas	36597	2022-05-12	0
Louis Jordan and his Tympany Five	36598	2022-05-12	0
Sergio Cammariere	36599	2022-05-12	0
Niño de Alicante	36600	2022-05-12	0
Ircle	36601	2022-05-12	0
Edgar Allen Floe	36602	2022-05-12	0
Steve Fister	36603	2022-05-12	0
MIA	36604	2022-05-12	0
Lil Johnson	36605	2022-05-12	0
Andreas Dorau	36606	2022-05-12	0
Finley	36607	2022-05-12	0
Mick Flannery	36608	2022-05-12	0
Inderjit Nikku	36609	2022-05-12	0
Boney M.	36610	2022-05-12	0
Zion / Eddie Dee	36611	2022-05-12	0
Snapper feat. Chenice	36612	2022-05-12	0
Crvena Jabuka	36613	2022-05-12	0
Kidz Bop Kids	36614	2022-05-12	0
The Even Dozen Jug Band	36615	2022-05-12	0
Joe Sample / Randy Crawford	36616	2022-05-12	0
Hex	36617	2022-05-12	0
Wynton Kelly	36618	2022-05-12	0
Daan Junior	36619	2022-05-12	0
Anais Mitchell [feat. The Haden Triplets]	36620	2022-05-12	0
Edenbridge	36621	2022-05-12	0
Godsmack	36622	2022-05-12	0
Sylford Walker	36623	2022-05-12	0
Paralisis Permanente	36624	2022-05-12	0
Raul Malo	36625	2022-05-12	0
Radio 4	36626	2022-05-12	0
Diane Schuur / Maynard Ferguson	36627	2022-05-12	0
Arion	36628	2022-05-12	0
Prefuse 73 feat. Mikah 9	36629	2022-05-12	0
Kevin Toney	36630	2022-05-12	0
Cale Parks	36631	2022-05-12	0
Juana Rodriguez	36632	2022-05-12	0
Cyril Neville	36633	2022-05-12	0
Frank McComb	36634	2022-05-12	0
Morgan Page	36635	2022-05-12	0
Corenell	36636	2022-05-12	0
Detroit Grand Pubahs	36637	2022-05-12	0
The Continentals	36638	2022-05-12	0
Vieux Farka Touré	36639	2022-05-12	0
Paco De Lucia	36640	2022-05-12	0
The Business	36641	2022-05-12	0
DJ Harry	36642	2022-05-12	0
Lucky Millinder	36643	2022-05-12	0
Family Force 5	36644	2022-05-12	0
The Lies	36645	2022-05-12	0
DJ Rush	36646	2022-05-12	0
Steeple Chaser	36647	2022-05-12	0
Ut	36648	2022-05-12	0
Trespassers William	36649	2022-05-12	0
Jimmy Reed	36650	2022-05-12	0
DMX Krew	36651	2022-05-12	0
Slaughter	36652	2022-05-12	0
GWAR	36653	2022-05-12	0
Rivera Rotation	36654	2022-05-12	0
Hank Garland	36655	2022-05-12	0
Emilio Navaira	36656	2022-05-12	0
Bart Peeters	36657	2022-05-12	0
Marc Collin featuring Valente Bertelli & Katrine Ottosen	36658	2022-05-12	0
Fight	36659	2022-05-12	0
Liechtenstein	36660	2022-05-12	0
Zongamin	36661	2022-05-12	0
Prefab Sprout	36662	2022-05-12	0
Chris Whitley	36663	2022-05-12	0
The Spotnicks	36664	2022-05-12	0
Leif Ove Andsnes/City of Birmingham Symphony Orchestra/Sir Simon Rattle	36665	2022-05-12	0
Marcel Kanche	36666	2022-05-12	0
Thingy	36667	2022-05-12	0
Spagna	36668	2022-05-12	0
Max Roach	36669	2022-05-12	0
Onslaught	36670	2022-05-12	0
Blue Orchids	36671	2022-05-12	0
Natural Black	36672	2022-05-12	0
Chicos de Barrio	36673	2022-05-12	0
Jim Breuer	36674	2022-05-12	0
Grinderman	36675	2022-05-12	0
Mia X	36676	2022-05-12	0
Seguridad Social	36677	2022-05-12	0
Shiny Toy Guns	36678	2022-05-12	0
Jacob Fred Jazz Odyssey	36679	2022-05-12	0
Isobel Campbell / Mark Lanegan	36680	2022-05-12	0
Joe Dolan	36681	2022-05-12	0
Lillian Axe	36682	2022-05-12	0
Dorothy Love Coates / The Original Gospel Harmonettes	36683	2022-05-12	0
Hal Singer	36684	2022-05-12	0
Marcie Blane	36685	2022-05-12	0
Moses Pelham	36686	2022-05-12	0
The Redneck Manifesto	36687	2022-05-12	0
Airliner	36688	2022-05-12	0
Oh No	36689	2022-05-12	0
Jono El Grande	36690	2022-05-12	0
Hi-Fi Companions	36691	2022-05-12	0
Eddie Bo	36692	2022-05-12	0
Ashley Hutchings_ Ernesto De Pascale	36693	2022-05-12	0
Gertrudis	36694	2022-05-12	0
Waldo's People	36695	2022-05-12	0
Mannheim Steamroller_ Mason Williams	36696	2022-05-12	0
Eric Johnson	36697	2022-05-12	0
Puhdys	36698	2022-05-12	0
Astrud Gilberto / Walter Wanderley Trio	36699	2022-05-12	0
Thunderclap Newman	36700	2022-05-12	0
Village People	36701	2022-05-12	0
Tord Gustavsen_ Harald Johnsen_ Jarle Vespestad	36702	2022-05-12	0
THE FATBACK BAND	36703	2022-05-12	0
Bodyrox / Luciana	36704	2022-05-12	0
[ingenting]	36705	2022-05-12	0
Desmond Dekker	36706	2022-05-12	0
Vanity Project	36707	2022-05-12	0
Korby Lenker	36708	2022-05-12	0
Akon	36709	2022-05-12	0
DJ Manian	36710	2022-05-12	0
The Lapse	36711	2022-05-12	0
Wayne Bergeron	36712	2022-05-12	0
Shirley Gunter & The Queens	36713	2022-05-12	0
Elf	36714	2022-05-12	0
Michael Whalen	36715	2022-05-12	0
TO BE	36716	2022-05-12	0
Boney James	36717	2022-05-12	0
Astral Projection (SFX)	36718	2022-05-12	0
Marco Bailey & Tom Hades	36719	2022-05-12	0
Dalmata	36720	2022-05-12	0
Amy Winehouse	36721	2022-05-12	0
Chancho En Piedra	36722	2022-05-12	0
Sylvester Weaver	36723	2022-05-12	0
Holly Cole Trio	36724	2022-05-12	0
Solar System	36725	2022-05-12	0
Male	36726	2022-05-12	0
Taj Mahal & The Hula Blues Band	36727	2022-05-12	0
La Arrolladora Banda El Limón De Rene Camacho	36728	2022-05-12	0
Virgin Prunes	36729	2022-05-12	0
Black Crowes	36730	2022-05-12	0
Rey Ruiz	36731	2022-05-12	0
Los Caminantes	36732	2022-05-12	0
Dogwood	36733	2022-05-12	0
Danilo Montero	36734	2022-05-12	0
Eleven Minutes Away	36735	2022-05-12	0
Shantel	36736	2022-05-12	0
CSS	36737	2022-05-12	0
Playa Limbo	36738	2022-05-12	0
Favretto feat. Kate	36739	2022-05-12	0
Krust & Die	36740	2022-05-12	0
Deco	36741	2022-05-12	0
Dj Gollum / Scarlet	36742	2022-05-12	0
Kelli Sae	36743	2022-05-12	0
Bride	36744	2022-05-12	0
Junk Project	36745	2022-05-12	0
Dave Douglas	36746	2022-05-12	0
The Germs	36747	2022-05-12	0
EZ Rollers	36748	2022-05-12	0
Playaz Circle / I-20	36749	2022-05-12	0
Atrox	36750	2022-05-12	0
Stella	36751	2022-05-12	0
Christopher Franke	36752	2022-05-12	0
Dee Brown	36753	2022-05-12	0
Beatundercontrol	36754	2022-05-12	0
The Last Dance	36755	2022-05-12	0
Brandon Fields	36756	2022-05-12	0
Jorn Van Deynhoven	36757	2022-05-12	0
Lee Roy Parnell	36758	2022-05-12	0
Tosca	36759	2022-05-12	0
Southside Spinners	36760	2022-05-12	0
Jimmy Clanton	36761	2022-05-12	0
JUNIUS	36762	2022-05-12	0
Andy Pratt	36763	2022-05-12	0
Washington Phillips	36764	2022-05-12	0
Proficy	36765	2022-05-12	0
Bézu	36766	2022-05-12	0
Lil Mz. 313	36767	2022-05-12	0
Dynamite Deluxe	36768	2022-05-12	0
Damian Uzabiaga	36769	2022-05-12	0
Cristina Pato	36770	2022-05-12	0
Ole Paus	36771	2022-05-12	0
Voicemail	36772	2022-05-12	0
Murderbot	36773	2022-05-12	0
Simon Harris	36774	2022-05-12	0
Matthew Halsall	36775	2022-05-12	0
Classics IV featuring Dennis Yost	36776	2022-05-12	0
Spectrum	36777	2022-05-12	0
Studio One	36778	2022-05-12	0
Mac Davis	36779	2022-05-12	0
The Vipers Skiffle Group	36780	2022-05-12	0
Ressurrection Band	36781	2022-05-12	0
Vana	36782	2022-05-12	0
Js Project	36783	2022-05-12	0
The Handful	36784	2022-05-12	0
Dick Gaughan	36785	2022-05-12	0
Jerry Kilgore	36786	2022-05-12	0
Iguana Tango	36787	2022-05-12	0
Issa Bagayogo	36788	2022-05-12	0
Tyrone Taylor	36789	2022-05-12	0
Deniz Koyu	36790	2022-05-12	0
Authority	36791	2022-05-12	0
Simian Mobile Disco	36792	2022-05-12	0
Anouar Brahem_ Francois Couturier_ Jean-Louis Matinier	36793	2022-05-12	0
The Space Brothers	36794	2022-05-12	0
Faust	36795	2022-05-12	0
Traffic	36796	2022-05-12	0
Bloomfield	36797	2022-05-12	0
Gabi	36798	2022-05-12	0
Jo Jo Gunne	36799	2022-05-12	0
George Lynch	36800	2022-05-12	0
My	36801	2022-05-12	0
Brian Coll	36802	2022-05-12	0
Night In Gales	36803	2022-05-12	0
Agent Alvin Featuring Spikey Tee	36804	2022-05-12	0
Kris de Bruyne & Band	36805	2022-05-12	0
Last Tuesday	36806	2022-05-12	0
Mount Everest Trio	36807	2022-05-12	0
Rican	36808	2022-05-12	0
Martina Sorbara	36809	2022-05-12	0
Mychael Danna & Jeff Danna	36810	2022-05-12	0
Sektosixo	36811	2022-05-12	0
Remi Nicole	36812	2022-05-12	0
Bettye Swann	36813	2022-05-12	0
Mike Rud	36814	2022-05-12	0
Martika	36815	2022-05-12	0
2Mex	36816	2022-05-12	0
Smooth Touch	36817	2022-05-12	0
Quest	36818	2022-05-12	0
Jackie Mittoo	36819	2022-05-12	0
Cocoon	36820	2022-05-12	0
Sagittarius	36821	2022-05-12	0
Larry Graham & Graham Central Station	36822	2022-05-12	0
fIREHOSE	36823	2022-05-12	0
Hardsoul	36824	2022-05-12	0
Paris Musette	36825	2022-05-12	0
Crazy Horse	36826	2022-05-12	0
Clone The Fragile	36827	2022-05-12	0
Blowing Free	36828	2022-05-12	0
Amy Pearson	36829	2022-05-12	0
Axel Coon	36830	2022-05-12	0
Voyager One	36831	2022-05-12	0
Slo Moshun	36832	2022-05-12	0
Big Time Sarah	36833	2022-05-12	0
P!nk Featuring Indigo Girls	36834	2022-05-12	0
Daryl Hall & John Oates	36835	2022-05-12	0
Dis	36836	2022-05-12	0
Eddie Cochran & Gene Vincent	36837	2022-05-12	0
Dem Franchize Boyz feat. Three 6 Mafia	36838	2022-05-12	0
From First to Last	36839	2022-05-12	0
Nick Lowe	36840	2022-05-12	0
Austrian Death Machine	36841	2022-05-12	0
Mojo Buford	36842	2022-05-12	0
The Transients	36843	2022-05-12	0
Mobb Deep featuring NOYD	36844	2022-05-12	0
Tommy And The Terrors	36845	2022-05-12	0
Os Mutantes	36846	2022-05-12	0
Die Türen	36847	2022-05-12	0
Haji & Emanuel Feat. Beverley Knight & Bryan Chambers	36848	2022-05-12	0
The Poets	36849	2022-05-12	0
The Police	36850	2022-05-12	0
Baby Rasta Band	36851	2022-05-12	0
Rebirth Brass Band_ Cheeky Blakk	36852	2022-05-12	0
The John Earl Walker Band	36853	2022-05-12	0
Coal Chamber	36854	2022-05-12	0
G Unit ft. 50 Cent & Tony Yayo	36855	2022-05-12	0
King Wilkie	36856	2022-05-12	0
Gothenburg Symphony Orchestra / Neeme Järvi	36857	2022-05-12	0
The Masked Marauders	36858	2022-05-12	0
Maze Featuring Frankie Beverly	36859	2022-05-12	0
Radiohead	36860	2022-05-12	0
Woody Guthrie & Jack Elliott	36861	2022-05-12	0
Jape	36862	2022-05-12	0
Fabolous / Jermaine Dupri	36863	2022-05-12	0
HA-ASH;Kalimba	36864	2022-05-12	0
98º	36865	2022-05-12	0
DoomSword	36866	2022-05-12	0
3T	36867	2022-05-12	0
Maria Rita	36868	2022-05-12	0
Satin Souls	36869	2022-05-12	0
Dazz Band	36870	2022-05-12	0
Crooked Stilo	36871	2022-05-12	0
Joe Maneri Quartet	36872	2022-05-12	0
Gang Green	36873	2022-05-12	0
BRIAN ENO AND J PETER SCHWALM	36874	2022-05-12	0
George Kranz	36875	2022-05-12	0
Factums	36876	2022-05-12	0
Penetration	36877	2022-05-12	0
Rev Theory	36878	2022-05-12	0
Oscar D'León	36879	2022-05-12	0
Crystal Noise	36880	2022-05-12	0
Hund am Strand	36881	2022-05-12	0
Joe Grushecky	36882	2022-05-12	0
Bell Biv DeVoe	36883	2022-05-12	0
Hit The Lights	36884	2022-05-12	0
Peter Grudzien	36885	2022-05-12	0
Cancerbats	36886	2022-05-12	0
Mafalda Veiga	36887	2022-05-12	0
Dennis Ferrer featuring Kenny Bobien	36888	2022-05-12	0
4 Strings	36889	2022-05-12	0
Audrey Gagnon	36890	2022-05-12	0
The Sea Urchins	37029	2022-05-12	0
Major Organ And The Adding Machine	36891	2022-05-12	0
Danny Tenaglia	36892	2022-05-12	0
Jean Lumière	36893	2022-05-12	0
Reigning Sound	36894	2022-05-12	0
The Orchids	36895	2022-05-12	0
Dave Fletcher	36896	2022-05-12	0
Seven Day Jesus	36897	2022-05-12	0
The Poni-Tails	36898	2022-05-12	0
Veselin Tasev	36899	2022-05-12	0
touchingGrace	36900	2022-05-12	0
An Albatross	36901	2022-05-12	0
Silent Waves	36902	2022-05-12	0
Wilson Pickett	36903	2022-05-12	0
Bunny Rugs & Upsetters	36904	2022-05-12	0
Manuel Carrasco	36905	2022-05-12	0
Youssou N'Dour	36906	2022-05-12	0
I AWAKE	36907	2022-05-12	0
Archer Prewitt	36908	2022-05-12	0
Vashti Bunyan	36909	2022-05-12	0
Santiago Niño & DJ Ronxxx	36910	2022-05-12	0
A Mei	36911	2022-05-12	0
Jerry Harrison	36912	2022-05-12	0
The Band	36913	2022-05-12	0
The Fully Down	36914	2022-05-12	0
Wizzard	36915	2022-05-12	0
Isaac Hayes	36916	2022-05-12	0
The Real Booty Babes	36917	2022-05-12	0
Nic Fanciulli	36918	2022-05-12	0
Narziss	36919	2022-05-12	0
Mercedes Sosa	36920	2022-05-12	0
The Reggae Boys	36921	2022-05-12	0
Michel Montecrossa and The Chosen Few	36922	2022-05-12	0
Regulations	36923	2022-05-12	0
Ghetto Mafia	36924	2022-05-12	0
Toshinori Kondo	36925	2022-05-12	0
Ballboy	36926	2022-05-12	0
JT The Bigga Figga	36927	2022-05-12	0
New Direction	36928	2022-05-12	0
Ornette Coleman;London Symphony Orchestra	36929	2022-05-12	0
Prole	36930	2022-05-12	0
Stephen Bishop	36931	2022-05-12	0
The Reivers	36932	2022-05-12	0
Paola & Chiara	36933	2022-05-12	0
Kaddisfly	36934	2022-05-12	0
Amorphous Androgynous	36935	2022-05-12	0
SWV	36936	2022-05-12	0
Mark-Anthony Abel	36937	2022-05-12	0
Jimmy Herring	36938	2022-05-12	0
Razors Edge	36939	2022-05-12	0
Tonya	36940	2022-05-12	0
Lasse Lindh	36941	2022-05-12	0
Markus	36942	2022-05-12	0
Roberto Perera	36943	2022-05-12	0
Christian Scott	36944	2022-05-12	0
Spokes Mashiyane	36945	2022-05-12	0
Falko Brocksieper	36946	2022-05-12	0
Lifter Puller	36947	2022-05-12	0
Betty Buckley	36948	2022-05-12	0
KAUKO  RÖYHKÄ	36949	2022-05-12	0
The Boxer Rebellion	36950	2022-05-12	0
Terry Oldfield	36951	2022-05-12	0
Dear Leader	36952	2022-05-12	0
Doubtingthomas	36953	2022-05-12	0
The Weathermen	36954	2022-05-12	0
David Sandström Overdrive	36955	2022-05-12	0
Lorna	36956	2022-05-12	0
Barley Bree	36957	2022-05-12	0
The Penguins	36958	2022-05-12	0
One Flew South	36959	2022-05-12	0
Webb Pierce	36960	2022-05-12	0
Lee Greenwood	36961	2022-05-12	0
Evan Lionel	36962	2022-05-12	0
Wilfrido Vargas	36963	2022-05-12	0
Jahmali	36964	2022-05-12	0
The Beatles Revival Band	36965	2022-05-12	0
Tommy Flanagan	36966	2022-05-12	0
Jr. Walker & The All Stars	36967	2022-05-12	0
Pets With Pets	36968	2022-05-12	0
Don Moen	36969	2022-05-12	0
English Chamber Orchestra;Donald Fraser;José Luis Garcia	36970	2022-05-12	0
Clowns und Helden	36971	2022-05-12	0
Alain Turban	36972	2022-05-12	0
Mark Knopfler / Emmylou Harris	36973	2022-05-12	0
Loren Connors	36974	2022-05-12	0
Digital DJ's_ Jealous J	36975	2022-05-12	0
Nasty Habits	36976	2022-05-12	0
Banda Eva	36977	2022-05-12	0
Joe King Carrasco	36978	2022-05-12	0
Mônica Salmaso	36979	2022-05-12	0
Paul Kalkbrenner	36980	2022-05-12	0
Hostage	36981	2022-05-12	0
Spinal Tap feat. Keith Emerson	36982	2022-05-12	0
Wolfgang Ambros	36983	2022-05-12	0
Vermeer Quartet	36984	2022-05-12	0
Edward Johnson	36985	2022-05-12	0
Rick Braun/Richard Elliot	36986	2022-05-12	0
Element 101	36987	2022-05-12	0
Elena	36988	2022-05-12	0
Substate	36989	2022-05-12	0
Tuffest	36990	2022-05-12	0
Arcadia	36991	2022-05-12	0
Eddy Mitchell	36992	2022-05-12	0
Theo Hakola	36993	2022-05-12	0
Diana Krall / Christian McBride	36994	2022-05-12	0
BBS Paranoicos	36995	2022-05-12	0
Nero	36996	2022-05-12	0
Ole van Dansk	36997	2022-05-12	0
Parrita	36998	2022-05-12	0
Sun:Port	36999	2022-05-12	0
Cog	37000	2022-05-12	0
Mini Viva	37001	2022-05-12	0
Irene Grandi	37002	2022-05-12	0
Royal Crescent Mob	37003	2022-05-12	0
Israel	37004	2022-05-12	0
The Kingsmen	37005	2022-05-12	0
Kirk Whalum	37006	2022-05-12	0
Itzhak Perlman/Samuel Sanders	37007	2022-05-12	0
Breathe	37008	2022-05-12	0
Marianne Faithfull	37009	2022-05-12	0
Roni Size / Reprazent	37010	2022-05-12	0
The Vandermark 5	37011	2022-05-12	0
George Jones	37012	2022-05-12	0
Zombina And The Skeletones	37013	2022-05-12	0
Diego Martin	37014	2022-05-12	0
Tomcats in Tokyo	37015	2022-05-12	0
Liliput	37016	2022-05-12	0
Wiley	37017	2022-05-12	0
Gene Parsons	37018	2022-05-12	0
Neville Brothers	37019	2022-05-12	0
De'lacy	37020	2022-05-12	0
Emotional	37021	2022-05-12	0
The Del-Vikings	37022	2022-05-12	0
Hayseed Dixie	37023	2022-05-12	0
La Firma	37024	2022-05-12	0
Mobb Deep featuring Big Noyd	37025	2022-05-12	0
Chimera State	37026	2022-05-12	0
Sonu Nigam	37027	2022-05-12	0
Europe	37028	2022-05-12	0
The Gruesome Twosome (DJ Morpheus+Bertrand Burgalat)	37030	2022-05-12	0
Lonnie Liston Smith	37031	2022-05-12	0
Non	37032	2022-05-12	0
Annihilator	37033	2022-05-12	0
Damian Marley	37034	2022-05-12	0
Silkworm	37035	2022-05-12	0
P.O.D.	37036	2022-05-12	0
Nicky Wire	37037	2022-05-12	0
Hexstatic feat. Juice Aleem	37038	2022-05-12	0
Pasion Vega	37039	2022-05-12	0
Those Unknown	37040	2022-05-12	0
Rhydian feat. Idina Menzel	37041	2022-05-12	0
Eisheilig	37042	2022-05-12	0
The Pure	37043	2022-05-12	0
The Byrds	37044	2022-05-12	0
Hell Razah & Shabazz are&T.H.U.G. Angelz	37045	2022-05-12	0
Los Abuelos De La Nada	37046	2022-05-12	0
Northern Lights	37047	2022-05-12	0
Molella	37048	2022-05-12	0
Jefferson Airplane	37049	2022-05-12	0
Kelly Price / Daron Jones / Quinness Parker	37050	2022-05-12	0
Los Fabulosos Cadillacs	37051	2022-05-12	0
Bad Brains	37052	2022-05-12	0
Filthy Thieving Bastards	37053	2022-05-12	0
The Peanut Butter Conspiracy	37054	2022-05-12	0
Santigold	37055	2022-05-12	0
Benny Bailey	37056	2022-05-12	0
Shane MacGowan And The Popes	37057	2022-05-12	0
Downfall 2012	37058	2022-05-12	0
Alison Krauss / Union Station	37059	2022-05-12	0
Matt Mays & El Torpedo	37060	2022-05-12	0
Write This Down	37061	2022-05-12	0
Bill Conti	37062	2022-05-12	0
Ray Anthony Orchestra - Big Band Swing	37063	2022-05-12	0
Nicholas Pike	37064	2022-05-12	0
The Briefs	37065	2022-05-12	0
Exposure	37066	2022-05-12	0
Katy Perry	37067	2022-05-12	0
Edison Lighthouse	37068	2022-05-12	0
El Chicano	37069	2022-05-12	0
Michael Scott	37070	2022-05-12	0
Pat Metheny Group	37071	2022-05-12	0
Pee Wee Crayton & His Guitar	37072	2022-05-12	0
Johan Verminnen	37073	2022-05-12	0
Amber Pacific	37074	2022-05-12	0
The Greenberry Woods	37075	2022-05-12	0
Derrick Harriott	37076	2022-05-12	0
Los Brujos	37077	2022-05-12	0
Psyche	37078	2022-05-12	0
Hubert Sumlin	37079	2022-05-12	0
Jacki O / Ghostface	37080	2022-05-12	0
The George Shearing Quintet with Nancy Wilson	37081	2022-05-12	0
Orlando Voorn	37082	2022-05-12	0
Juice	37083	2022-05-12	0
Jorge Negrete	37084	2022-05-12	0
The Republic Tigers	37085	2022-05-12	0
Pink Elephant	37086	2022-05-12	0
Flaming Stars	37087	2022-05-12	0
Beanfield	37088	2022-05-12	0
Lonnie Liston Smith;Lonnie Liston Smith and the Cosmic Echoes	37089	2022-05-12	0
Evergrey	37090	2022-05-12	0
Makem and Clancy	37091	2022-05-12	0
Ametsub	37092	2022-05-12	0
Struka	37093	2022-05-12	0
Captain & Tennille	37094	2022-05-12	0
DJ Bootsie	37095	2022-05-12	0
Circo	37096	2022-05-12	0
Havoc_ Prodeje	37097	2022-05-12	0
Synsun	37098	2022-05-12	0
Sascha Heyna	37099	2022-05-12	0
Scarlet Diva	37100	2022-05-12	0
Captain Ahab	37101	2022-05-12	0
Firewind	37102	2022-05-12	0
Daryl Stuermer	37103	2022-05-12	0
Jolly Harbour	37104	2022-05-12	0
Orphaned Land	37105	2022-05-12	0
Orgy	37106	2022-05-12	0
Foy Vance	37107	2022-05-12	0
101 Strings Orchestra	37108	2022-05-12	0
Los Paranoias	37109	2022-05-12	0
Trik Turner	37110	2022-05-12	0
Terry Dexter	37111	2022-05-12	0
Big Mojo Elem	37112	2022-05-12	0
Aria (TUTL)	37113	2022-05-12	0
Holly Brook	37114	2022-05-12	0
Third World	37115	2022-05-12	0
Maks And The Minors	37116	2022-05-12	0
Percubaba	37117	2022-05-12	0
Thousand Foot Krutch	37118	2022-05-12	0
La Red De San Luis	37119	2022-05-12	0
Marky Ramone	37120	2022-05-12	0
Anacrusis	37121	2022-05-12	0
Rodrigo Gonzalez	37122	2022-05-12	0
J Dilla	37123	2022-05-12	0
Paradise Boys	37124	2022-05-12	0
Fun 'Da' Mental	37125	2022-05-12	0
Philipi Rosa	37126	2022-05-12	0
Alan Jenkins and the Thurston Lava Tube	37127	2022-05-12	0
Ty Herndon	37128	2022-05-12	0
Soñador	37129	2022-05-12	0
Casting Crowns	37130	2022-05-12	0
The Mass	37131	2022-05-12	0
Bigga Boss	37132	2022-05-12	0
Free Diamonds	37133	2022-05-12	0
Montero	37134	2022-05-12	0
Brainbombs	37135	2022-05-12	0
Dance With A Stranger	37136	2022-05-12	0
Chloë Agnew	37137	2022-05-12	0
Gordonsolie Motherfuckers	37138	2022-05-12	0
Iman	37139	2022-05-12	0
Arpeggio	37140	2022-05-12	0
Xzibit	37141	2022-05-12	0
Kelly Marie	37142	2022-05-12	0
Diblo Dibala	37143	2022-05-12	0
TJ Cases	37144	2022-05-12	0
Brett Eidman	37145	2022-05-12	0
Poundhound	37146	2022-05-12	0
Peter Buffett	37147	2022-05-12	0
Wau Y Los Arrrghs!!	37148	2022-05-12	0
Pillar	37149	2022-05-12	0
Kangding Ray	37150	2022-05-12	0
Dubioza kolektiv	37151	2022-05-12	0
Pastor Troy & Nino	37152	2022-05-12	0
Robbie Seay Band	37153	2022-05-12	0
De De Lind	37154	2022-05-12	0
Ada Jane	37155	2022-05-12	0
Comet Gain	37156	2022-05-12	0
Kamil Polner & Michelle Richer	37157	2022-05-12	0
Di Maggio	37158	2022-05-12	0
Solar Twins	37159	2022-05-12	0
Pheeroan Aklaff	37160	2022-05-12	0
Judy Dyble	37161	2022-05-12	0
Thavius Beck	37162	2022-05-12	0
Celso Piña y su Ronda Bogotá	37163	2022-05-12	0
Dead or American	37164	2022-05-12	0
Mauracher	37165	2022-05-12	0
The Black Dog	37166	2022-05-12	0
Lo Fidelity All stars	37167	2022-05-12	0
DJ Koze vs Sid LeRock	37168	2022-05-12	0
Manolis Famellos & I Podilates	37169	2022-05-12	0
Patti LuPone;Paul Gemignani	37170	2022-05-12	0
Karrin Allyson	37171	2022-05-12	0
La Tropa F	37172	2022-05-12	0
Andy Hui	37173	2022-05-12	0
Malene Mortensen	37174	2022-05-12	0
Barre Phillips	37175	2022-05-12	0
Dominici	37176	2022-05-12	0
Foo Fighters	37177	2022-05-12	0
Santiago Nino	37178	2022-05-12	0
Shakira	37179	2022-05-12	0
Frankie J featuring Paul Wall	37180	2022-05-12	0
Jack Peñate	37181	2022-05-12	0
Glampire	37182	2022-05-12	0
Chelsea Grin	37183	2022-05-12	0
Danny Wilson	37184	2022-05-12	0
Shazam	37185	2022-05-12	0
Shout Out Louds	37186	2022-05-12	0
Mi & L'Au	37187	2022-05-12	0
Joachim Garraud	37188	2022-05-12	0
Dope Stars Inc.	37189	2022-05-12	0
Ah Cama-Sotz	37190	2022-05-12	0
Teargas & Plateglass	37191	2022-05-12	0
Faudel / Khaled	37192	2022-05-12	0
Michael Allen Harrison	37193	2022-05-12	0
Gerd Dudenhöffer	37194	2022-05-12	0
Doug Hoekstra	37195	2022-05-12	0
Aldo Nova	37196	2022-05-12	0
Eric Clapton / B.B. King	37197	2022-05-12	0
This Ending	37198	2022-05-12	0
Jimmy Jansson	37199	2022-05-12	0
Beng Beng Cocktail	37200	2022-05-12	0
Brooks O'Dell	37201	2022-05-12	0
Jamelao	37202	2022-05-12	0
Lucas Prata	37203	2022-05-12	0
Dolly Parton (with Billy Ray Cyrus_ Tanya Tucker_ Mary Chapin Carpenter_ Kathy Mattea_ Pam Tillis)	37204	2022-05-12	0
DeBarge	37205	2022-05-12	0
On The Last Day	37206	2022-05-12	0
O Quam Tristis...	37207	2022-05-12	0
The Monkeywrench	37208	2022-05-12	0
Manzanita - El Chino	37209	2022-05-12	0
Overnight Lows	37210	2022-05-12	0
Blaze Bayley	37211	2022-05-12	0
Kirk Franklin	37212	2022-05-12	0
St. Louis Jimmy Oden	37213	2022-05-12	0
Yppah	37214	2022-05-12	0
Mika Vainio	37215	2022-05-12	0
Knut Værnes	37216	2022-05-12	0
Cor veleno	37217	2022-05-12	0
Jesus Jones	37218	2022-05-12	0
Gene Vincent & His Blue Caps	37219	2022-05-12	0
Steve Goodman	37220	2022-05-12	0
Ron Trent_ Erik Rico	37221	2022-05-12	0
Groovebox	37222	2022-05-12	0
Afro-Cuban All Stars	37223	2022-05-12	0
The Elgins	37224	2022-05-12	0
Jorge Salan	37225	2022-05-12	0
La Sega Del Canto	37226	2022-05-12	0
Enzo Jannacci	37227	2022-05-12	0
Sound Field	37228	2022-05-12	0
Ella Jenkins	37229	2022-05-12	0
D' Militante	37230	2022-05-12	0
Roberto Faz	37231	2022-05-12	0
Earl Brutus	37232	2022-05-12	0
Säkert!	37233	2022-05-12	0
Billy Swan	37234	2022-05-12	0
TOMASI feat. Raquel Pacheco	37235	2022-05-12	0
She Wants Revenge	37236	2022-05-12	0
Alizée	37237	2022-05-12	0
Dieter Moebius	37238	2022-05-12	0
883	37239	2022-05-12	0
Camille	37240	2022-05-12	0
Jean Corti	37241	2022-05-12	0
Texas Tornados	37242	2022-05-12	0
Bling Dawg	37243	2022-05-12	0
H-Town	37244	2022-05-12	0
Queen Ifrica	37245	2022-05-12	0
Trina & Ballgrum	37246	2022-05-12	0
Ghoti Hook	37247	2022-05-12	0
Sam Sharp	37248	2022-05-12	0
Levellers	37249	2022-05-12	0
Mick Farren/Jack Lancaster	37250	2022-05-12	0
The Long Ryders	37251	2022-05-12	0
Till Brönner / Aimee Mann	37252	2022-05-12	0
Gemini Five	37253	2022-05-12	0
Mario Lanza	37254	2022-05-12	0
Planet Asia	37255	2022-05-12	0
UNKLE / Thom Yorke	37256	2022-05-12	0
Dave "Baby" Cortez	37257	2022-05-12	0
Udo Jürgens	37258	2022-05-12	0
Louie Culture	37259	2022-05-12	0
Zsédenyi Adrienn	37260	2022-05-12	0
Grinspoon	37261	2022-05-12	0
Fat Freddy's Drop	37262	2022-05-12	0
The Stooges	37263	2022-05-12	0
Frankie Lee Sims	37264	2022-05-12	0
Men Of Standard	37265	2022-05-12	0
Spex	37266	2022-05-12	0
Billy Bragg & Wilco Featuring Natalie Merchant	37267	2022-05-12	0
Lethalness	37268	2022-05-12	0
HOWDEN - WAKEFORD	37269	2022-05-12	0
As de Trêfle	37270	2022-05-12	0
Delon & Dalcan	37271	2022-05-12	0
Reverend Beat-Man & The Un-Believers	37272	2022-05-12	0
Dee Robert	37273	2022-05-12	0
Di-rect	37274	2022-05-12	0
Triumvirat	37275	2022-05-12	0
Lily Holbrook	37276	2022-05-12	0
Hooligans	37277	2022-05-12	0
Goldblade	37278	2022-05-12	0
Noitalinna Huraa!	37279	2022-05-12	0
Nicole C. Mullen	37280	2022-05-12	0
Bessie Smith	37281	2022-05-12	0
STEVE TAYLOR	37282	2022-05-12	0
Peter Hunningale	37283	2022-05-12	0
Kim Wilson	37284	2022-05-12	0
Z-RO	37285	2022-05-12	0
Molesta	37286	2022-05-12	0
The All Seeing I	37287	2022-05-12	0
Kris Drever	37288	2022-05-12	0
Bedhead	37289	2022-05-12	0
Blues Etílicos	37290	2022-05-12	0
Dot Allison	37291	2022-05-12	0
Tom Petty And The Heartbreakers	37292	2022-05-12	0
Synthetic Breed	37293	2022-05-12	0
Antonio Carlos Jobim / Luiz Bonfa / João Gilberto	37294	2022-05-12	0
617	37295	2022-05-12	0
Jack Endino	37296	2022-05-12	0
Metamatics	37297	2022-05-12	0
DJ Dazzle	37298	2022-05-12	0
Darkstar	37299	2022-05-12	0
Disorder	37300	2022-05-12	0
Bugs Eat Books	37301	2022-05-12	0
Healer	37302	2022-05-12	0
Bruce Springsteen	37303	2022-05-12	0
Embargo	37304	2022-05-12	0
John Gregory	37305	2022-05-12	0
Eagles Of Death Metal	37306	2022-05-12	0
Dan Fogelberg	37307	2022-05-12	0
Kenny G featuring David Benoit	37308	2022-05-12	0
Switchblade Symphony	37309	2022-05-12	0
Cherry Five	37310	2022-05-12	0
The Soup Dragons	37311	2022-05-12	0
String Driven Thing	37312	2022-05-12	0
Max Romeo	37313	2022-05-12	0
Down Low	37314	2022-05-12	0
Joel Mull	37315	2022-05-12	0
Teräsbetoni	37316	2022-05-12	0
Secret Dakota Ring	37317	2022-05-12	0
Shellshag	37318	2022-05-12	0
Joe Pace	37319	2022-05-12	0
Arkham	37320	2022-05-12	0
Sleep Feat. Zelly Rock	37321	2022-05-12	0
Big George Jackson	37322	2022-05-12	0
Jean Paul Rena and Terrawheel	37323	2022-05-12	0
Lyres	37324	2022-05-12	0
Choking Victim	37325	2022-05-12	0
Electra	37326	2022-05-12	0
Donna The Buffalo	37327	2022-05-12	0
Buc Fifty	37328	2022-05-12	0
Telephone Jim Jesus	37329	2022-05-12	0
Nikoo	37330	2022-05-12	0
White Label	37331	2022-05-12	0
October 31	37332	2022-05-12	0
Freedom For King Kong	37333	2022-05-12	0
Vladislav Delay	37334	2022-05-12	0
Dirty Rig	37335	2022-05-12	0
Ney Matogrosso	37336	2022-05-12	0
Scout Niblett	37337	2022-05-12	0
Lori Perry	37338	2022-05-12	0
Massiv in Mensch	37339	2022-05-12	0
The Johnny Shines Blues Band	37340	2022-05-12	0
Tiken Jah Fakoly	37341	2022-05-12	0
Ralf Gum	37342	2022-05-12	0
MJG	37343	2022-05-12	0
Zap Pow	37344	2022-05-12	0
Bomb	37345	2022-05-12	0
Tim 'Ripper' Owens	37346	2022-05-12	0
Jason Donovan	37347	2022-05-12	0
Azeda Booth	37348	2022-05-12	0
Trolley Route	37349	2022-05-12	0
Will.i.am feat. The Babongo Tribe	37350	2022-05-12	0
Long John Hunter	37351	2022-05-12	0
Strunz & Farah	37352	2022-05-12	0
West Indian Girl	37353	2022-05-12	0
Cal Tjader	37354	2022-05-12	0
Skeeter Davis	37355	2022-05-12	0
DK	37356	2022-05-12	0
T. Graham Brown	37357	2022-05-12	0
The Supremes / Four Tops	37358	2022-05-12	0
Orquesta America	37359	2022-05-12	0
Life In Your Way	37360	2022-05-12	0
Johnny Bond and The Red River Boys	37361	2022-05-12	0
Thermostatic	37362	2022-05-12	0
Wighnomy Brothers feat. Robag Wruhme	37363	2022-05-12	0
Café Quijano	37364	2022-05-12	0
The Everly Brothers	37365	2022-05-12	0
Marmalade	37366	2022-05-12	0
EN VOICE	37367	2022-05-12	0
Michael White with Bill Frisell	37368	2022-05-12	0
Drumattic Twins	37369	2022-05-12	0
Mason	37370	2022-05-12	0
Rev. Timothy Wright	37371	2022-05-12	0
Mortification	37372	2022-05-12	0
Punch Brothers	37373	2022-05-12	0
Andrey Kiritchenko	37374	2022-05-12	0
Antiseen	37375	2022-05-12	0
Buddy Jewell	37376	2022-05-12	0
Marthia Sides	37377	2022-05-12	0
Winifred Phillips	37378	2022-05-12	0
MC5	37379	2022-05-12	0
Sean Ensign	37380	2022-05-12	0
Mindless Self Indulgence	37381	2022-05-12	0
Swallow The Sun	37382	2022-05-12	0
S.U.P	37383	2022-05-12	0
Doof	37384	2022-05-12	0
DJ `X´elerator feat. Annakiya	37385	2022-05-12	0
Los Halcones De Salitrillo	37386	2022-05-12	0
Mahay	37387	2022-05-12	0
MC Duke	37388	2022-05-12	0
Rapoon	37389	2022-05-12	0
Madredeus	37390	2022-05-12	0
Patsy Moore	37391	2022-05-12	0
Sombre View	37392	2022-05-12	0
Josef K	37393	2022-05-12	0
Earl Van Dyke & The Soul Brothers	37394	2022-05-12	0
The Amps	37395	2022-05-12	0
Roy Rogers	37396	2022-05-12	0
Arc Angels	37397	2022-05-12	0
Mersonary Killaz	37398	2022-05-12	0
Proxy	37399	2022-05-12	0
Southside Johnny & The Asbury Jukes	37400	2022-05-12	0
Gorilla Zoe	37401	2022-05-12	0
Las Ardillitas De Lalo Guerrero	37402	2022-05-12	0
Black Eyed Peas	37403	2022-05-12	0
Madness	37404	2022-05-12	0
Our People Versus Yours	37405	2022-05-12	0
Ed Harcourt	37406	2022-05-12	0
Les Paul & Mary Ford	37407	2022-05-12	0
Conquest	37408	2022-05-12	0
David Lee Garza	37409	2022-05-12	0
Riot/Clone	37410	2022-05-12	0
Noisettes	37411	2022-05-12	0
Joel Alme	37412	2022-05-12	0
The Boxmasters feat. Billy Bob Thornton	37413	2022-05-12	0
Hell Rell_ A Mafia	37414	2022-05-12	0
David Robertson	37415	2022-05-12	0
The Futureheads	37416	2022-05-12	0
Bayside	37417	2022-05-12	0
Oliver Huntemann	37418	2022-05-12	0
Hinkel	37419	2022-05-12	0
Lou Reid & Carolina	37420	2022-05-12	0
The Underwolves	37421	2022-05-12	0
Dance Or Die	37422	2022-05-12	0
Erick Sermon feat. Keith Murray & Cadillac Tah	37423	2022-05-12	0
Nusrat Fateh Ali Khan	37424	2022-05-12	0
Loudon Wainwright III (Lucy Wainwright Roche)	37425	2022-05-12	0
Mind Da Gap	37426	2022-05-12	0
Taana Gardner	37427	2022-05-12	0
Elend	37428	2022-05-12	0
OLIVER	37429	2022-05-12	0
UM Dance Collective	37430	2022-05-12	0
Jacky Terrasson	37431	2022-05-12	0
MJ Cole featuring Laura Vane	37432	2022-05-12	0
Death is Not Glamorous	37433	2022-05-12	0
Alunni Del Sole	37434	2022-05-12	0
Sleeping At Last	37435	2022-05-12	0
Mal De Ojo	37436	2022-05-12	0
Christophe Beck	37437	2022-05-12	0
Maurice Davis	37438	2022-05-12	0
Diego Carrasco;Pepe Roca	37439	2022-05-12	0
Andrew Spencer & The Vamprockerz	37440	2022-05-12	0
Angels	37441	2022-05-12	0
Arrogance	37442	2022-05-12	0
Eldar	37443	2022-05-12	0
Emancipator	37444	2022-05-12	0
Roscoe Holcomb & The Stanley Brothers	37445	2022-05-12	0
Berezin	37446	2022-05-12	0
Cholomandinga	37447	2022-05-12	0
The Regime	37448	2022-05-12	0
Bobby Byrd / Anna King	37449	2022-05-12	0
Virolo	37450	2022-05-12	0
Drama	37451	2022-05-12	0
Verdena	37452	2022-05-12	0
Live Alien Broadcast	37453	2022-05-12	0
Elmore James Jr.	37454	2022-05-12	0
Students	37455	2022-05-12	0
A Place to Bury Strangers	37456	2022-05-12	0
Alex Gopher	37457	2022-05-12	0
Etran Finatawa	37458	2022-05-12	0
The Supersuckers	37459	2022-05-12	0
Scientists	37460	2022-05-12	0
Tantric	37461	2022-05-12	0
Gameface	37462	2022-05-12	0
Ekoostik Hookah	37463	2022-05-12	0
Lano Places	37464	2022-05-12	0
Farid Ortiz - Emilio Oviedo "El Comandante	37465	2022-05-12	0
Dougie MacLean	37466	2022-05-12	0
Ojm	37467	2022-05-12	0
Rise To Addiction	37468	2022-05-12	0
Eazy-E	37469	2022-05-12	0
Joe Perry	37470	2022-05-12	0
9mm Parabellum Bullet	37471	2022-05-12	0
Antonello Venditti	37472	2022-05-12	0
El-B	37473	2022-05-12	0
V.I.P	37474	2022-05-12	0
Charge 69	37475	2022-05-12	0
Andre Popp	37476	2022-05-12	0
Anti-Pop Consortium	37477	2022-05-12	0
Kaskade with Tamra	37478	2022-05-12	0
Oak Ridge Boys	37479	2022-05-12	0
Diana Krall	37480	2022-05-12	0
Klaas	37481	2022-05-12	0
Barbara Carlotti	37482	2022-05-12	0
Davide Squillace	37483	2022-05-12	0
Pastora	37484	2022-05-12	0
Kingston Wall	37485	2022-05-12	0
Uusitalo	37486	2022-05-12	0
Jack Irons	37487	2022-05-12	0
Super Rail Band de Bamako	37488	2022-05-12	0
D:Fuse & Hiratzka (feat. Ceci Castelblanco)	37489	2022-05-12	0
Richie Rich featuring B-Legit_ Erk The Jerk	37490	2022-05-12	0
Lonnie Johnson	37491	2022-05-12	0
Tri State Corner	37492	2022-05-12	0
Sir Neville Marriner	37493	2022-05-12	0
Laid Back	37494	2022-05-12	0
Michael Rose	37495	2022-05-12	0
Dukes Of Hamburg	37496	2022-05-12	0
Justin Timberlake duet with Beyonce	37497	2022-05-12	0
Dose	37498	2022-05-12	0
Ann Nesby	37499	2022-05-12	0
Black Tambourine	37500	2022-05-12	0
Roy Roberts	37501	2022-05-12	0
The Marvelettes	37502	2022-05-12	0
In Fear And Faith	37503	2022-05-12	0
Little Joy	37504	2022-05-12	0
Richard Page	37505	2022-05-12	0
Kelly Clarkson	37506	2022-05-12	0
Exile ft. Breakmaus	37507	2022-05-12	0
Martin Böttcher	37508	2022-05-12	0
Arrah and the Ferns	37509	2022-05-12	0
Passafire	37510	2022-05-12	0
The Roots / Dice Raw / Peedi Peedi	37511	2022-05-12	0
The Thermals	37512	2022-05-12	0
Cinderella Effect	37513	2022-05-12	0
Terrorizer	37514	2022-05-12	0
Duesenjaeger	37515	2022-05-12	0
Les Caméléons	37516	2022-05-12	0
Extreme Noise Terror	37517	2022-05-12	0
The Grass Roots	37518	2022-05-12	0
Evil Wings	37519	2022-05-12	0
Desireless	37520	2022-05-12	0
Jigsaw Band	37521	2022-05-12	0
Christian McBride_ Inside Straight	37522	2022-05-12	0
Premiata Forneria Marconi	37523	2022-05-12	0
Beangrowers	37524	2022-05-12	0
The Clientele	37525	2022-05-12	0
P.J. Olsson	37526	2022-05-12	0
Charlie Haden / Tanya Haden / Rachel Haden	37527	2022-05-12	0
Liquid Scarlet	37528	2022-05-12	0
Optiv Ft. Rymetyme	37529	2022-05-12	0
Amps For Christ	37530	2022-05-12	0
Charley Pride	37531	2022-05-12	0
Russ Reinberg	37532	2022-05-12	0
The Skygreen Leopards	37533	2022-05-12	0
Sara Groves	37534	2022-05-12	0
Videodrone	37535	2022-05-12	0
Milt Jackson	37536	2022-05-12	0
Tommy Bolin Band	37537	2022-05-12	0
Bassholes	37538	2022-05-12	0
Elektricni orgazam	37539	2022-05-12	0
Peter Kruder	37540	2022-05-12	0
Goofy	37541	2022-05-12	0
Ronski Speed presents Sun Decade	37542	2022-05-12	0
Bruno Nicolai	37543	2022-05-12	0
Roscoe Holcomb	37544	2022-05-12	0
Jape Squad	37545	2022-05-12	0
Birds Of Avalon	37546	2022-05-12	0
Bruno Sanfilippo	37547	2022-05-12	0
Kimmo Liskomäen Pitkät Kalsarit	37548	2022-05-12	0
Jessi Colter / Waylon Jennings	37549	2022-05-12	0
Wovenhand	37550	2022-05-12	0
True Faith	37551	2022-05-12	0
Spires That in the Sunset Rise	37552	2022-05-12	0
Sounds from the Ground	37553	2022-05-12	0
Alessandra Celletti	37554	2022-05-12	0
Arthur Fiedler;Peter Nero	37555	2022-05-12	0
Vince Benedetti meets Diana Krall	37556	2022-05-12	0
Ramsay Midwood	37557	2022-05-12	0
Lightnin' Hopkins	37558	2022-05-12	0
Mario ranieri	37559	2022-05-12	0
Atomic Kitten	37560	2022-05-12	0
Attack Formation	37561	2022-05-12	0
Common Rider	37562	2022-05-12	0
Jonathan Coulton	37563	2022-05-12	0
The Delta Mirror	37564	2022-05-12	0
Waylon Jennings	37565	2022-05-12	0
Rufus And Chaka Khan	37566	2022-05-12	0
Jesse Dee	37567	2022-05-12	0
Axel	37568	2022-05-12	0
Flexa Lyndo	37569	2022-05-12	0
Miquel Brown	37570	2022-05-12	0
The Milkman	37571	2022-05-12	0
Rappy McRapperson	37572	2022-05-12	0
Vassar Clements and Jerry Douglas	37573	2022-05-12	0
The Warren Brothers	37574	2022-05-12	0
Whistler's Jug Band	37575	2022-05-12	0
Jona Lewie	37576	2022-05-12	0
Echoing Green_ The	37577	2022-05-12	0
System 7 / Derrick May	37578	2022-05-12	0
Model 500	37579	2022-05-12	0
D.O.	37580	2022-05-12	0
Funkadelic	37581	2022-05-12	0
Millenia Nova	37582	2022-05-12	0
Transvision Vamp	37583	2022-05-12	0
Maral Salmassi	37584	2022-05-12	0
Twentieth Century Zoo	37585	2022-05-12	0
Pat Travers	37586	2022-05-12	0
Leonardo Favio	37587	2022-05-12	0
Goblin	37588	2022-05-12	0
Nils Landgren	37589	2022-05-12	0
J.J. Cale	37590	2022-05-12	0
Yanni	37591	2022-05-12	0
So Sad Althea	37592	2022-05-12	0
Three Fish	37593	2022-05-12	0
Angela Strehli	37594	2022-05-12	0
The Dj Producer	37595	2022-05-12	0
Ste Strausz	37596	2022-05-12	0
Richard Hickox Orchestra / Richard Hickox	37597	2022-05-12	0
Box Elders	37598	2022-05-12	0
Eric Serra	37599	2022-05-12	0
Rafael Toral	37600	2022-05-12	0
DaVIP	37601	2022-05-12	0
Mögel	37602	2022-05-12	0
Wood In Di Fire	37603	2022-05-12	0
Marsen Jules	37604	2022-05-12	0
Baggi Begovic & Bryan Dalton	37605	2022-05-12	0
Vera	37606	2022-05-12	0
Jim Lauderdale	37607	2022-05-12	0
Nova Express	37608	2022-05-12	0
Krondon	37609	2022-05-12	0
Ashton_ Becker_ Dente	37610	2022-05-12	0
Prefuse 73	37611	2022-05-12	0
Belief Systems	37612	2022-05-12	0
Sheila Chandra	37613	2022-05-12	0
Glen Gray & The Casa Loma Orchestra	37614	2022-05-12	0
Pedro Vargas	37615	2022-05-12	0
Fern Knight	37616	2022-05-12	0
Jana Peri	37617	2022-05-12	0
Newsong	37618	2022-05-12	0
De Mens	37619	2022-05-12	0
Fantasia featuring Jazze Pha	37620	2022-05-12	0
Alfredo Kraus	37621	2022-05-12	0
Twilightning	37622	2022-05-12	0
SFX	37623	2022-05-12	0
Derek Sherinian	37624	2022-05-12	0
Susumu Yokota	37625	2022-05-12	0
The Strokes	37626	2022-05-12	0
Frankie Paul	37627	2022-05-12	0
Signum	37628	2022-05-12	0
Lil Keke_ H.A.W.K.	37629	2022-05-12	0
Nachtmahr	37630	2022-05-12	0
Wolfgang Gartner	37631	2022-05-12	0
RICKY LYNN GREGG	37632	2022-05-12	0
Mary McBride	37633	2022-05-12	0
Brenda	37634	2022-05-12	0
Genesis	37635	2022-05-12	0
Salsaloco De Cuba	37636	2022-05-12	0
Sky Tells All	37637	2022-05-12	0
Coma	37638	2022-05-12	0
Cece Winans	37639	2022-05-12	0
Bill Frisell	37640	2022-05-12	0
Big Maceo Merriweather	37641	2022-05-12	0
Jonah Martanga	37642	2022-05-12	0
Josh White	37643	2022-05-12	0
Erik Truffaz	37644	2022-05-12	0
Aksak Maboul	37645	2022-05-12	0
Fifteen	37646	2022-05-12	0
Yumurì	37647	2022-05-12	0
SubNoize Souljaz	37648	2022-05-12	0
Babylon Disco	37649	2022-05-12	0
Alexis Korner	37650	2022-05-12	0
Estrellas Cubanas	37651	2022-05-12	0
Shlomi Aber	37652	2022-05-12	0
Jomanda	37653	2022-05-12	0
Ed Byrne	37654	2022-05-12	0
1 Mile North	37655	2022-05-12	0
Pedro Suarez-Vertiz	37656	2022-05-12	0
DJ Hype & the Phaderheadz	37657	2022-05-12	0
Cutback	37658	2022-05-12	0
Patricia Barber	37659	2022-05-12	0
Dick & Dee Dee	37660	2022-05-12	0
Chase Pagan	37661	2022-05-12	0
Honey Dogs	37662	2022-05-12	0
General Elektriks	37663	2022-05-12	0
Iszoloscope	37664	2022-05-12	0
Black Moth Super Rainbow	37665	2022-05-12	0
The Micragirls	37666	2022-05-12	0
Ninja High School	37667	2022-05-12	0
Espen Lind	37668	2022-05-12	0
Dawnseekers	37669	2022-05-12	0
Powerman 5000	37670	2022-05-12	0
21st Century Symphony Orchestra	37671	2022-05-12	0
Balkan Beat Box	37672	2022-05-12	0
Luna	37673	2022-05-12	0
The View	37674	2022-05-12	0
Bernard Haitink	37675	2022-05-12	0
Suzanne Ciani	37676	2022-05-12	0
Can	37677	2022-05-12	0
Josiah Leming	37678	2022-05-12	0
The Allman Brothers Band	37679	2022-05-12	0
Shat	37680	2022-05-12	0
Mansbestfriend	37681	2022-05-12	0
Olli Banjo	37682	2022-05-12	0
Pole	37683	2022-05-12	0
Bobby Rydell	37684	2022-05-12	0
Los Nakos	37685	2022-05-12	0
J-Diggs	37686	2022-05-12	0
Air Liquide	37687	2022-05-12	0
Al Dexter	37688	2022-05-12	0
Alberto Plaza/Jorge Rojas	37689	2022-05-12	0
Frankie Valli	37690	2022-05-12	0
Dave Brubeck Quartet	37691	2022-05-12	0
Joy Askew	37692	2022-05-12	0
Eddie Kirkland	37693	2022-05-12	0
Les Nubians	37694	2022-05-12	0
Errol Dunkley	37695	2022-05-12	0
Bill Gaither Trio	37696	2022-05-12	0
La Mafia	37697	2022-05-12	0
Macaco	37698	2022-05-12	0
Linkin Park	37699	2022-05-12	0
Magik Johnson	37700	2022-05-12	0
Hella Donna feat. Great Jokers	37701	2022-05-12	0
The London Pops Orchestra	37702	2022-05-12	0
Hurl	37703	2022-05-12	0
Joni James	37704	2022-05-12	0
Steve Miller	37705	2022-05-12	0
Dinamita Pa Los Pollos	37706	2022-05-12	0
The Loved Ones	37707	2022-05-12	0
Woody Herman	37708	2022-05-12	0
Def Con Dos	37709	2022-05-12	0
Sometime Sunday	37710	2022-05-12	0
Monoide	37711	2022-05-12	0
L'Affaire Louis' Trio	37712	2022-05-12	0
Lefty Frizzell	37713	2022-05-12	0
Archie Shepp_ Napoleon Maddox_ Oliver Lake_ Hamid Drake_ Joe Fonda_ Cochemea Gastelum	37714	2022-05-12	0
Josie	37715	2022-05-12	0
Terence Blanchard;Jubilant Sykes	37716	2022-05-12	0
Glenn Tipton	37717	2022-05-12	0
Tito Puenté	37718	2022-05-12	0
Ella Baila Sola	37719	2022-05-12	0
Maldita Nerea	37720	2022-05-12	0
Kevin Moore	37721	2022-05-12	0
Pako & Frederik	37722	2022-05-12	0
Guerilla Black Featuring Jazze Pha and Brooke Valentine	37723	2022-05-12	0
Red Elvises	37724	2022-05-12	0
Static Thought	37725	2022-05-12	0
Luddite Clone	37726	2022-05-12	0
Paul Burch	37727	2022-05-12	0
Exillon	37728	2022-05-12	0
Tejedor	37729	2022-05-12	0
The Go! Team	37730	2022-05-12	0
Myriam Hernandez	37731	2022-05-12	0
Quarteto Em Cy	37732	2022-05-12	0
Mae West	37733	2022-05-12	0
Love Battery	37734	2022-05-12	0
Sarah Vaughan	37735	2022-05-12	0
Undeclinable Ambuscade	37736	2022-05-12	0
Silverstein	37737	2022-05-12	0
Efecto Mariposa	37738	2022-05-12	0
Castanets	37739	2022-05-12	0
The Gufs	37740	2022-05-12	0
Yellow #5	37741	2022-05-12	0
Obrint Pas	37742	2022-05-12	0
DJ Wout	37743	2022-05-12	0
Xavier Naidoo	37744	2022-05-12	0
Jay Reatard	37745	2022-05-12	0
Cripta	37746	2022-05-12	0
Sasha da Link	37747	2022-05-12	0
In Flagranti	37748	2022-05-12	0
Suicide Commando	37749	2022-05-12	0
Graham Coxon	37750	2022-05-12	0
Gene Allison	37751	2022-05-12	0
Billy Preston / Syreeta	37752	2022-05-12	0
Silver Screen	37753	2022-05-12	0
Rotersand	37754	2022-05-12	0
Pharoah Sanders	37755	2022-05-12	0
Josu Distorsión - Los del Puente Romano	37756	2022-05-12	0
Rimini Project	37757	2022-05-12	0
Barry Tuckwell/Academy of St Martin-in-the-Fields/Sir Neville Marriner	37758	2022-05-12	0
Cheek	37759	2022-05-12	0
Attrition	37760	2022-05-12	0
The Q Tips	37761	2022-05-12	0
Byron Janis	37762	2022-05-12	0
Wau y Los Arrrghs	37763	2022-05-12	0
Ysa Ferrer	37764	2022-05-12	0
Dave Gahan	37765	2022-05-12	0
The Waterboys	37766	2022-05-12	0
Nobodys	37767	2022-05-12	0
Terranova	37768	2022-05-12	0
Saian Supa Crew	37769	2022-05-12	0
Jefferson Gonçalves	37770	2022-05-12	0
Daisy Chain	37771	2022-05-12	0
Cleopatra Stratan	37772	2022-05-12	0
Doctor Nerve / Meridian Arts Ensemble	37773	2022-05-12	0
Frankee	37774	2022-05-12	0
Chanta Vielma	37775	2022-05-12	0
Lost Valentinos	37776	2022-05-12	0
Chavez	37777	2022-05-12	0
Format	37778	2022-05-12	0
Zero Tolerance	37779	2022-05-12	0
La Souris Déglinguée	37780	2022-05-12	0
Roy Hargrove Big Band	37781	2022-05-12	0
Colin Blunstone	37782	2022-05-12	0
Dreamtale	37783	2022-05-12	0
Dana Rayne	37784	2022-05-12	0
Puya	37785	2022-05-12	0
Johnny Bond	37786	2022-05-12	0
Action Action	37787	2022-05-12	0
God Forbid	37788	2022-05-12	0
Bargain Music	37789	2022-05-12	0
Ryan Lindsey	37790	2022-05-12	0
Bass Junkie	37791	2022-05-12	0
Gabrielle	37792	2022-05-12	0
Nonpalidece	37793	2022-05-12	0
Ego Likeness	37794	2022-05-12	0
Instituto Mexicano Del Sonido	37795	2022-05-12	0
Haddaway	37796	2022-05-12	0
Bodhisattva 13:20	37797	2022-05-12	0
20/20	37798	2022-05-12	0
Connemara Stone Company	37799	2022-05-12	0
Michael Kamen	37800	2022-05-12	0
Holograf	37801	2022-05-12	0
La Secta AllStar	37802	2022-05-12	0
Brother Ali	37803	2022-05-12	0
The Lovetones	37804	2022-05-12	0
Shadow Gallery	37805	2022-05-12	0
Valentina Madonna	37806	2022-05-12	0
740 Boyz	37807	2022-05-12	0
Ravi Shankar	37808	2022-05-12	0
Thirteen Floor	37809	2022-05-12	0
Georgia White	37810	2022-05-12	0
Nu Brand Flexxx	37811	2022-05-12	0
Starkillerz	37812	2022-05-12	0
Kora	37813	2022-05-12	0
The Beat Daddys	37814	2022-05-12	0
Postgirobygget	37815	2022-05-12	0
Every Avenue	37816	2022-05-12	0
The Neptunas	37817	2022-05-12	0
Billy Lee Riley	37818	2022-05-12	0
Sunshine	37819	2022-05-12	0
Riow Arai	37820	2022-05-12	0
Heatmiser	37821	2022-05-12	0
Arthur H	37822	2022-05-12	0
John Wesley	37823	2022-05-12	0
Dirty Wormz	37824	2022-05-12	0
Silencio Absoluto	37825	2022-05-12	0
Will Downing	37826	2022-05-12	0
Muslimgauze	37827	2022-05-12	0
Dog Faced Gods	37828	2022-05-12	0
GNR	37829	2022-05-12	0
EZSpecial	37830	2022-05-12	0
Borialis	37831	2022-05-12	0
Puff Johnson	37832	2022-05-12	0
Alex Bugnon	37833	2022-05-12	0
Goldie Hill	37834	2022-05-12	0
The Aqua Velvets	37835	2022-05-12	0
Intricate Minds	37836	2022-05-12	0
Jesse Fuller	37837	2022-05-12	0
The Tellers	37838	2022-05-12	0
Here I Come Falling	37839	2022-05-12	0
Booty Love Gang	37840	2022-05-12	0
Secretions	37841	2022-05-12	0
Macbeth	37842	2022-05-12	0
Aceituna sin hueso	37843	2022-05-12	0
Charles Wright	37844	2022-05-12	0
Der Blutharsch	37845	2022-05-12	0
Michael Franti & Spearhead w/Zap Mama	37846	2022-05-12	0
The Summer Obsession	37847	2022-05-12	0
Mekaal Hasan Band	37848	2022-05-12	0
Bang Bang	37849	2022-05-12	0
The Dylans	37850	2022-05-12	0
Jamie T	37851	2022-05-12	0
Sentenced	37852	2022-05-12	0
Ludivine Sagnier_ Jean-Pierre Marielle	37853	2022-05-12	0
Mad Professor	37854	2022-05-12	0
Imiskoubria / La KLiKARiA	37855	2022-05-12	0
Drag-On	37856	2022-05-12	0
Matt Monro	37857	2022-05-12	0
Standstill	37858	2022-05-12	0
Pato Banton	37859	2022-05-12	0
The Winans	37860	2022-05-12	0
Co-Fusion	37861	2022-05-12	0
Alice Cooper;Jeff Beck With Terry Bozzio And Tony Hymas	37862	2022-05-12	0
Raw Produce feat. Kofi	37863	2022-05-12	0
Alan Fitzpatrick	37864	2022-05-12	0
Anarbor	37865	2022-05-12	0
Alvin Youngblood Hart	37866	2022-05-12	0
Obituary	37867	2022-05-12	0
Armin Van Buuren Feat. Justine Suissa	37868	2022-05-12	0
Devin Townsend Band	37869	2022-05-12	0
Takagi Masakatsu	37870	2022-05-12	0
Twisted Individual	37871	2022-05-12	0
Fats Waller	37872	2022-05-12	0
Birdman / Chop	37873	2022-05-12	0
Crime And The City Solution	37874	2022-05-12	0
Jadis	37875	2022-05-12	0
Classics 1v	37876	2022-05-12	0
Call	37877	2022-05-12	0
The Muckrakers	37878	2022-05-12	0
Pangaea	37879	2022-05-12	0
Lifesavas	37880	2022-05-12	0
Gangsters	37881	2022-05-12	0
Idem	37882	2022-05-12	0
Christian Smith	37883	2022-05-12	0
Amaia Montero	37884	2022-05-12	0
Blue Sky Black Death	37885	2022-05-12	0
E. Town Concrete	37886	2022-05-12	0
Sergio Endrigo	37887	2022-05-12	0
Quantum Bigfoot	37888	2022-05-12	0
Cuca	37889	2022-05-12	0
Flux	37890	2022-05-12	0
Gene Ammons / Sonny Stitt	37891	2022-05-12	0
Julian Sas Band	37892	2022-05-12	0
The Plus Ones	37893	2022-05-12	0
SUTCLIFFE JÜGEND	37894	2022-05-12	0
The Sleepy Jackson	37895	2022-05-12	0
The Dials	37896	2022-05-12	0
Stew	37897	2022-05-12	0
Webb Wilder	37898	2022-05-12	0
Roy Haynes	37899	2022-05-12	0
Video Nasties	37900	2022-05-12	0
Charlie Haden_ Egberto Gismonti	37901	2022-05-12	0
Dayton	37902	2022-05-12	0
Tanlines	37903	2022-05-12	0
Exit	37904	2022-05-12	0
Roger Creager	37905	2022-05-12	0
The Chi-Lites	37906	2022-05-12	0
LORE	37907	2022-05-12	0
The Jacka	37908	2022-05-12	0
Edú Lobo / Airto Moreira / Hermeto Pascoal / Claudio Slow / Jose Mariono	37909	2022-05-12	0
Hurricane Gator	37910	2022-05-12	0
Beth Carvalho	37911	2022-05-12	0
Channel 3	37912	2022-05-12	0
Meade Lux Lewis	37913	2022-05-12	0
Paper Rival	37914	2022-05-12	0
Mac Tyer feat. Adji L'Haineux & Bigou	37915	2022-05-12	0
John Mayall & The Bluesbreakers	37916	2022-05-12	0
Onelinedrawing	37917	2022-05-12	0
Sky	37918	2022-05-12	0
Juli	37919	2022-05-12	0
MoZella	37920	2022-05-12	0
Downset	37921	2022-05-12	0
Runrig & The Tartan Army	37922	2022-05-12	0
Balzac	37923	2022-05-12	0
Jupiter One	37924	2022-05-12	0
Kilpi	37925	2022-05-12	0
Kawabata Makoto_Michishita Shinsuke	37926	2022-05-12	0
The Acro-brats	37927	2022-05-12	0
The Silencers	37928	2022-05-12	0
Deine Lakaien	37929	2022-05-12	0
GANGgajang	37930	2022-05-12	0
Deepest Blue	37931	2022-05-12	0
Gary Wright	37932	2022-05-12	0
Marco Pernice	37933	2022-05-12	0
Spirits and Worm	37934	2022-05-12	0
The Art Ensemble of Chicago	37935	2022-05-12	0
Seabound	37936	2022-05-12	0
MF Grimm	37937	2022-05-12	0
Strong Arm Steady	37938	2022-05-12	0
Quantec	37939	2022-05-12	0
Sonny Rollins	37940	2022-05-12	0
A Flock Of Seagulls	37941	2022-05-12	0
Dallas Symphony Orchestra	37942	2022-05-12	0
Monie Love	37943	2022-05-12	0
Marlena ( LADY BLACK LACE )	37944	2022-05-12	0
Linhart & Jackman	37945	2022-05-12	0
Todd Terry	37946	2022-05-12	0
THE EYE	37947	2022-05-12	0
Phantom Limbs	37948	2022-05-12	0
Love Inc.;Simone Denny	37949	2022-05-12	0
Destiny's Child featuring Wyclef Jean	37950	2022-05-12	0
Belami	37951	2022-05-12	0
Rajan & Sajan Mishra_ Shubha Mudgal	37952	2022-05-12	0
Tigran Oganezov	37953	2022-05-12	0
Rascal Flatts	37954	2022-05-12	0
Yves Deruyter	37955	2022-05-12	0
King Swamp	37956	2022-05-12	0
Vanessa Williams / A.J. Baptiste-Caselle / Tavia Rivee Jefferson / Jillian Hervey	37957	2022-05-12	0
Den Gale Pose	37958	2022-05-12	0
Arthur Gunter	37959	2022-05-12	0
Martin	37960	2022-05-12	0
Prager Handgriff	37961	2022-05-12	0
Hammock	37962	2022-05-12	0
Todd Agnew	37963	2022-05-12	0
Chiclete Com Banana	37964	2022-05-12	0
Jesse Belvin	37965	2022-05-12	0
The Sugarhill Gang	37966	2022-05-12	0
John Powell	37967	2022-05-12	0
Anat Ben David	37968	2022-05-12	0
Little Junior Parker	37969	2022-05-12	0
Syl Johnson	37970	2022-05-12	0
Asia 2001	37971	2022-05-12	0
Eleanor McEvoy	37972	2022-05-12	0
Bratmobile	37973	2022-05-12	0
Grand Marquis	37974	2022-05-12	0
The Badloves	37975	2022-05-12	0
Shanes	37976	2022-05-12	0
The Producers	37977	2022-05-12	0
The Shake	37978	2022-05-12	0
Pitbull Daycare	37979	2022-05-12	0
Osvaldo Pugliese	37980	2022-05-12	0
Paul Reddick	37981	2022-05-12	0
Anne Akiko Meyers	37982	2022-05-12	0
Vidar Busk And His True Believers	37983	2022-05-12	0
The Restarts	37984	2022-05-12	0
Mzuri Sana	37985	2022-05-12	0
Seven Witches	37986	2022-05-12	0
Sonics Rendezvous Band	37987	2022-05-12	0
Jermaine Stewart	37988	2022-05-12	0
Thea Gilmore	37989	2022-05-12	0
Aftermath	37990	2022-05-12	0
Airwave featuring Didier Likeng	37991	2022-05-12	0
SM-Trax Feat. Sweet Pussy Pauline	37992	2022-05-12	0
Jay Clifford	37993	2022-05-12	0
Dr. Dooom/Kool Keith/KutMasta Kurt	37994	2022-05-12	0
Stars	37995	2022-05-12	0
Deadmau5 Feat. MC Flipside	37996	2022-05-12	0
La Oreja de Van Gogh	37997	2022-05-12	0
The Glove	37998	2022-05-12	0
Fred Wesley	37999	2022-05-12	0
Kanye West	38000	2022-05-12	0
95 North	38001	2022-05-12	0
Vaux	38002	2022-05-12	0
The Cute Lepers	38003	2022-05-12	0
Bolt Thrower	38004	2022-05-12	0
Alias	38005	2022-05-12	0
Soulsister	38006	2022-05-12	0
Gogi Grant	38007	2022-05-12	0
Lars Hollmer	38008	2022-05-12	0
Philip Jeck	38009	2022-05-12	0
Locust	38010	2022-05-12	0
Danny Wright	38011	2022-05-12	0
Normie Rowe	38012	2022-05-12	0
NRA	38013	2022-05-12	0
Mud Flow	38014	2022-05-12	0
La Shica	38015	2022-05-12	0
Angela Lansbury	38016	2022-05-12	0
Loic Lantoine	38017	2022-05-12	0
Stevie Face	38018	2022-05-12	0
The Crimson Ghosts	38019	2022-05-12	0
John Mayer	38020	2022-05-12	0
Kenji Williams	38021	2022-05-12	0
Los Toreros Muertos	38022	2022-05-12	0
Moss & Szade feat. Audrey Valorzi	38023	2022-05-12	0
David Coverdale	38024	2022-05-12	0
Mochipet	38025	2022-05-12	0
Trijntje Oosterhuis	38026	2022-05-12	0
Backyard Babies	38027	2022-05-12	0
Les Savy Fav	38028	2022-05-12	0
Peter Herbolzheimer Rhythm Combination & Brass	38029	2022-05-12	0
Fischerspooner	38030	2022-05-12	0
Meitz	38031	2022-05-12	0
Sharkey	38032	2022-05-12	0
Hell Razah	38033	2022-05-12	0
The Old Haunts	38034	2022-05-12	0
Ny Rel-X	38035	2022-05-12	0
Brice Kapel	38036	2022-05-12	0
Avant Garde_ Avant Garde	38037	2022-05-12	0
Mandy Moore	38038	2022-05-12	0
Leona Lewis	38039	2022-05-12	0
Alex Pahlke	38040	2022-05-12	0
Retsin	38041	2022-05-12	0
Taco	38042	2022-05-12	0
Ana Biaze	38043	2022-05-12	0
Klement Julienne	38044	2022-05-12	0
The Psycho Realm_ Sick Jacken_ Duke	38045	2022-05-12	0
3 Steps Ahead	38046	2022-05-12	0
Sarah Silverman	38047	2022-05-12	0
Colombia Alegre Y Romantica	38048	2022-05-12	0
Tiger Lillies	38049	2022-05-12	0
Jadon Lavik	38050	2022-05-12	0
Luca Zeta	38051	2022-05-12	0
John Patitucci	38052	2022-05-12	0
The Happenings	38053	2022-05-12	0
Mary Louise Wilson	38054	2022-05-12	0
Billy Klippert	38055	2022-05-12	0
The New Mastersounds	38056	2022-05-12	0
El Meswy	38057	2022-05-12	0
Sam Punk & Weichei pres. Kanakk Attakk	38058	2022-05-12	0
Stereotypical Working Class	38059	2022-05-12	0
9th Corner	38060	2022-05-12	0
As One	38061	2022-05-12	0
Brian Jonestown Massacre	38062	2022-05-12	0
Tuomas Rantanen	38063	2022-05-12	0
Anfall	38064	2022-05-12	0
Richie Spice	38065	2022-05-12	0
Lelio Luttazzi	38066	2022-05-12	0
Jimpster	38067	2022-05-12	0
Blancmange	38068	2022-05-12	0
Easy Star All-Stars	38069	2022-05-12	0
Michael Penn	38070	2022-05-12	0
Cleve Francis	38071	2022-05-12	0
The Paragons	38072	2022-05-12	0
Chad Wackerman	38073	2022-05-12	0
Legendary Pink Dots	38074	2022-05-12	0
Phil Kline	38075	2022-05-12	0
J.B. Hutto	38076	2022-05-12	0
Steve Wynn & The Dragon Bridge Orchestra	38077	2022-05-12	0
Dan Cummins	38078	2022-05-12	0
Magazin	38079	2022-05-12	0
Liquid Gang	38080	2022-05-12	0
Peter Poehl	38081	2022-05-12	0
2 Damn Tuff	38082	2022-05-12	0
Refractory	38083	2022-05-12	0
Vagrants	38084	2022-05-12	0
Judy Garland	38085	2022-05-12	0
Patrick Moraz	38086	2022-05-12	0
Bintangs	38087	2022-05-12	0
Speckled Red	38088	2022-05-12	0
Zélia Duncan	38089	2022-05-12	0
People Under The Stairs	38090	2022-05-12	0
Ricky Martin	38091	2022-05-12	0
Patterson Hood	38092	2022-05-12	0
Sloan	38093	2022-05-12	0
Greg Mathieson	38094	2022-05-12	0
Mystical Sun	38095	2022-05-12	0
Chimaira	38096	2022-05-12	0
North Mississippi All Stars	38097	2022-05-12	0
Carlos Ponce	38098	2022-05-12	0
Alesha Dixon	38099	2022-05-12	0
Glen Campbell And Bobbie Gentry	38100	2022-05-12	0
Allure	38101	2022-05-12	0
Badness	38102	2022-05-12	0
BT_ Tommy Stinson	38103	2022-05-12	0
Eddie Sierra	38104	2022-05-12	0
Bruford	38105	2022-05-12	0
Sherie Rene Scott	38106	2022-05-12	0
Wes Jeans	38107	2022-05-12	0
Blossom Dearie	38108	2022-05-12	0
Janice Vidal	38109	2022-05-12	0
Lenny White	38110	2022-05-12	0
Lewis Black	38111	2022-05-12	0
Eddie Fisher	38112	2022-05-12	0
Annie Lennox	38113	2022-05-12	0
Donna Summer	38114	2022-05-12	0
Jorma Kaukonen	38115	2022-05-12	0
Mitchell Jones	38116	2022-05-12	0
Sub City Dwellers	38117	2022-05-12	0
Building 429	38118	2022-05-12	0
AVID All Stars	38119	2022-05-12	0
Blood Meridian	38120	2022-05-12	0
Kenn Starr	38121	2022-05-12	0
Miika Kuisma	38122	2022-05-12	0
Positive Force	38123	2022-05-12	0
Ministry	38124	2022-05-12	0
Intro	38125	2022-05-12	0
Sierra Maestra	38126	2022-05-12	0
Letta Mbulu	38127	2022-05-12	0
Dominic	38128	2022-05-12	0
Herbert	38129	2022-05-12	0
Boris Divider	38130	2022-05-12	0
Eleni Mandell	38131	2022-05-12	0
Stan Getz	38132	2022-05-12	0
Mystery Islands & Stefan Cambridge pres. Chapter G8	38133	2022-05-12	0
Ledisi	38134	2022-05-12	0
Art of Trance	38135	2022-05-12	0
Darin	38136	2022-05-12	0
Aswad	38137	2022-05-12	0
Noiseshaper	38138	2022-05-12	0
After The Fire	38139	2022-05-12	0
George Hamilton IV	38140	2022-05-12	0
Rebecca St. James	38141	2022-05-12	0
Vast Aire Feat. Karniege_ Breez Evahflowin_ Poison Pen & Aesop Rock	38142	2022-05-12	0
Spanner Banner	38143	2022-05-12	0
SSM	38144	2022-05-12	0
X-Clan	38145	2022-05-12	0
Cheb Kader	38146	2022-05-12	0
Storm Warning	38147	2022-05-12	0
Ernesto	38148	2022-05-12	0
Halifax	38149	2022-05-12	0
Prince Jammy vs King Tubbys	38150	2022-05-12	0
The Cowsills	38151	2022-05-12	0
Bernadette Peters;John Mauceri	38152	2022-05-12	0
Casual Violence	38153	2022-05-12	0
Justin Tubb	38154	2022-05-12	0
Jason & The Scorchers	38155	2022-05-12	0
Memphis Sheiks	38156	2022-05-12	0
Machito and His Afro-Cuban Orchestra	38157	2022-05-12	0
Desaparecidos	38158	2022-05-12	0
Shauna Burns	38159	2022-05-12	0
Bob Gallion	38160	2022-05-12	0
Ray Charles Trio	38161	2022-05-12	0
Josh Joplin Group	38162	2022-05-12	0
SoulPrint	38163	2022-05-12	0
The Mormon Tabernacle Choir	38164	2022-05-12	0
Left Hand Solution	38165	2022-05-12	0
The Sabres Of Paradise	38166	2022-05-12	0
Mike Misar	38167	2022-05-12	0
Collection D'Arnell-Andrea	38168	2022-05-12	0
The Beatnuts	38169	2022-05-12	0
Fourplay	38170	2022-05-12	0
Los Visitantes	38171	2022-05-12	0
J.	38172	2022-05-12	0
Claudio Abbado	38173	2022-05-12	0
Good Riddance	38174	2022-05-12	0
Les Hou-Lops	38175	2022-05-12	0
Horacio Salgán	38176	2022-05-12	0
Lonnie Youngblood	38177	2022-05-12	0
K'Naan	38178	2022-05-12	0
Punchdrunk	38179	2022-05-12	0
Sunset Rubdown	38180	2022-05-12	0
Red Flag 77	38181	2022-05-12	0
Scanner	38182	2022-05-12	0
Trusty	38183	2022-05-12	0
Silly Wizard	38184	2022-05-12	0
Performed by Jennifer Hudson_;Deena Jones and The Dreams;Dreamgirls (Motion Picture Soundtrack)	38185	2022-05-12	0
Da Headbussaz	38186	2022-05-12	0
RaRa Avis	38187	2022-05-12	0
Marduk	38188	2022-05-12	0
U2 Tribute	38189	2022-05-12	0
Natalia Lesz	38190	2022-05-12	0
Lou Rawls	38191	2022-05-12	0
Passport	38192	2022-05-12	0
Patton Oswalt	38193	2022-05-12	0
The Delmore Brothers	38194	2022-05-12	0
Konstantin Wecker	38195	2022-05-12	0
Beyond The Embrace	38196	2022-05-12	0
Minus The Bear	38197	2022-05-12	0
Alex K	38198	2022-05-12	0
Audra McDonald	38199	2022-05-12	0
Barbara Morrison with Johnny Otis and His Band	38200	2022-05-12	0
Robin Gibb	38201	2022-05-12	0
Paso Doble	38202	2022-05-12	0
Kate Voegele	38203	2022-05-12	0
Christopher Cross	38204	2022-05-12	0
Jehst feat. Klashnekoff & Lewis Parker	38205	2022-05-12	0
Dr Kucho!_ Gregor Salto	38206	2022-05-12	0
Marcos Valle	38207	2022-05-12	0
Debby Boone	38208	2022-05-12	0
Attention Deficit	38209	2022-05-12	0
Bow Wow	38210	2022-05-12	0
Kali	38211	2022-05-12	0
Keali I Reichel	38212	2022-05-12	0
Edmundo Ros & His Orchestra	38213	2022-05-12	0
Lil' Kim (Featuring Grace Jones and Lil' Cease)	38214	2022-05-12	0
Los Lobos	38215	2022-05-12	0
Warrior King	38216	2022-05-12	0
Orla Fallon	38217	2022-05-12	0
Loko	38218	2022-05-12	0
Peter Hadar	38219	2022-05-12	0
The Nolans	38220	2022-05-12	0
Brighteye Brison	38221	2022-05-12	0
Steve Lukather	38222	2022-05-12	0
Bone Thugs-N-Harmony	38223	2022-05-12	0
Raymond Lefèvre	38224	2022-05-12	0
Israel Philharmonic Orchestra / Zubin Mehta	38225	2022-05-12	0
Adam Green	38226	2022-05-12	0
The Sunny Cowgirls	38227	2022-05-12	0
Massimo Ranieri	38228	2022-05-12	0
Ten City	38229	2022-05-12	0
Bad Astronaut	38230	2022-05-12	0
Headhunterz & Wildstylez	38231	2022-05-12	0
Languis	38232	2022-05-12	0
Kemko	38233	2022-05-12	0
Band of Pain	38234	2022-05-12	0
Paul Wall feat. Lil Keke	38235	2022-05-12	0
Seth Lakeman	38236	2022-05-12	0
DJ Spinn	38237	2022-05-12	0
Hervé	38238	2022-05-12	0
Alonzo	38239	2022-05-12	0
RUSTY & DOUG KERSHAW	38240	2022-05-12	0
Strip Steve	38241	2022-05-12	0
The Five Stairsteps	38242	2022-05-12	0
The Pale Fountains	38243	2022-05-12	0
Little Jackie	38244	2022-05-12	0
Jermaine Dupri & DJ Ideal	38245	2022-05-12	0
Milly Quezada	38246	2022-05-12	0
Deathstars	38247	2022-05-12	0
Joe Higgs	38248	2022-05-12	0
33Miles	38249	2022-05-12	0
Brainticket	38250	2022-05-12	0
Birdman	38251	2022-05-12	0
Pirupa_ Pigi	38252	2022-05-12	0
Gene Ammons Band	38253	2022-05-12	0
Walter Wanderley	38254	2022-05-12	0
Lizzy Mercier Descloux	38255	2022-05-12	0
Juniper Moon	38256	2022-05-12	0
White Willow	38257	2022-05-12	0
Sunstorm	38258	2022-05-12	0
Nikolaj Nørlund	38259	2022-05-12	0
Ryuji Takeuchi	38260	2022-05-12	0
Dave Young	38261	2022-05-12	0
Arthur 'Big Boy' Crudup	38262	2022-05-12	0
Templars	38263	2022-05-12	0
Natalie Grant	38264	2022-05-12	0
Lenny Dee & Radium	38265	2022-05-12	0
Antony & The Johnsons	38266	2022-05-12	0
The Buckinghams	38267	2022-05-12	0
Moto Boy	38268	2022-05-12	0
Chris Hülsbeck	38269	2022-05-12	0
Jay Frog	38270	2022-05-12	0
Fear Factory	38271	2022-05-12	0
Grupo Gale	38272	2022-05-12	0
David Holmes presents The Free Association	38273	2022-05-12	0
Camera Obscura	38274	2022-05-12	0
Funk Brothers	38275	2022-05-12	0
Breite Seite	38276	2022-05-12	0
The Beauty Room	38277	2022-05-12	0
Sasha Sokol	38278	2022-05-12	0
Aya	38279	2022-05-12	0
Mike Batt	38280	2022-05-12	0
Sky Larkin	38281	2022-05-12	0
Shadiya	38282	2022-05-12	0
Dave Lambert & Housetrap feat. Liam South	38283	2022-05-12	0
Polaris	38284	2022-05-12	0
Finale	38285	2022-05-12	0
Drevo	38286	2022-05-12	0
Yumuri y sus hermanos	38287	2022-05-12	0
Ancient Astronauts	38288	2022-05-12	0
Clubzound	38289	2022-05-12	0
Ali ft. Leki	38290	2022-05-12	0
Vladimir Horowitz	38291	2022-05-12	0
Orquesta Broadway	38292	2022-05-12	0
Simple	38293	2022-05-12	0
Wilkins	38294	2022-05-12	0
Jimmy Smith / B.B. King	38295	2022-05-12	0
Choeurs Et Orchestre Radio-Lyrique De Paris_ Andre Pernet_ Lucien Lovano_ Solange Michel	38296	2022-05-12	0
Daisy	38297	2022-05-12	0
The Holy Kiss	38298	2022-05-12	0
A Plea For Purging	38299	2022-05-12	0
Gordon Goodwin's Big Phat Band	38300	2022-05-12	0
Yael Naim / Lisbeth Guldbaek / Anne Warin / Pedro Alves	38301	2022-05-12	0
Lucy Pearl	38302	2022-05-12	0
Georgia Gibbs	38303	2022-05-12	0
Los De Adentro	38304	2022-05-12	0
Datblygu	38305	2022-05-12	0
Joshua Radin	38306	2022-05-12	0
John Waite	38307	2022-05-12	0
Los Dareyes De La Sierra	38308	2022-05-12	0
Nicolette Larson	38309	2022-05-12	0
Die Krupps	38310	2022-05-12	0
Will Smith	38311	2022-05-12	0
Jude Cole	38312	2022-05-12	0
Temprees	38313	2022-05-12	0
Pedro Khima	38314	2022-05-12	0
Bert Jansch / John Renbourn	38315	2022-05-12	0
The Boswell Sisters	38316	2022-05-12	0
Cold War Kids	38317	2022-05-12	0
Reckless Kelly	38318	2022-05-12	0
Blessure Grave	38319	2022-05-12	0
The Verve Pipe	38320	2022-05-12	0
Fad Gadget	38321	2022-05-12	0
Max Sedgley	38322	2022-05-12	0
MSTRKRFT	38323	2022-05-12	0
Muddy Waters	38324	2022-05-12	0
Lazee Feat. Neverstore	38325	2022-05-12	0
Support Lesbiens	38326	2022-05-12	0
Wild Horses	38327	2022-05-12	0
Cicada	38328	2022-05-12	0
Cult Of Luna	38329	2022-05-12	0
Day Of Fire	38330	2022-05-12	0
Liberty N Justice	38331	2022-05-12	0
T.O.K.	38332	2022-05-12	0
Hanne Hukkelberg	38333	2022-05-12	0
Kojak	38334	2022-05-12	0
Spencer Brewer/Eric Tingstad/Nancy Rumbel	38335	2022-05-12	0
Kuba	38336	2022-05-12	0
Amusement Parks On Fire	38337	2022-05-12	0
Espers	38338	2022-05-12	0
Byron Lee & The Dragonaires	38339	2022-05-12	0
Coldfeet	38340	2022-05-12	0
Les Humphries Singers	38341	2022-05-12	0
Matthew Puckett	38342	2022-05-12	0
Silvana Malta	38343	2022-05-12	0
Persephone	38344	2022-05-12	0
The Puppini Sisters	38345	2022-05-12	0
Jan and Dean	38346	2022-05-12	0
Tyler Bates	38347	2022-05-12	0
Spear Of Destiny	38348	2022-05-12	0
Supa	38349	2022-05-12	0
Monsters Of Folk	38350	2022-05-12	0
Idiot Pilot	38351	2022-05-12	0
Kafani	38352	2022-05-12	0
Ráfaga	38353	2022-05-12	0
Wild Nothing	38354	2022-05-12	0
Christian Anders	38355	2022-05-12	0
Mike Badger and Friends	38356	2022-05-12	0
Rod Mason & Ray Foxley	38357	2022-05-12	0
Brodka	38358	2022-05-12	0
Billy Joe Shaver_ Tanya Tucker	38359	2022-05-12	0
Rosie Thomas	38360	2022-05-12	0
Emmas Mini	38361	2022-05-12	0
Earl Scruggs	38362	2022-05-12	0
Bad Wizard	38363	2022-05-12	0
Shamanic Tribes On Acid	38364	2022-05-12	0
Stephen Duffy	38365	2022-05-12	0
Unashamed	38366	2022-05-12	0
Sean Lennon	38367	2022-05-12	0
Mayer Hawthorne	38368	2022-05-12	0
Deadly Avenger	38369	2022-05-12	0
Devin The Dude	38370	2022-05-12	0
Royal Bangs	38371	2022-05-12	0
Zomby	38372	2022-05-12	0
P Ramlee	38373	2022-05-12	0
Lao Tizer	38374	2022-05-12	0
The Four Preps	38375	2022-05-12	0
Mobb Deep featuring Lil Cease	38376	2022-05-12	0
Orchestra Di Piazza Vittorio	38377	2022-05-12	0
Frankie Bones	38378	2022-05-12	0
The Derailers	38379	2022-05-12	0
Danny Davis & The Boys	38380	2022-05-12	0
Moneybrother	38381	2022-05-12	0
Richmond Fontaine	38382	2022-05-12	0
Divine Heresy	38383	2022-05-12	0
E.G. Daily	38384	2022-05-12	0
Ikara Colt	38385	2022-05-12	0
Shirley & Company	38386	2022-05-12	0
Toy Dolls	38387	2022-05-12	0
Cracklin Moth	38388	2022-05-12	0
Acid Mothers Temple & The Cosmic Inferno	38389	2022-05-12	0
Alan Jackson duet with The Chipmunks	38390	2022-05-12	0
Carla Cook	38391	2022-05-12	0
Christian Smith_ John Selway	38392	2022-05-12	0
Baron Zen	38393	2022-05-12	0
Sinik & Reeno	38394	2022-05-12	0
Secret Archives of the Vatican	38395	2022-05-12	0
UCast	38396	2022-05-12	0
RJD2	38397	2022-05-12	0
Jimmy Burns	38398	2022-05-12	0
The Satintones	38399	2022-05-12	0
Pants Yell!	38400	2022-05-12	0
Friday Bridge	38401	2022-05-12	0
Beth Nielsen Chapman	38402	2022-05-12	0
Casey Driessen	38403	2022-05-12	0
Babado Novo	38404	2022-05-12	0
Righteous Pigs	38405	2022-05-12	0
The Original London Cast	38406	2022-05-12	0
Social Unrest	38407	2022-05-12	0
Nouvelle	38408	2022-05-12	0
The Eyeliners	38409	2022-05-12	0
Monsta Boy	38410	2022-05-12	0
Murder Junkies	38411	2022-05-12	0
Left Alone	38412	2022-05-12	0
Daddy Rings	38413	2022-05-12	0
Rhino 39	38414	2022-05-12	0
Jonezetta	38415	2022-05-12	0
Elvis Costello	38416	2022-05-12	0
Raymond Van Het Groenewoud	38417	2022-05-12	0
R.L. Burnside & The Sound Machine	38418	2022-05-12	0
Jr. James & the Late Guitar	38419	2022-05-12	0
The Sammies	38420	2022-05-12	0
Quicksilver Messenger Service	38421	2022-05-12	0
Ruff Ryders / Jay-Z	38422	2022-05-12	0
Don Choa	38423	2022-05-12	0
Mark Knopfler	38424	2022-05-12	0
Madd Anju	38425	2022-05-12	0
Paradise Lost	38426	2022-05-12	0
Epifani Barbers	38427	2022-05-12	0
Basti Grub	38428	2022-05-12	0
Phylum Sinter	38429	2022-05-12	0
Claudia Telles	38430	2022-05-12	0
U.P.O.	38431	2022-05-12	0
The Sunshine Boys	38432	2022-05-12	0
She & Him	38433	2022-05-12	0
Allegra	38434	2022-05-12	0
Corinna May	38435	2022-05-12	0
St. Raw	38436	2022-05-12	0
702	38437	2022-05-12	0
Patrícia Candoso	38438	2022-05-12	0
Austin Pitre	38439	2022-05-12	0
Waxies Dargle	38440	2022-05-12	0
Karen Peck And New River	38441	2022-05-12	0
Ladytron	38442	2022-05-12	0
Memphis Slim and Willie Dixon with Pete Seeger	38443	2022-05-12	0
The Cleaners	38444	2022-05-12	0
Kings Of Leon	38445	2022-05-12	0
Charles Mingus / John LaPorta	38446	2022-05-12	0
Cinema Bizarre	38447	2022-05-12	0
Bonde Do Role	38448	2022-05-12	0
Dennis Bovell	38449	2022-05-12	0
Ustad Amjad Ali Khan	38450	2022-05-12	0
Wes King	38451	2022-05-12	0
Van McCoy	38452	2022-05-12	0
Sugarplum Fairy	38453	2022-05-12	0
Dischange	38454	2022-05-12	0
A Day To Remember	38455	2022-05-12	0
John Frusciante	38456	2022-05-12	0
Bottin	38457	2022-05-12	0
Two Cow Garage	38458	2022-05-12	0
Frederic Galliano	38459	2022-05-12	0
Fertig_ Los!	38460	2022-05-12	0
Falco	38461	2022-05-12	0
Curse	38462	2022-05-12	0
The Cab	38463	2022-05-12	0
Tom T. Hall	38464	2022-05-12	0
Rockin' Horse	38465	2022-05-12	0
Deep Zone	38466	2022-05-12	0
Ile Axe	38467	2022-05-12	0
Fishbone	38468	2022-05-12	0
88 Fingers Louie	38469	2022-05-12	0
Orion	38470	2022-05-12	0
Tijuana Hercules	38471	2022-05-12	0
Andy Lau	38472	2022-05-12	0
Odd Nosdam	38473	2022-05-12	0
Aurlus Mabélé	38474	2022-05-12	0
Oscar Peterson Trio	38475	2022-05-12	0
Chris Brady	38476	2022-05-12	0
Raul Midon	38477	2022-05-12	0
Leona Williams & Edna Winston	38478	2022-05-12	0
Skillz	38479	2022-05-12	0
Daryle Singletary	38480	2022-05-12	0
Sam 'Lightnin' Hopkins	38481	2022-05-12	0
Helix	38482	2022-05-12	0
Indukti	38483	2022-05-12	0
HOLLY DUNN	38484	2022-05-12	0
Mastiksoul	38485	2022-05-12	0
Jan Blohm	38486	2022-05-12	0
Page McConnell	38487	2022-05-12	0
Paul Davis	38488	2022-05-12	0
Herbie Hancock	38489	2022-05-12	0
Butcher Boy	38490	2022-05-12	0
Paula Toller	38491	2022-05-12	0
Prinz Porno	38492	2022-05-12	0
Fol Chen	38493	2022-05-12	0
Severe Torture	38494	2022-05-12	0
The Country Gentlemen	38495	2022-05-12	0
Samira	38496	2022-05-12	0
Duraluxe	38497	2022-05-12	0
Frank Crumit	38498	2022-05-12	0
Nancy Kerr & James Fagan	38499	2022-05-12	0
Marvin Hamlisch;John Lithgow;Jeffrey Huard	38500	2022-05-12	0
Litzy	38501	2022-05-12	0
Skank	38502	2022-05-12	0
Morrissey	38503	2022-05-12	0
Bloodlined Calligraphy	38504	2022-05-12	0
Nikita	38505	2022-05-12	0
Russell Malone	38506	2022-05-12	0
Angeles del Infierno	38507	2022-05-12	0
Padi	38508	2022-05-12	0
Sarah Jane Morris	38509	2022-05-12	0
officerfishdumplings	38510	2022-05-12	0
Eagle Seagull	38511	2022-05-12	0
Paul Johnson Feat. Candi Staton	38512	2022-05-12	0
Vincent Vincent And The Villains	38513	2022-05-12	0
Michael Fakesch	38514	2022-05-12	0
Ethel Merman / The London Festival Chorus / Stanley Black	38515	2022-05-12	0
Rance Allen Group	38516	2022-05-12	0
Mavericks	38517	2022-05-12	0
Galadriel	38518	2022-05-12	0
Bebo Valdes	38519	2022-05-12	0
Ning Baizura	38520	2022-05-12	0
Rod Carrillo & Shefali	38521	2022-05-12	0
Gus Cannon & Noah Lewis	38522	2022-05-12	0
The Aim Of Design Is To Define Space	38523	2022-05-12	0
Ivan Moravec	38524	2022-05-12	0
Wizo	38525	2022-05-12	0
Collective Sound Members	38526	2022-05-12	0
Rico Bernasconi	38527	2022-05-12	0
Ronnie Wood	38528	2022-05-12	0
Black Stone Cherry	38529	2022-05-12	0
Ned's Atomic Dustbin	38530	2022-05-12	0
Kill Your Idols	38531	2022-05-12	0
Kevin Lyttle	38532	2022-05-12	0
U-Recken	38533	2022-05-12	0
Eclection	38534	2022-05-12	0
Beans	38535	2022-05-12	0
Jermaine Jackson & Pia Zadora	38536	2022-05-12	0
Bobby Marchan	38537	2022-05-12	0
Stacey Kent	38538	2022-05-12	0
Declan Galbraith	38539	2022-05-12	0
Bringing Down Broadway	38540	2022-05-12	0
Sufjan Stevens	38541	2022-05-12	0
Buddy Knox	38542	2022-05-12	0
Volcano_ I'm Still Excited!!	38543	2022-05-12	0
Kenny Rogers And Dottie West	38544	2022-05-12	0
Phyllis Nelson	38545	2022-05-12	0
Sons of Otis	38546	2022-05-12	0
Party Pimpz	38547	2022-05-12	0
Bedlight For Blue Eyes	38548	2022-05-12	0
Mustasch	38549	2022-05-12	0
Kato	38550	2022-05-12	0
nmperign	38551	2022-05-12	0
Andy Duguid	38552	2022-05-12	0
T.G.Sheppard	38553	2022-05-12	0
Janus	38554	2022-05-12	0
D-Factor	38555	2022-05-12	0
James Blood Ulmer	38556	2022-05-12	0
Peter Banks	38557	2022-05-12	0
Soularis ft. Mandy Edge	38558	2022-05-12	0
Sir Harry Lauder	38559	2022-05-12	0
Paul Whiteman & His Orchestra	38560	2022-05-12	0
Kathy Kallick	38561	2022-05-12	0
SITD	38562	2022-05-12	0
Lil' Kim	38563	2022-05-12	0
Kite	38564	2022-05-12	0
Michel Camilo	38565	2022-05-12	0
Syndrome	38566	2022-05-12	0
24-7 Spyz	38567	2022-05-12	0
Ectomorph	38568	2022-05-12	0
Gloria Trevi	38569	2022-05-12	0
Checco Zalone	38570	2022-05-12	0
Hack Mack Jackson	38571	2022-05-12	0
THE CHIFFONS	38572	2022-05-12	0
37500 Yens	38573	2022-05-12	0
Orthrelm	38574	2022-05-12	0
M&T	38575	2022-05-12	0
The Dirtbombs	38576	2022-05-12	0
Figurines	38577	2022-05-12	0
Lower Class Brats	38578	2022-05-12	0
Young Canadians	38579	2022-05-12	0
Dan Colehour	38580	2022-05-12	0
Negativ	38581	2022-05-12	0
Macabre Instincts	38582	2022-05-12	0
Yelle	38583	2022-05-12	0
John Spiers & Jon Boden	38584	2022-05-12	0
Mikromusic	38585	2022-05-12	0
Robert Goulet	38586	2022-05-12	0
Jonny Lang	38587	2022-05-12	0
Roberta Gambarini	38588	2022-05-12	0
PROKID	38589	2022-05-12	0
This Or The Apocalypse	38590	2022-05-12	0
Diego "El Cigala	38591	2022-05-12	0
The Dominoes	38592	2022-05-12	0
Mirage Of Deep	38593	2022-05-12	0
Infadels	38594	2022-05-12	0
The Whitlams	38595	2022-05-12	0
David Banner / Marcus / Kamikazi	38596	2022-05-12	0
Thirst	38597	2022-05-12	0
Carter Burwell	38598	2022-05-12	0
John Mayall's Bluesbreakers	38599	2022-05-12	0
Mind:State	38600	2022-05-12	0
Tony Levin	38601	2022-05-12	0
Crash Test Dummies	38602	2022-05-12	0
Reggie Rockstone	38603	2022-05-12	0
Rolo vs Dj Kram	38604	2022-05-12	0
Margo Guryan	38605	2022-05-12	0
Clue To Kalo	38606	2022-05-12	0
Visaci Zamek	38607	2022-05-12	0
Rebirth Brass Band	38608	2022-05-12	0
Bénabar	38609	2022-05-12	0
The Black Crowes	38610	2022-05-12	0
Jag	38611	2022-05-12	0
Abbey Lincoln	38612	2022-05-12	0
USSA	38613	2022-05-12	0
MALIAN MUSICIANS & DAMON ALBARN	38614	2022-05-12	0
Mr. Lif	38615	2022-05-12	0
Brand New	38616	2022-05-12	0
Bill Douglas / The Ars Nova Singers	38617	2022-05-12	0
Elin Ruth Sigvardsson [feat. Magnus Carlson]	38618	2022-05-12	0
Pablo Francisco	38619	2022-05-12	0
Next	38620	2022-05-12	0
Hovia Edwards	38621	2022-05-12	0
The Radio Dept.	38622	2022-05-12	0
The Electric Soft Parade	38623	2022-05-12	0
Infuzija	38624	2022-05-12	0
Yiota Vei	38625	2022-05-12	0
Ray LaMontagne	38626	2022-05-12	0
Wamba	38627	2022-05-12	0
Jim Ford	38628	2022-05-12	0
Tonex	38629	2022-05-12	0
Darkseed	38630	2022-05-12	0
Sprinkler	38631	2022-05-12	0
Frisco vs Ice MC	38632	2022-05-12	0
Robert Forster	38633	2022-05-12	0
Times New Viking	38634	2022-05-12	0
Get Cape. Wear Cape. Fly	38635	2022-05-12	0
Throneberry	38636	2022-05-12	0
Cirque du Soleil	38637	2022-05-12	0
Kerry Livgren	38638	2022-05-12	0
Llewellyn	38639	2022-05-12	0
Sharon Burch	38640	2022-05-12	0
Acid Casuals	38641	2022-05-12	0
Cibo Matto	38642	2022-05-12	0
Klute	38643	2022-05-12	0
Tipton_  Entwistle & Powell	38644	2022-05-12	0
Tombthroat	38645	2022-05-12	0
Calibre	38646	2022-05-12	0
Roddy Frame	38647	2022-05-12	0
Joe Harnell	38648	2022-05-12	0
Tito El Bambino	38649	2022-05-12	0
Rio Reiser	38650	2022-05-12	0
Donald Lawrence & The Tri-City Singers	38651	2022-05-12	0
Mariya Takeuchi	38652	2022-05-12	0
The God Damn Whores	38653	2022-05-12	0
Deekline & Wizard	38654	2022-05-12	0
Jump Project	38655	2022-05-12	0
Tiger Army	38656	2022-05-12	0
Orlando Pops Orchestra and Andrew Lane	38657	2022-05-12	0
Geraint Jarman A'r Cynganeddwyr	38658	2022-05-12	0
Kozma Orsi	38659	2022-05-12	0
Dusty Springfield	38660	2022-05-12	0
Mono men	38661	2022-05-12	0
KJ-52	38662	2022-05-12	0
Delorentos	38663	2022-05-12	0
Jon Faddis	38664	2022-05-12	0
Hello	38665	2022-05-12	0
Gedicke	38666	2022-05-12	0
Ziggy Marley And The Melody Makers	38667	2022-05-12	0
Virtus_ Shanty Band	38668	2022-05-12	0
Howlin' Wolf	38669	2022-05-12	0
Ween	38670	2022-05-12	0
Roomsa	38671	2022-05-12	0
Beats For Beginners	38672	2022-05-12	0
4 Skins	38673	2022-05-12	0
Little People	38674	2022-05-12	0
Megalon	38675	2022-05-12	0
Ethel Smith	38676	2022-05-12	0
Lifelover	38677	2022-05-12	0
Super Deluxe	38678	2022-05-12	0
Ranking Toyan	38679	2022-05-12	0
Cesare Basile	38680	2022-05-12	0
Sam the Kid	38681	2022-05-12	0
Tora Tora	38818	2022-05-12	0
Amalia Mendoza Con El Mariachi Vargas De Tecalitlan	38682	2022-05-12	0
DJ Vadim feat. Gift of Gab	38683	2022-05-12	0
Annie	38684	2022-05-12	0
Danza Invisible	38685	2022-05-12	0
Not Breathing	38686	2022-05-12	0
Faker	38687	2022-05-12	0
Guru Josh Project	38688	2022-05-12	0
Dani Marsan	38689	2022-05-12	0
Brian Schober	38690	2022-05-12	0
5 Bugs	38691	2022-05-12	0
Armed For Apocalypse	38692	2022-05-12	0
Titán	38693	2022-05-12	0
Louis Slipperz	38694	2022-05-12	0
Parachute Band	38695	2022-05-12	0
Marni Nixon/John McCabe	38696	2022-05-12	0
Mick Farren And The Deviants	38697	2022-05-12	0
Fixx	38698	2022-05-12	0
Mike Vax	38699	2022-05-12	0
Talita Kum	38700	2022-05-12	0
Wendy Matthews	38701	2022-05-12	0
Preach	38702	2022-05-12	0
Throw The Fight	38703	2022-05-12	0
Triangulo	38704	2022-05-12	0
En Vogue	38705	2022-05-12	0
Roomsa featuring Lady Sarah	38706	2022-05-12	0
Cock Robin	38707	2022-05-12	0
DJ Antoine vs Mad Mark	38708	2022-05-12	0
FFH	38709	2022-05-12	0
Mary Black	38710	2022-05-12	0
Disillusion	38711	2022-05-12	0
Report Suspicious Activity	38712	2022-05-12	0
Mystic Revelation of Rastafari	38713	2022-05-12	0
Lightflow	38714	2022-05-12	0
Sebastian Davidson	38715	2022-05-12	0
Hallelujah the Hills	38716	2022-05-12	0
Kenny Rogers	38717	2022-05-12	0
DAN SEALS	38718	2022-05-12	0
iio	38719	2022-05-12	0
Katie Armiger	38720	2022-05-12	0
Obus	38721	2022-05-12	0
Judy Collins and Eric Andersen	38722	2022-05-12	0
Dusminguet	38723	2022-05-12	0
Hugues Aufray	38724	2022-05-12	0
Fela Kuti	38725	2022-05-12	0
Shugo Tokumaru	38726	2022-05-12	0
Ottmar Liebert	38727	2022-05-12	0
The Pan I Am	38728	2022-05-12	0
Hawaii Samurai	38729	2022-05-12	0
Thought Riot	38730	2022-05-12	0
Amy Mastura	38731	2022-05-12	0
Shakin' Stevens	38732	2022-05-12	0
Dusted	38733	2022-05-12	0
Worm Is Green	38734	2022-05-12	0
Hello Saferide	38735	2022-05-12	0
My Spacecoaster	38736	2022-05-12	0
Edi Fitzroy	38737	2022-05-12	0
Ms. Dynamite	38738	2022-05-12	0
Andrei Gavrilov	38739	2022-05-12	0
Transmotion	38740	2022-05-12	0
Better Than Ezra	38741	2022-05-12	0
The Foundation	38742	2022-05-12	0
Elizete Cardoso	38743	2022-05-12	0
Stephanie Marano	38744	2022-05-12	0
DYCR	38745	2022-05-12	0
Thelonious Monk Quartet	38746	2022-05-12	0
Oztara	38747	2022-05-12	0
Njie	38748	2022-05-12	0
The Hush Sound	38749	2022-05-12	0
Alex Chilton	38750	2022-05-12	0
Outputmessage	38751	2022-05-12	0
Barry Louis Polisar	38752	2022-05-12	0
Audio Bullys	38753	2022-05-12	0
Kultiration	38754	2022-05-12	0
Lorena / Sergio Rivero	38755	2022-05-12	0
Career Suicide	38756	2022-05-12	0
Daddy Screw	38757	2022-05-12	0
Mark-Henning	38758	2022-05-12	0
Olga Tañon	38759	2022-05-12	0
Citizens Here and Abroad	38760	2022-05-12	0
K.C. Accidental	38761	2022-05-12	0
Alibi Montana	38762	2022-05-12	0
Bottom Line	38763	2022-05-12	0
Rupee	38764	2022-05-12	0
Sonny Terry / Brownie McGhee	38765	2022-05-12	0
Grupo Mamey	38766	2022-05-12	0
Madd Anju & Kiprich	38767	2022-05-12	0
The Mighty Diamonds	38768	2022-05-12	0
Wayne Marshall	38769	2022-05-12	0
Headnodic	38770	2022-05-12	0
Antigama	38771	2022-05-12	0
TV Rock Feat. Seany B	38772	2022-05-12	0
Graham Nash	38773	2022-05-12	0
Narco	38774	2022-05-12	0
Charlie Christian	38775	2022-05-12	0
Royal Liverpool Philharmonic Orchestra_ Douglas Bostock	38776	2022-05-12	0
Snoop Dogg Featuring Goldie Loc	38777	2022-05-12	0
Frank Chacksfield And His Orchestra	38778	2022-05-12	0
Season To Risk	38779	2022-05-12	0
Kate McGarry	38780	2022-05-12	0
The Mojomatics	38781	2022-05-12	0
Crosby & Nash	38782	2022-05-12	0
Resonate	38783	2022-05-12	0
Dinu Lipatti_ Orchestre de la Suisse Romande_ Ernest Ansermet	38784	2022-05-12	0
Stress / Xavier Naidoo	38785	2022-05-12	0
Mari Boine	38786	2022-05-12	0
One Way	38787	2022-05-12	0
Fitness Forever	38788	2022-05-12	0
Dells	38789	2022-05-12	0
The Seekers	38790	2022-05-12	0
The Reason	38791	2022-05-12	0
Franck Roger	38792	2022-05-12	0
The Bobby McGee's	38793	2022-05-12	0
4ft Fingers	38794	2022-05-12	0
Darlene Love	38795	2022-05-12	0
Raccoon / The Teeth	38796	2022-05-12	0
Kid Koala	38797	2022-05-12	0
Kula Shaker	38798	2022-05-12	0
Davenport	38799	2022-05-12	0
Marty Robbins	38800	2022-05-12	0
Jim Chappell	38801	2022-05-12	0
Sani	38802	2022-05-12	0
Kaipa	38803	2022-05-12	0
Tshala Muana	38804	2022-05-12	0
Travis	38805	2022-05-12	0
Willie Dixon / Memphis Slim	38806	2022-05-12	0
Fishbone's Angelo Moore	38807	2022-05-12	0
Utopia	38808	2022-05-12	0
Leroy Van Dyke	38809	2022-05-12	0
Would-Be-Goods	38810	2022-05-12	0
Debi Makhsoospuri	38811	2022-05-12	0
George Carlin	38812	2022-05-12	0
Sergio Contreras	38813	2022-05-12	0
1 Giant Leap feat. Robbie Wlliams & Maxi Jazz	38814	2022-05-12	0
New-Orleans Rhythm Kings	38815	2022-05-12	0
Dirty Birdy	38816	2022-05-12	0
Luigi Alva/Orchestra del Teatro alla Scala_ Milano/Tullio Serafin	38817	2022-05-12	0
Broning	38819	2022-05-12	0
54 Seconds	38820	2022-05-12	0
Sven-Bertil Taube	38821	2022-05-12	0
Judy Henske	38822	2022-05-12	0
Mundy	38823	2022-05-12	0
Micky Modelle v Jessy	38824	2022-05-12	0
Lonely Drifter Karen	38825	2022-05-12	0
Sycronomica	38826	2022-05-12	0
Parlour Steps	38827	2022-05-12	0
Allister	38828	2022-05-12	0
Palace Of Oranges	38829	2022-05-12	0
Hank Penny	38830	2022-05-12	0
Bubba Sparxxx / Ryan Tedder	38831	2022-05-12	0
Coffinberry	38832	2022-05-12	0
Rick Cua	38833	2022-05-12	0
Bob Hund	38834	2022-05-12	0
Ray Sandoval	38835	2022-05-12	0
Christian Fennesz	38836	2022-05-12	0
Panik & Molemen	38837	2022-05-12	0
Ilario Alicante	38838	2022-05-12	0
Being 747	38839	2022-05-12	0
Richgirl	38840	2022-05-12	0
Dusty Rhodes and the River Band	38841	2022-05-12	0
Triona Ní Dhomhnaill	38842	2022-05-12	0
Girltalk	38843	2022-05-12	0
Sonia Dersion	38844	2022-05-12	0
Chris Kenner	38845	2022-05-12	0
El DeBarge	38846	2022-05-12	0
Seventh Day Slumber	38847	2022-05-12	0
Windir	38848	2022-05-12	0
The Roches	38849	2022-05-12	0
Beth Orton	38850	2022-05-12	0
Christian Marclay	38851	2022-05-12	0
Webster / Meyer	38852	2022-05-12	0
León Gieco/Pete Seeger	38853	2022-05-12	0
Dave Holland_ Steve Coleman_ Julian Priester_ Marvin Smitty Smith_ Kenny Wheeler	38854	2022-05-12	0
Derek Webb	38855	2022-05-12	0
Pig Destroyer	38856	2022-05-12	0
Marilyn Monroe	38857	2022-05-12	0
Myslovitz	38858	2022-05-12	0
Tragedy	38859	2022-05-12	0
Ferrante And Teicher	38860	2022-05-12	0
Cajjmere Wray	38861	2022-05-12	0
Caifanes	38862	2022-05-12	0
Freakhouse	38863	2022-05-12	0
Hanna Pakarinen	38864	2022-05-12	0
Sway feat. Akon	38865	2022-05-12	0
I Am Kloot	38866	2022-05-12	0
Kenny Larkin	38867	2022-05-12	0
Minsk	38868	2022-05-12	0
Keith Carradine	38869	2022-05-12	0
Labelle (featuring Patti Labelle)	38870	2022-05-12	0
Paul Rodgers	38871	2022-05-12	0
Barbara Cook_ Robert Preston	38872	2022-05-12	0
Laleh	38873	2022-05-12	0
Esma Redzepova and Usnija Jasarova	38874	2022-05-12	0
Pleymo	38875	2022-05-12	0
The Rubettes	38876	2022-05-12	0
Hammers of Misfortune	38877	2022-05-12	0
Backstreet Boys	38878	2022-05-12	0
Angra Mainyu	38879	2022-05-12	0
Mae	38880	2022-05-12	0
Oliver Kalkofe	38881	2022-05-12	0
The Enemy	38882	2022-05-12	0
Mombojó	38883	2022-05-12	0
Pál Utcai Fiúk	38884	2022-05-12	0
Irigy Honaljmirigy	38885	2022-05-12	0
John Stewart	38886	2022-05-12	0
8Ball & MJG	38887	2022-05-12	0
Jelly Roll Morton's Hot Seven	38888	2022-05-12	0
Santiago Auserón_ DAGOLL DAGOM	38889	2022-05-12	0
Crazy	38890	2022-05-12	0
Count Basic	38891	2022-05-12	0
Trent Willmon	38892	2022-05-12	0
The Oak Ridge Boys	38893	2022-05-12	0
Shock	38894	2022-05-12	0
Frank Sinatra Jr.	38895	2022-05-12	0
Andy Caldwell	38896	2022-05-12	0
Lauren Wagner & Fred Weldy	38897	2022-05-12	0
Dan Bern	38898	2022-05-12	0
Papa Brittle	38899	2022-05-12	0
Figures On A Beach	38900	2022-05-12	0
Super Numeri	38901	2022-05-12	0
Boris Gardiner	38902	2022-05-12	0
TCP	38903	2022-05-12	0
Betül Demir	38904	2022-05-12	0
Tony Sly	38905	2022-05-12	0
Dj Kali	38906	2022-05-12	0
Airbourne	38907	2022-05-12	0
Chris Joss	38908	2022-05-12	0
Poison Idea	38909	2022-05-12	0
PENNY TAI	38910	2022-05-12	0
Thea Musgrave	38911	2022-05-12	0
Superpunk	38912	2022-05-12	0
The Inchtabokatables	38913	2022-05-12	0
Nick Jonas & The Administration	38914	2022-05-12	0
Hinge & Bracket	38915	2022-05-12	0
The Orioles	38916	2022-05-12	0
Alexander Xendzov feat. Julie-Anne Melfi	38917	2022-05-12	0
Von Iva	38918	2022-05-12	0
Robbie Basho	38919	2022-05-12	0
Xasthur	38920	2022-05-12	0
Nick Cave & Warren Ellis	38921	2022-05-12	0
Shakedown	38922	2022-05-12	0
Kotebel	38923	2022-05-12	0
DJ Chick	38924	2022-05-12	0
Gaute Ormåsen	38925	2022-05-12	0
Lara	38926	2022-05-12	0
Sarah Brightman & José Carreras	38927	2022-05-12	0
John Renbourn	38928	2022-05-12	0
Wes Montgomery	38929	2022-05-12	0
Warbringer	38930	2022-05-12	0
Jamie Ritmen	38931	2022-05-12	0
New Grenada	38932	2022-05-12	0
Boo Boo Davis	38933	2022-05-12	0
The Teddy Bears	38934	2022-05-12	0
Anathallo	38935	2022-05-12	0
Adema	38936	2022-05-12	0
Linea 77	38937	2022-05-12	0
Octave One	38938	2022-05-12	0
Jim White	38939	2022-05-12	0
Earthworms	38940	2022-05-12	0
Giusy Ferreri feat. Tiziano Ferro	38941	2022-05-12	0
Bruce Rowland	38942	2022-05-12	0
Warren Smith	38943	2022-05-12	0
Gaetano Donizetti	38944	2022-05-12	0
Laura Flores	38945	2022-05-12	0
Capgun Coup	38946	2022-05-12	0
Disco Superstars feat. Inusa Dawuda	38947	2022-05-12	0
La Phaze	38948	2022-05-12	0
Umlaut	38949	2022-05-12	0
Huguette Tourangeau / Orchestre Symphonique de Montréal / Charles Dutoit	38950	2022-05-12	0
MORS PRINCIPIUM EST	38951	2022-05-12	0
Dead Prez	38952	2022-05-12	0
Dorival Caymmi	38953	2022-05-12	0
The Wild Swans	38954	2022-05-12	0
Cataract	38955	2022-05-12	0
The Headless Horsemen	38956	2022-05-12	0
Beloved	38957	2022-05-12	0
The Dwarf Chorus	38958	2022-05-12	0
Talc	38959	2022-05-12	0
Stacey Q	38960	2022-05-12	0
Jeremy Warmsley	38961	2022-05-12	0
Los Palominos	38962	2022-05-12	0
Reconceal	38963	2022-05-12	0
Colossal Yes	38964	2022-05-12	0
Pentangle	38965	2022-05-12	0
Curiosity Killed The Cat	38966	2022-05-12	0
Splack Pack	38967	2022-05-12	0
Nikki	38968	2022-05-12	0
Jim Bob	38969	2022-05-12	0
Jim Starck	38970	2022-05-12	0
Grant Geissman	38971	2022-05-12	0
Trin-I-Tee 5:7	38972	2022-05-12	0
Toni Kater	38973	2022-05-12	0
Cheb Hasni	38974	2022-05-12	0
Talisman	38975	2022-05-12	0
Irradio	38976	2022-05-12	0
No Use For A Name	38977	2022-05-12	0
David Jacobs-Strain	38978	2022-05-12	0
Liars	38979	2022-05-12	0
The Stranglers	38980	2022-05-12	0
Frost	38981	2022-05-12	0
Mara Carlyle	38982	2022-05-12	0
Jon Hassell_ J.A Deane_ Jean-Philippe Rykiel_ Michael Brook	38983	2022-05-12	0
Dropline	38984	2022-05-12	0
Gerry & The Pacemakers	38985	2022-05-12	0
Prince	38986	2022-05-12	0
Alabama	38987	2022-05-12	0
Holy Ghost Revival	38988	2022-05-12	0
Grupo Los_ Amigos	38989	2022-05-12	0
Jeniferever	38990	2022-05-12	0
Fun Lovin' Criminals	38991	2022-05-12	0
Cisko Brothers	38992	2022-05-12	0
Kiss Kiss	38993	2022-05-12	0
DUNCAN SHEIK	38994	2022-05-12	0
Maxwell	38995	2022-05-12	0
Artie Shaw and his orchestra	38996	2022-05-12	0
Quatuor Danel	38997	2022-05-12	0
Household Names	38998	2022-05-12	0
Jellybass feat. Brother Culture	38999	2022-05-12	0
Carolyn Arends	39000	2022-05-12	0
Boz Scaggs	39001	2022-05-12	0
Carol Duboc	39002	2022-05-12	0
Stela Konitopoulou	39003	2022-05-12	0
Udo	39004	2022-05-12	0
Andy & Lucas	39005	2022-05-12	0
Ariel Pink's Haunted Graffiti	39006	2022-05-12	0
Dick Jacobs	39007	2022-05-12	0
Dennis Alcapone	39008	2022-05-12	0
Diefenbach	39009	2022-05-12	0
Margie Joseph	39010	2022-05-12	0
Revolting Cocks	39011	2022-05-12	0
Pulser	39012	2022-05-12	0
Archive	39013	2022-05-12	0
Vusi Mahlasela	39014	2022-05-12	0
ISRAEL & NEW BREED	39015	2022-05-12	0
Dr. Elmo	39016	2022-05-12	0
Jessica Folcker	39017	2022-05-12	0
Jorge Alfano	39018	2022-05-12	0
Tristan Garner	39019	2022-05-12	0
Cab Calloway	39020	2022-05-12	0
Der Plan	39021	2022-05-12	0
Wave Machines	39022	2022-05-12	0
Rusty Bryant	39023	2022-05-12	0
Triana Pura	39024	2022-05-12	0
MRK 1	39025	2022-05-12	0
Tommy Körberg	39026	2022-05-12	0
Adriano Pappalardo	39027	2022-05-12	0
Julie Peel	39028	2022-05-12	0
Georgia Anne Muldrow	39029	2022-05-12	0
Terry Jacks	39030	2022-05-12	0
Prince & The New Power Generation	39031	2022-05-12	0
Frankie Lee	39032	2022-05-12	0
Snowgoons	39033	2022-05-12	0
Sven Wittekind	39034	2022-05-12	0
Cheap Thrills	39035	2022-05-12	0
Cannonball Adderley	39036	2022-05-12	0
Askil Holm	39037	2022-05-12	0
Jose Cepero	39038	2022-05-12	0
Piotta	39039	2022-05-12	0
Laura Leon	39040	2022-05-12	0
Michael Stanley Band	39041	2022-05-12	0
Cartola	39042	2022-05-12	0
Hard Skin	39043	2022-05-12	0
Tommy Bolin	39044	2022-05-12	0
The Creepshow	39045	2022-05-12	0
Colin Gilmore	39046	2022-05-12	0
Z-Trip	39047	2022-05-12	0
Sami Yusuf	39048	2022-05-12	0
DJ Jean	39049	2022-05-12	0
Randy Graff / Robert Billig	39050	2022-05-12	0
Miguel Mateos Zas	39051	2022-05-12	0
Youssoupha	39052	2022-05-12	0
Bobby Taylor / The Vancouvers	39053	2022-05-12	0
O.A.R.	39054	2022-05-12	0
Dying Passion	39055	2022-05-12	0
Peter Wackel	39056	2022-05-12	0
Chuck Prophet	39057	2022-05-12	0
Richard Dyer-Bennet	39058	2022-05-12	0
Sixtoo	39059	2022-05-12	0
Kiko Navarro feat. Concha Buika	39060	2022-05-12	0
Junia Walker	39061	2022-05-12	0
Cquence	39062	2022-05-12	0
Karma	39063	2022-05-12	0
These Immortal Souls	39064	2022-05-12	0
Doreen Shaffer	39065	2022-05-12	0
Galt MacDermot;Tom Pierson	39066	2022-05-12	0
Frontline Assembly	39067	2022-05-12	0
Linkwood	39068	2022-05-12	0
Mental Overdrive featuring Anneli Drecker	39069	2022-05-12	0
Youth Group	39070	2022-05-12	0
Toxic Anger Syndrome	39071	2022-05-12	0
Don Drummond	39072	2022-05-12	0
Bahiano	39073	2022-05-12	0
Nancy Walker	39074	2022-05-12	0
Sangiuliano	39075	2022-05-12	0
Palo Alto	39076	2022-05-12	0
Tim O'brien	39077	2022-05-12	0
Transbeauce	39078	2022-05-12	0
Cameos	39079	2022-05-12	0
Julie Delpy	39080	2022-05-12	0
Stan Webb's Chicken Shack	39081	2022-05-12	0
Baby Mammoth	39082	2022-05-12	0
Spiderbait	39083	2022-05-12	0
Fly My Pretties	39084	2022-05-12	0
Ahmad Jamal	39085	2022-05-12	0
Mia Martini	39086	2022-05-12	0
Neil Diamond	39087	2022-05-12	0
Third Day/Steven Curtis Chapman/Mercy Me	39088	2022-05-12	0
Michael W. Smith	39089	2022-05-12	0
Sugababes	39090	2022-05-12	0
Larry The Cable Guy	39091	2022-05-12	0
Inspiral Carpets	39092	2022-05-12	0
The SlimP	39093	2022-05-12	0
Binary Star	39094	2022-05-12	0
Fredrika Stahl	39095	2022-05-12	0
3 Inches Of Blood	39096	2022-05-12	0
Carl Davis;Janice Watson;Ruby Philogene	39097	2022-05-12	0
Najoua Belyzel	39098	2022-05-12	0
Ijahman Levi	39099	2022-05-12	0
Butch & Amir	39100	2022-05-12	0
Anthony Red Rose	39101	2022-05-12	0
Rotary Connection	39102	2022-05-12	0
Candy Lo	39103	2022-05-12	0
Pat Farrell featuring Patrick Miller	39104	2022-05-12	0
Moonspell	39105	2022-05-12	0
Don Nix	39106	2022-05-12	0
Frankie	39107	2022-05-12	0
Lagwagon	39108	2022-05-12	0
Marie-Lynn Hammond	39109	2022-05-12	0
Judy Mowatt	39110	2022-05-12	0
Bob Azzam	39111	2022-05-12	0
Ustad Sultan Khan	39112	2022-05-12	0
The Gaylads	39113	2022-05-12	0
Mona Mur	39114	2022-05-12	0
Nicolas Bacchus	39115	2022-05-12	0
Mustan Kuun Lapset	39116	2022-05-12	0
Clawfinger	39117	2022-05-12	0
Goofy (Feat. Gold Voice & QT)	39118	2022-05-12	0
Saigon Hookers	39119	2022-05-12	0
4Him	39120	2022-05-12	0
Richard Swift	39121	2022-05-12	0
Earthbound	39122	2022-05-12	0
Jumprope	39123	2022-05-12	0
Nouvelle Vague	39124	2022-05-12	0
Oliver N'Goma	39125	2022-05-12	0
M.I.A.	39126	2022-05-12	0
Portugal. The Man	39127	2022-05-12	0
Helstar	39128	2022-05-12	0
Moodswings;Chrissie Hynde	39129	2022-05-12	0
P Money	39130	2022-05-12	0
King Sunny Ade	39131	2022-05-12	0
Russ Taff	39132	2022-05-12	0
Mithotyn	39133	2022-05-12	0
Big Youth / Leroy Smart	39134	2022-05-12	0
12 Stones	39135	2022-05-12	0
Bryn Terfel / Miah Persson / Scottish Chamber Orchestra / Sir Charles Mackerras	39136	2022-05-12	0
Gutter Twins	39137	2022-05-12	0
Mala	39138	2022-05-12	0
Lluis Llach	39139	2022-05-12	0
The Teardrop Explodes	39140	2022-05-12	0
Babs Gonzales	39141	2022-05-12	0
Visions	39142	2022-05-12	0
Soda Inc.	39143	2022-05-12	0
Jovanotti	39144	2022-05-12	0
Charles Mingus	39145	2022-05-12	0
Green On Red	39146	2022-05-12	0
Luc Skyz	39147	2022-05-12	0
Ojos De Brujo	39148	2022-05-12	0
TIN TIN OUT FEATURING EMMA BUNTON	39149	2022-05-12	0
The Juliana Theory	39150	2022-05-12	0
SoundLift	39151	2022-05-12	0
Absinthe Glow	39152	2022-05-12	0
Pornopop	39153	2022-05-12	0
Lisa Brokop	39154	2022-05-12	0
Gina X Performance	39155	2022-05-12	0
The Mary Timony Band	39156	2022-05-12	0
Ashanti	39157	2022-05-12	0
Garrison Keillor	39158	2022-05-12	0
The Maytals	39159	2022-05-12	0
KC & The Sunshine Band	39160	2022-05-12	0
Ariel Rot	39161	2022-05-12	0
Cadet	39162	2022-05-12	0
Leona Naess	39163	2022-05-12	0
Bronze	39164	2022-05-12	0
W.A.S.P.	39165	2022-05-12	0
Plastilina Mosh	39166	2022-05-12	0
New Duncan Imperials	39167	2022-05-12	0
Chuck Mangione	39168	2022-05-12	0
Union Wireless	39169	2022-05-12	0
Ammer Einheit	39170	2022-05-12	0
Oliver Koletzki feat. Juli Holz	39171	2022-05-12	0
The Kyle Bennett Band	39172	2022-05-12	0
Scienz of Life	39173	2022-05-12	0
Joe Arroyo Y La Verdad	39174	2022-05-12	0
John Brown\\'s Body	39175	2022-05-12	0
Liquido	39176	2022-05-12	0
Jimmie Lunceford & His Orchestra	39177	2022-05-12	0
Havana 3 A.M.	39178	2022-05-12	0
Horslips	39179	2022-05-12	0
Lucienne Delyle	39180	2022-05-12	0
Agoria Feat. Villeneuve	39181	2022-05-12	0
David Banner / Freakzanatcha	39182	2022-05-12	0
Chiara Civello	39183	2022-05-12	0
Jam & Spoon ft. Rea	39184	2022-05-12	0
Simple / Raw-B / Fabster	39185	2022-05-12	0
Jesus Cifuentes	39186	2022-05-12	0
Captain Everything!	39187	2022-05-12	0
Les Malpolis	39188	2022-05-12	0
Abby	39189	2022-05-12	0
The Cardinals	39190	2022-05-12	0
Sash!	39191	2022-05-12	0
Jean Grae	39192	2022-05-12	0
Little Man Tate	39193	2022-05-12	0
Cutting Edge	39194	2022-05-12	0
Luton Fyah	39195	2022-05-12	0
Kenny G with Peabo Bryson	39196	2022-05-12	0
Samsas Traum	39197	2022-05-12	0
Sir Thomas Beecham;Jennifer Vyvyan	39198	2022-05-12	0
Johnny Ace / The Johnny Otis Band	39199	2022-05-12	0
BLEED THE SKY	39200	2022-05-12	0
DJ Billy E	39201	2022-05-12	0
Great White	39202	2022-05-12	0
Love Shop	39203	2022-05-12	0
Sally Shapiro	39204	2022-05-12	0
Beck_ Bogert_ Appice	39205	2022-05-12	0
Jehst	39206	2022-05-12	0
Extrabreit	39207	2022-05-12	0
flying virgins	39208	2022-05-12	0
Evangelicals	39209	2022-05-12	0
Mariachi Arriba Juárez	39210	2022-05-12	0
NTM	39211	2022-05-12	0
Megapolis	39212	2022-05-12	0
Chus_ Ceballos	39213	2022-05-12	0
K-Mob	39214	2022-05-12	0
Maria Mena	39215	2022-05-12	0
The Makers	39216	2022-05-12	0
Steven Halpern	39217	2022-05-12	0
Le Volume Était Au Maximum	39218	2022-05-12	0
Mr. Shadow	39219	2022-05-12	0
Stonewall Jackson and Super Friends	39220	2022-05-12	0
Lola Ponce	39221	2022-05-12	0
Mr. Easy	39222	2022-05-12	0
Audioscape & Kelly C	39223	2022-05-12	0
Steven Curtis Chapman	39224	2022-05-12	0
Will Atkinson	39225	2022-05-12	0
Mihalis Safras	39226	2022-05-12	0
The Rance Allen Group	39227	2022-05-12	0
Frankie Sparo	39228	2022-05-12	0
Debate	39229	2022-05-12	0
Zimbo Trio	39230	2022-05-12	0
Chicago House Syndicate	39231	2022-05-12	0
Majai	39232	2022-05-12	0
Honeybrowne	39233	2022-05-12	0
Haze	39234	2022-05-12	0
Gary Smith	39235	2022-05-12	0
Barbara Tucker	39236	2022-05-12	0
Clem Snide	39237	2022-05-12	0
Limbeck	39238	2022-05-12	0
Brutal Truth	39239	2022-05-12	0
Phutureprimitive_ Alyssa Palmer	39240	2022-05-12	0
Spiral Beach	39241	2022-05-12	0
DJ Myde	39242	2022-05-12	0
Jupiter Jones	39243	2022-05-12	0
Screamfeeder	39244	2022-05-12	0
Happy Apple	39245	2022-05-12	0
Non Prophets	39246	2022-05-12	0
Jessie Hill	39247	2022-05-12	0
Basslovers United	39248	2022-05-12	0
SK8	39249	2022-05-12	0
Skin	39250	2022-05-12	0
Brian Culbertson (Featuring Steve Cole)	39251	2022-05-12	0
So They Say	39252	2022-05-12	0
Napalm Death	39253	2022-05-12	0
Dmitry Fyodorov	39254	2022-05-12	0
Kia Shine	39255	2022-05-12	0
Jagged Edge featuring Jermaine Dupri_ Da Brat_ R.O.C._ Lil Bow Wow and Tigah	39256	2022-05-12	0
Paralysed Age	39257	2022-05-12	0
Fort Minor (Featuring Celph Titled)	39258	2022-05-12	0
Bill Nelson	39259	2022-05-12	0
Julius Papp	39260	2022-05-12	0
Mound City Blue Blowers	39261	2022-05-12	0
Demonbreed	39262	2022-05-12	0
Dante Thomas feat. Fo-Jo	39263	2022-05-12	0
Boozoo Chavis	39264	2022-05-12	0
Decerto	39265	2022-05-12	0
Sister Carol	39266	2022-05-12	0
Brazilian Tropical Orchestra	39267	2022-05-12	0
Moneen	39268	2022-05-12	0
Evil Nine	39269	2022-05-12	0
Ninjaman (feat. Ninja Ford)	39270	2022-05-12	0
Shy FX	39271	2022-05-12	0
Monstrosity	39272	2022-05-12	0
Dallas	39273	2022-05-12	0
Hella Donna	39274	2022-05-12	0
Motörhead	39275	2022-05-12	0
Melys	39276	2022-05-12	0
TO/DIE/FOR	39277	2022-05-12	0
Heróis Do Mar	39278	2022-05-12	0
Days Of The New	39279	2022-05-12	0
Sniper	39280	2022-05-12	0
Mike Marshall & Chris Thile	39281	2022-05-12	0
Sound Barrier	39282	2022-05-12	0
The Real Thing / The Real Thing	39283	2022-05-12	0
Digitonal	39284	2022-05-12	0
Hadag Nachash	39285	2022-05-12	0
Raccomandata Ricevuta Ritorno	39286	2022-05-12	0
Astrud Gilberto	39287	2022-05-12	0
Nevertheless	39288	2022-05-12	0
Tijuana No!	39289	2022-05-12	0
Joélle Leandre	39290	2022-05-12	0
Bap	39291	2022-05-12	0
The Sushi Club	39292	2022-05-12	0
Joe Lynn Turner	39293	2022-05-12	0
Magdi Rúzsa	39294	2022-05-12	0
Scritti Politti	39295	2022-05-12	0
The Delmonas	39296	2022-05-12	0
Mccarthy Trenching	39297	2022-05-12	0
JVOX	39298	2022-05-12	0
Original Broadway Cast	39299	2022-05-12	0
Stéphane Grappelli	39300	2022-05-12	0
Samon Kawamura	39301	2022-05-12	0
Huntingtons	39302	2022-05-12	0
Tim Van Eyken	39303	2022-05-12	0
Fanfare Savale	39304	2022-05-12	0
Rolfe Kent	39305	2022-05-12	0
Tego Calderon	39306	2022-05-12	0
B21	39307	2022-05-12	0
Joker's Daughter	39308	2022-05-12	0
Floyd Cramer	39309	2022-05-12	0
Sinéad O'Connor	39310	2022-05-12	0
Willie Dixon	39311	2022-05-12	0
Alton Miller	39312	2022-05-12	0
Nahki	39313	2022-05-12	0
Michael Prophet	39314	2022-05-12	0
Kailash Kher	39315	2022-05-12	0
Alex Fong	39316	2022-05-12	0
Mercy Fall	39317	2022-05-12	0
Vicious	39318	2022-05-12	0
A*Teens	39319	2022-05-12	0
Paul Baloche	39320	2022-05-12	0
Bloodbath	39321	2022-05-12	0
DJ Surgeon	39322	2022-05-12	0
Vacca	39323	2022-05-12	0
Kundalini Rising	39324	2022-05-12	0
John Schooley And His One Man Band	39325	2022-05-12	0
Seismic Anamoly	39326	2022-05-12	0
The Tamlins	39327	2022-05-12	0
Ian Van Dahl	39328	2022-05-12	0
Je Suis France	39329	2022-05-12	0
Peter Horrevorts	39330	2022-05-12	0
Variety Lab	39331	2022-05-12	0
Tony Sheridan & The Savage Young Beatles	39332	2022-05-12	0
Steve Hill	39333	2022-05-12	0
Splithabit	39334	2022-05-12	0
Anthony Malvo	39335	2022-05-12	0
The Octopus Project + Black Moth Super Rainbow	39336	2022-05-12	0
Comp	39337	2022-05-12	0
Grand palace	39338	2022-05-12	0
Doug Sahm	39339	2022-05-12	0
Howard Roberts	39340	2022-05-12	0
Kyau & Albert	39341	2022-05-12	0
Loriod Yvonne_Ensemble Intercontemporain_Olivier Messiaen_Pierre Boulez	39342	2022-05-12	0
Doris Monteiro	39343	2022-05-12	0
Cartel	39344	2022-05-12	0
Declan O'Rourke	39345	2022-05-12	0
Garrison Starr	39346	2022-05-12	0
The Contours	39347	2022-05-12	0
Art Pepper	39348	2022-05-12	0
Kinto Sol	39349	2022-05-12	0
Jive Five	39350	2022-05-12	0
J. Karjalainen Electric Sauna	39351	2022-05-12	0
Don Williams	39352	2022-05-12	0
Parni Valjak	39353	2022-05-12	0
Heart	39354	2022-05-12	0
Merle Haggard And The Strangers	39355	2022-05-12	0
Lawrence English	39356	2022-05-12	0
Larry Sparks	39357	2022-05-12	0
Cosmic Gate	39358	2022-05-12	0
Black N Blue	39359	2022-05-12	0
Aril Brikha	39360	2022-05-12	0
Fagget Fairys	39361	2022-05-12	0
Nik Bärtsch's Mobile	39362	2022-05-12	0
Rosario / La Mari	39363	2022-05-12	0
Sonic Surf City	39364	2022-05-12	0
Lacy Gibson	39365	2022-05-12	0
Jean Carlos Centeno	39366	2022-05-12	0
GG Allin	39367	2022-05-12	0
Willie Hutch	39368	2022-05-12	0
Marcella Detroit	39369	2022-05-12	0
Tom Paxton	39370	2022-05-12	0
Kylie Minogue	39371	2022-05-12	0
The Love X Nowhere	39372	2022-05-12	0
Sonar Kollektiv Orchester	39373	2022-05-12	0
Bigod 20	39374	2022-05-12	0
The Devil Wears Prada	39375	2022-05-12	0
Los Gigantes Del Vallenato	39376	2022-05-12	0
Nick Lachey	39377	2022-05-12	0
The Panoply Academy	39378	2022-05-12	0
BT feat. Erire	39379	2022-05-12	0
Roger Eno	39380	2022-05-12	0
Kevin Costner / The Modern West	39381	2022-05-12	0
Monsters of Liedermaching	39382	2022-05-12	0
Hardfloor	39383	2022-05-12	0
Twinkie Clark	39384	2022-05-12	0
Hide The Knives	39385	2022-05-12	0
Shanty	39386	2022-05-12	0
Été 67	39387	2022-05-12	0
Claire Hamill	39388	2022-05-12	0
The Golden Palominos	39389	2022-05-12	0
Redbong	39390	2022-05-12	0
Roger Clyne & The Peacemakers	39391	2022-05-12	0
End Of Everything	39392	2022-05-12	0
Boogie Times Tribe	39393	2022-05-12	0
Earth	39394	2022-05-12	0
The Beat	39395	2022-05-12	0
Comfort Class	39396	2022-05-12	0
Massive Töne	39397	2022-05-12	0
RBL Posse	39398	2022-05-12	0
Mother Mother	39399	2022-05-12	0
Small Sins	39400	2022-05-12	0
David Byrne & Fatboy Slim feat. Theresa Andersson	39401	2022-05-12	0
Iain Archer	39402	2022-05-12	0
Ark	39403	2022-05-12	0
San Quinn & Messy Marve Ft Dewayne Wiggins	39404	2022-05-12	0
Warren G	39405	2022-05-12	0
Wretch 32	39406	2022-05-12	0
Brs	39407	2022-05-12	0
June Tabor	39408	2022-05-12	0
Horace Silver Quintet	39409	2022-05-12	0
Deadsy	39410	2022-05-12	0
Oxide And Neutrino	39411	2022-05-12	0
Zoxea	39412	2022-05-12	0
Pilar Montenegro	39413	2022-05-12	0
Shirley Kwan	39414	2022-05-12	0
Joe Jackson Band	39415	2022-05-12	0
Stephen Kellogg & The Sixers	39416	2022-05-12	0
Ostinato	39417	2022-05-12	0
The USA Is a Monster	39418	2022-05-12	0
Don Fardon	39419	2022-05-12	0
National Dust	39420	2022-05-12	0
Crusaders	39421	2022-05-12	0
Vickie Winans	39422	2022-05-12	0
Jesse Dayton & Brennen Leigh	39423	2022-05-12	0
Abba	39424	2022-05-12	0
Clipse	39425	2022-05-12	0
Jullie_ Jullie	39426	2022-05-12	0
The Lord Dog Bird	39427	2022-05-12	0
Relax	39428	2022-05-12	0
Monty Alexander	39429	2022-05-12	0
Kam Moye aka Supastition	39430	2022-05-12	0
Lena	39431	2022-05-12	0
Gods Property	39432	2022-05-12	0
Rocker-T	39433	2022-05-12	0
BT	39434	2022-05-12	0
Redshape	39435	2022-05-12	0
Kiri Te Kanawa	39436	2022-05-12	0
Franky Tunes	39437	2022-05-12	0
DJ Remy	39438	2022-05-12	0
Steve Hill vs Hardforze	39439	2022-05-12	0
Cosima	39440	2022-05-12	0
JR Writer	39441	2022-05-12	0
Clarika	39442	2022-05-12	0
Voodoo Church	39443	2022-05-12	0
Hopalong Knut	39444	2022-05-12	0
Yordanka Hristova	39445	2022-05-12	0
Blue Meanies	39446	2022-05-12	0
Anna Tatangelo	39447	2022-05-12	0
Andy Abraham	39448	2022-05-12	0
Marco V	39449	2022-05-12	0
Brian M vs. McBunn	39450	2022-05-12	0
Ray Bryant	39451	2022-05-12	0
Mj	39452	2022-05-12	0
Miguel Migs	39453	2022-05-12	0
Bernward Koch	39454	2022-05-12	0
Pierre Henry / Spooky Tooth	39455	2022-05-12	0
Slipknot	39456	2022-05-12	0
John Hiatt	39457	2022-05-12	0
Hixxy / Technikore	39458	2022-05-12	0
Alborosie [feat. David Hinds]	39459	2022-05-12	0
Cannibal Cooking Club	39460	2022-05-12	0
Öris & Ågren	39461	2022-05-12	0
Eros Ramazzotti	39462	2022-05-12	0
Luca Antolini Dj	39463	2022-05-12	0
Marc Live	39464	2022-05-12	0
Tommy Sands	39465	2022-05-12	0
Max Melvin	39466	2022-05-12	0
Gerard Lenorman	39467	2022-05-12	0
Justice	39468	2022-05-12	0
The Clutters	39469	2022-05-12	0
Infinity & Meander	39470	2022-05-12	0
Laakso	39471	2022-05-12	0
K-Klass	39472	2022-05-12	0
Florian Silbereisen	39473	2022-05-12	0
Dina Carroll	39474	2022-05-12	0
Dave Aude	39475	2022-05-12	0
Mariachi Los Caporales	39476	2022-05-12	0
The Troggs	39477	2022-05-12	0
Breach of Trust	39478	2022-05-12	0
Ludovico Einaudi	39479	2022-05-12	0
Edwin McCain	39480	2022-05-12	0
The Scene	39481	2022-05-12	0
Son Of A Plumber	39482	2022-05-12	0
Alan Jackson	39483	2022-05-12	0
Alejandro Lerner	39484	2022-05-12	0
Strapping Young Lad	39485	2022-05-12	0
Lourds	39486	2022-05-12	0
Syrian	39487	2022-05-12	0
The Wedding	39488	2022-05-12	0
Sean T	39489	2022-05-12	0
The Animals	39490	2022-05-12	0
Between The Buried And Me	39491	2022-05-12	0
Teenage Fanclub	39492	2022-05-12	0
Bjørn Eidsvåg	39493	2022-05-12	0
The B-52's	39494	2022-05-12	0
Kelly Chen	39495	2022-05-12	0
Jesus On Extasy	39496	2022-05-12	0
Jamie Dee	39497	2022-05-12	0
Trang Fødsel	39498	2022-05-12	0
Steel Pulse	39499	2022-05-12	0
Laura Branigan	39500	2022-05-12	0
Ted Hawkins	39501	2022-05-12	0
Dc La Rue	39502	2022-05-12	0
From Monument To Masses	39503	2022-05-12	0
Safi Connection	39504	2022-05-12	0
Lee Morgan	39505	2022-05-12	0
Anthony Hamilton featuring LaToiya Williams	39506	2022-05-12	0
Mokoma	39507	2022-05-12	0
Maximo Park	39508	2022-05-12	0
Max Corbacho	39509	2022-05-12	0
Judy Cheeks	39510	2022-05-12	0
Kenny Wayne Shepherd	39511	2022-05-12	0
Tammy Wynette;George Jones;George Jones & Tammy Wynette	39512	2022-05-12	0
Wooden Wand And The Vanishing Voice	39513	2022-05-12	0
Cyril Pahinui	39514	2022-05-12	0
Inward Eye	39515	2022-05-12	0
Dr. Maya	39516	2022-05-12	0
Kirsty Lee Akers	39517	2022-05-12	0
Grayskul	39518	2022-05-12	0
Michael Stanley	39519	2022-05-12	0
Sofia Karlsson	39520	2022-05-12	0
Funky Chicos	39521	2022-05-12	0
Virginia Coalition	39522	2022-05-12	0
Ali Farka Toure_ Ry Cooder	39523	2022-05-12	0
The Stanley Brothers	39524	2022-05-12	0
Savoy Brown	39525	2022-05-12	0
Beneath The Sky	39526	2022-05-12	0
Minimum Vital	39527	2022-05-12	0
Grant Lee Buffalo	39528	2022-05-12	0
Little Miss Higgins	39529	2022-05-12	0
Los Melódicos	39530	2022-05-12	0
Straight Flush	39531	2022-05-12	0
Drive-By Truckers	39532	2022-05-12	0
China Crisis	39533	2022-05-12	0
Merry Clayton	39534	2022-05-12	0
Drum Komputer	39535	2022-05-12	0
XTC	39536	2022-05-12	0
Carol Channing;Shepard Coleman	39537	2022-05-12	0
Messiah	39538	2022-05-12	0
Mr. Vegas	39539	2022-05-12	0
Gruf	39540	2022-05-12	0
Traveling Wilburys	39541	2022-05-12	0
Gianluca Molinari	39542	2022-05-12	0
Orange Sector	39543	2022-05-12	0
Floor	39544	2022-05-12	0
Laika and the Cosmonauts	39545	2022-05-12	0
The New Birth	39546	2022-05-12	0
Jean-François Coen	39547	2022-05-12	0
B Will & Infinit EVOL	39548	2022-05-12	0
Zola	39549	2022-05-12	0
Achim Reichel	39550	2022-05-12	0
WC	39551	2022-05-12	0
The Velvet Underground	39552	2022-05-12	0
Shuggie Otis	39553	2022-05-12	0
Matt Dusk	39554	2022-05-12	0
Cæcilie Nørby	39555	2022-05-12	0
FM Einheit	39556	2022-05-12	0
Zwan	39557	2022-05-12	0
Gammer	39558	2022-05-12	0
Lazy Rich	39559	2022-05-12	0
Dawn	39560	2022-05-12	0
Bypass Unit	39561	2022-05-12	0
The Mannish Boys	39562	2022-05-12	0
Hélio Ziskind	39563	2022-05-12	0
Holger Czukay	39564	2022-05-12	0
Bloodjinn	39565	2022-05-12	0
Lil 1/2 Dead	39566	2022-05-12	0
The Orchestra feat. Anders Trentemøller	39567	2022-05-12	0
Minnie Riperton	39568	2022-05-12	0
Glenn Miller & His Orchestra	39569	2022-05-12	0
Ian Dury	39570	2022-05-12	0
Begum Abida Parveen	39571	2022-05-12	0
Lasse Stefanz	39572	2022-05-12	0
Mc Guire Sisters	39573	2022-05-12	0
Rocket 350	39574	2022-05-12	0
Street Pharmacy	39575	2022-05-12	0
Porter Wagoner and Dolly Parton	39576	2022-05-12	0
Nicole	39577	2022-05-12	0
Dwight Yoakam	39578	2022-05-12	0
Jermaine Jackson	39579	2022-05-12	0
Wolfie	39580	2022-05-12	0
Seryoga	39581	2022-05-12	0
Giuliano Palma & The Bluebeaters	39582	2022-05-12	0
Snax	39583	2022-05-12	0
MYSA	39584	2022-05-12	0
Prince Jazzbo	39585	2022-05-12	0
Sidonie	39586	2022-05-12	0
Soziedad Alkoholika	39587	2022-05-12	0
The Lovethugs	39588	2022-05-12	0
Silvia Goes_ Ivâni Sabino & Pepa D'Elia	39589	2022-05-12	0
Morgana King	39590	2022-05-12	0
White Belt Yellow Tag	39591	2022-05-12	0
50 Cent / Ne-Yo	39592	2022-05-12	0
Sentinel Beast	39593	2022-05-12	0
K-Ci & JoJo	39594	2022-05-12	0
Gloria Lynne	39595	2022-05-12	0
Reginald R. Robinson	39596	2022-05-12	0
Biohazard	39597	2022-05-12	0
Martin Solveig & Stephy Haik	39598	2022-05-12	0
Jan Garbarek_ The Hilliard Ensemble	39599	2022-05-12	0
Julian Cope	39600	2022-05-12	0
Ray Stevens	39601	2022-05-12	0
Susan Cadogan	39602	2022-05-12	0
Alison Krauss	39603	2022-05-12	0
Bonehead	39604	2022-05-12	0
Blir	39605	2022-05-12	0
Tetine	39606	2022-05-12	0
Dima Krasnik	39607	2022-05-12	0
Karen Young / Éric Auclair	39608	2022-05-12	0
The Cucumbers	39609	2022-05-12	0
Tony Carreira	39610	2022-05-12	0
Joe Bonamassa	39611	2022-05-12	0
Trace Decay	39612	2022-05-12	0
The Show is the Rainbow	39613	2022-05-12	0
Linda Clifford	39614	2022-05-12	0
Arthur Russell	39615	2022-05-12	0
Garnet Mimms	39616	2022-05-12	0
Richie Arndt & The Bluenatics	39617	2022-05-12	0
Cancer Bats	39618	2022-05-12	0
Bellatrax feat. Tina Cousins	39619	2022-05-12	0
Urban Cookie Collective	39620	2022-05-12	0
Noel Sanger	39621	2022-05-12	0
Redhead King Pin	39622	2022-05-12	0
Joey Cape	39623	2022-05-12	0
Giorgia	39624	2022-05-12	0
Cadillac Tramps	39625	2022-05-12	0
Brad Kane/Lea Salonga	39626	2022-05-12	0
Barry Jackson	39627	2022-05-12	0
Sid Vicious	39628	2022-05-12	0
Pretty Boy Floyd	39629	2022-05-12	0
Laughin'Nose	39630	2022-05-12	0
British Sea Power	39631	2022-05-12	0
Saga	39632	2022-05-12	0
Banjo Or Freakout	39633	2022-05-12	0
Bruce Hornsby and the Range	39634	2022-05-12	0
Helene Bøksle	39635	2022-05-12	0
Electric Boys	39636	2022-05-12	0
Paul van Dyk Feat. Johnny McDaid	39637	2022-05-12	0
Malk De Koijn	39638	2022-05-12	0
Your Enemies Friends	39639	2022-05-12	0
DuvelDuvel	39640	2022-05-12	0
Eiffel 65	39641	2022-05-12	0
David Anthony	39642	2022-05-12	0
Goatwhore	39643	2022-05-12	0
Pony Up!	39644	2022-05-12	0
G.R.I.T.S.	39645	2022-05-12	0
New Birth	39646	2022-05-12	0
Bobby Blue Bland	39647	2022-05-12	0
All Gone Dead	39648	2022-05-12	0
Mike Francis	39649	2022-05-12	0
Stan Webb	39650	2022-05-12	0
Glenn Branca	39651	2022-05-12	0
The Legendary Stardust Cowboy	39652	2022-05-12	0
The Muses Rapt	39653	2022-05-12	0
Veerus & Maxie Devine	39654	2022-05-12	0
Rodrigo Leão	39655	2022-05-12	0
Project 86	39656	2022-05-12	0
Justin Hayward	39657	2022-05-12	0
Chavela Vargas	39658	2022-05-12	0
Yoga Pop Ups	39659	2022-05-12	0
Sunlightsquare	39660	2022-05-12	0
Fred Poulet	39661	2022-05-12	0
Xela	39662	2022-05-12	0
Morissette	39663	2022-05-12	0
Swayzak;J.B. Rose	39664	2022-05-12	0
Rosanne Cash	39665	2022-05-12	0
Rafa Pons	39666	2022-05-12	0
Big Twins	39667	2022-05-12	0
Kevin Toney & Rahmlee Davis	39668	2022-05-12	0
Chrisette Michele	39669	2022-05-12	0
The 101ers	39670	2022-05-12	0
The Real McCoy	39671	2022-05-12	0
Nadia Ali	39672	2022-05-12	0
The Charms	39673	2022-05-12	0
Brian Knight	39674	2022-05-12	0
Lovie Lee	39675	2022-05-12	0
Controlled Bleeding	39676	2022-05-12	0
Aztec Two-Step	39677	2022-05-12	0
The Strike	39678	2022-05-12	0
Lukestar	39679	2022-05-12	0
Rich Boy	39680	2022-05-12	0
Fabrizio Faniello	39681	2022-05-12	0
Antonio Koudele	39682	2022-05-12	0
Amplify	39683	2022-05-12	0
The Hooters	39684	2022-05-12	0
Hasil Adkins	39685	2022-05-12	0
Sanseverino	39686	2022-05-12	0
Hundred Year Storm	39687	2022-05-12	0
The Calling	39688	2022-05-12	0
DJ The Joker	39689	2022-05-12	0
David Toop	39690	2022-05-12	0
Samajona	39691	2022-05-12	0
Five Satins	39692	2022-05-12	0
A-Sides	39693	2022-05-12	0
Merl Saunders	39694	2022-05-12	0
Eppu Normaali	39695	2022-05-12	0
George Lopez	39696	2022-05-12	0
Tokyo Sex Destruction	39697	2022-05-12	0
Mirah	39698	2022-05-12	0
Booker T & The MG's	39699	2022-05-12	0
Magic Pie	39700	2022-05-12	0
David Sanborn	39701	2022-05-12	0
Sofia Talvik	39702	2022-05-12	0
Gigi D'agostino	39703	2022-05-12	0
The Verve	39704	2022-05-12	0
Duke Special	39705	2022-05-12	0
Hanin Elias	39706	2022-05-12	0
U.S. Maple	39707	2022-05-12	0
Crippled Black Phoenix	39708	2022-05-12	0
Carbon Leaf	39709	2022-05-12	0
Claire Voyant	39710	2022-05-12	0
The Click Five	39711	2022-05-12	0
Costa Cordalis	39712	2022-05-12	0
Sarah Harding	39713	2022-05-12	0
Alter Ego	39714	2022-05-12	0
Béla Fleck and the Flecktones	39715	2022-05-12	0
The Blood Brothers	39716	2022-05-12	0
Final Fantasy	39717	2022-05-12	0
Procol Harum	39718	2022-05-12	0
Spring Heeled Jack	39719	2022-05-12	0
Waking Eyes	39720	2022-05-12	0
Brian Posehn	39721	2022-05-12	0
Arda	39722	2022-05-12	0
Imogen Heap	39723	2022-05-12	0
Karen Bernod	39724	2022-05-12	0
Mark Perry	39725	2022-05-12	0
SINERGY	39726	2022-05-12	0
National Health	39727	2022-05-12	0
Mike Brooks	39728	2022-05-12	0
Scott Walker	39729	2022-05-12	0
Lonnie Brooks	39730	2022-05-12	0
Steve Harley & Cockney Rebel	39731	2022-05-12	0
Rodney Jones	39732	2022-05-12	0
Paul Curreri	39733	2022-05-12	0
Brian Eno And David Byrne	39734	2022-05-12	0
Useless Id	39735	2022-05-12	0
Delta Spirit	39736	2022-05-12	0
Remy Shand	39737	2022-05-12	0
Il Divo	39738	2022-05-12	0
La Bottega Dell'Arte	39739	2022-05-12	0
Space Frog	39740	2022-05-12	0
Christopher	39741	2022-05-12	0
Tube & Berger pres. Push Push	39742	2022-05-12	0
The Specials	39743	2022-05-12	0
Frank V	39744	2022-05-12	0
In This Moment	39745	2022-05-12	0
Instrumental	39746	2022-05-12	0
Kid Creole & The Coconuts	39747	2022-05-12	0
Dj Satomi	39748	2022-05-12	0
Same Difference	39749	2022-05-12	0
Botellita De Jerez	39750	2022-05-12	0
Jon Cougar Concentration Camp	39751	2022-05-12	0
Rotor	39752	2022-05-12	0
Schrottgrenze	39753	2022-05-12	0
My Summer As A Salvation Soldier	39754	2022-05-12	0
James "Son" Thomas & Cleveland "Broomman" Jones	39755	2022-05-12	0
Veggie Tales	39756	2022-05-12	0
Johan Gielen	39757	2022-05-12	0
Embrace the End	39758	2022-05-12	0
Alfredo Zitarrosa	39759	2022-05-12	0
Necronomitron	39760	2022-05-12	0
Elevator To Hell	39761	2022-05-12	0
La Renga	39762	2022-05-12	0
La Coka Nostra	39763	2022-05-12	0
Seth Gueko	39764	2022-05-12	0
Poncho Sanchez	39765	2022-05-12	0
Mystikal	39766	2022-05-12	0
Debbie Gibson	39767	2022-05-12	0
Audio Soul Project	39768	2022-05-12	0
The Capitol Years	39769	2022-05-12	0
Meykel	39770	2022-05-12	0
Maurette Brown Clark	39771	2022-05-12	0
Luis Alberto Spinetta	39772	2022-05-12	0
Carlos Vives	39773	2022-05-12	0
Air Supply	39774	2022-05-12	0
Vrse Murphy	39775	2022-05-12	0
Russell Sherman	39776	2022-05-12	0
T-Bone Walker	39777	2022-05-12	0
Eddie & The Hot Rods	39778	2022-05-12	0
Kenny Werner	39779	2022-05-12	0
AFI	39780	2022-05-12	0
Dekad	39781	2022-05-12	0
Michael Yonkers	39782	2022-05-12	0
Jurassic 5	39783	2022-05-12	0
Swim	39784	2022-05-12	0
Blind Willie & Partner	39785	2022-05-12	0
Evan Dando	39786	2022-05-12	0
Henry McCullough	39787	2022-05-12	0
Josh Wink	39788	2022-05-12	0
Pescado Rabioso	39789	2022-05-12	0
Bebel Gilberto	39790	2022-05-12	0
The Merry Macs	39791	2022-05-12	0
Trilucid	39792	2022-05-12	0
Nouvelle Vague feat. Martin Gore	39793	2022-05-12	0
Axwell	39794	2022-05-12	0
Takács Quartet	39795	2022-05-12	0
Cybertribe	39796	2022-05-12	0
Aly & Fila	39797	2022-05-12	0
Lotus	39798	2022-05-12	0
Aaron Neville featuring Ivan Neville	39799	2022-05-12	0
Agenda of Swine	39800	2022-05-12	0
Kingdom Come	39801	2022-05-12	0
Diana Ross / Marvin Gaye	39802	2022-05-12	0
Ultravox	39803	2022-05-12	0
Hank Mobley	39804	2022-05-12	0
Nasa	39805	2022-05-12	0
Evelyn Thomas	39806	2022-05-12	0
The Frantic Flintstones	39807	2022-05-12	0
Natalie Cole & Peabo Bryson	39808	2022-05-12	0
Filthy Dukes	39809	2022-05-12	0
Hilary Hahn	39810	2022-05-12	0
Future Kings Of Spain	39811	2022-05-12	0
Patrice Rushen	39812	2022-05-12	0
Screaming Target	39813	2022-05-12	0
Ac Acoustics	39814	2022-05-12	0
Batdorf & Rodney	39815	2022-05-12	0
The Rain	39816	2022-05-12	0
Bo Kaspers Orkester	39817	2022-05-12	0
London Symphony Orchestra and Leopold Ludwig	39818	2022-05-12	0
Moby	39819	2022-05-12	0
Dave Ellesmere	39820	2022-05-12	0
Oceansize	39821	2022-05-12	0
Mike Sonar & Nivaya	39822	2022-05-12	0
The Gabe Dixon Band	39823	2022-05-12	0
Dusty Kid	39824	2022-05-12	0
New World Africa	39825	2022-05-12	0
Santos	39826	2022-05-12	0
JJ Flores & Steve Smooth feat. Alex Peace	39827	2022-05-12	0
Joachim Spieth	39828	2022-05-12	0
DJ Mayonnaise	39829	2022-05-12	0
The Gourds	39830	2022-05-12	0
Studio Allstars	39831	2022-05-12	0
Dario Marianelli	39832	2022-05-12	0
The Lettermen	39833	2022-05-12	0
Compton's Most Wanted	39834	2022-05-12	0
Jan Garbarek_ Bill Frisell_ Eberhard Weber_ Michael DiPasqua	39835	2022-05-12	0
Example	39836	2022-05-12	0
Fonzerelli	39837	2022-05-12	0
Torn Apart	39838	2022-05-12	0
Zero Le Crêche	39839	2022-05-12	0
The Wallflowers	39840	2022-05-12	0
Byzantine	39841	2022-05-12	0
Jimmy Page	39842	2022-05-12	0
Perrocker	39843	2022-05-12	0
Mecki Mark Men	39844	2022-05-12	0
silent force	39845	2022-05-12	0
Queens Of The Stone Age	39846	2022-05-12	0
Spiros Kaloumenos	39847	2022-05-12	0
Leviathan	39848	2022-05-12	0
Bangbros	39849	2022-05-12	0
El Coyote Y Su Banda	39850	2022-05-12	0
Richie Sambora	39851	2022-05-12	0
Gary Hoey	39852	2022-05-12	0
The Tragically Hip	39853	2022-05-12	0
Carbon Based Lifeforms	39854	2022-05-12	0
Uriah Heep	39855	2022-05-12	0
Arthur Verocai	39856	2022-05-12	0
Triinu Kivilaan	39857	2022-05-12	0
The Red Thread	39858	2022-05-12	0
Atomic Opera	39859	2022-05-12	0
SIL	39860	2022-05-12	0
Stretch Arm Strong	39861	2022-05-12	0
Major Problems	39862	2022-05-12	0
Lordz Of Brooklyn	39863	2022-05-12	0
David Lee Roth	39864	2022-05-12	0
YDI	39865	2022-05-12	0
Monta	39866	2022-05-12	0
Janet Paschal	39867	2022-05-12	0
Mumia Abu-Jamal	39868	2022-05-12	0
Luther "Guitar Junior" Johnson	39869	2022-05-12	0
Slyde	39870	2022-05-12	0
Anja Schneider	39871	2022-05-12	0
James Ingram / Patti Austin	39872	2022-05-12	0
On Broken Wings	39873	2022-05-12	0
DJ X-Change	39874	2022-05-12	0
VIP Mass Choir featuring John P. Kee	39875	2022-05-12	0
Soul Asylum	39876	2022-05-12	0
The Groundhogs	39877	2022-05-12	0
Tommy James And The Shondells	39878	2022-05-12	0
Beverley Craven	39879	2022-05-12	0
Joe Venuti_ Eddie Lang	39880	2022-05-12	0
P. J Proby	39881	2022-05-12	0
Markus Enochson	39882	2022-05-12	0
We Are The Ocean	39883	2022-05-12	0
Prong	39884	2022-05-12	0
Sylvie Lewis	39885	2022-05-12	0
LJ Kruzer	39886	2022-05-12	0
Stemm	39887	2022-05-12	0
Veljanov	39888	2022-05-12	0
Gramm Kracker	39889	2022-05-12	0
Da Groove Doctors featuring Duane Harden	39890	2022-05-12	0
Fort Knox Five	39891	2022-05-12	0
Guilty connector	39892	2022-05-12	0
Bedwetters	39893	2022-05-12	0
Bill & Gloria Gaither	39894	2022-05-12	0
Lee Scratch Perry	39895	2022-05-12	0
Yonderboi	39896	2022-05-12	0
Phenomden featuring Don Rico	39897	2022-05-12	0
Daniel Stefanik	39898	2022-05-12	0
Oppressed Logic	39899	2022-05-12	0
Stefon Harris	39900	2022-05-12	0
Puddle Of Mudd	39901	2022-05-12	0
Willard Grant Conspiracy	39902	2022-05-12	0
Barry Manilow Featuring The Jimmy Dorsey Orchestra with Rosemary Clooney	39903	2022-05-12	0
Skitz	39904	2022-05-12	0
ChronGen	39905	2022-05-12	0
Blank + Jones	39906	2022-05-12	0
Books On Tape	39907	2022-05-12	0
Los Cadetes de Linares	39908	2022-05-12	0
Admiral Tibett	39909	2022-05-12	0
Tony Thompson	39910	2022-05-12	0
STEEL PROPHET	39911	2022-05-12	0
Danger Danger	39912	2022-05-12	0
Blah Blah Blah	39913	2022-05-12	0
The Tangent	39914	2022-05-12	0
Chris Carrier & Jef K	39915	2022-05-12	0
Kiotti	39916	2022-05-12	0
Lifestyle	39917	2022-05-12	0
Edvard Grieg	39918	2022-05-12	0
T.I. & DJ Drama	39919	2022-05-12	0
Pharoahe Monch	39920	2022-05-12	0
Keith Urban	39921	2022-05-12	0
Billy Bragg	39922	2022-05-12	0
Adrede	39923	2022-05-12	0
Coleman Hawkins	39924	2022-05-12	0
Teenage Fanclub & Jad Fair	39925	2022-05-12	0
Twenty 4 Seven & Captain Hollywood	39926	2022-05-12	0
Kool Savas & Azad feat. Xavier Naidoo	39927	2022-05-12	0
Marilyn Horne / Vienna Cantata Orchestra / Henry Lewis	39928	2022-05-12	0
Psycho and the Birds	39929	2022-05-12	0
Boot Party	39930	2022-05-12	0
Erskine Hawkins & His Orchestra	39931	2022-05-12	0
Cidade Negra	39932	2022-05-12	0
Boss Volenti	39933	2022-05-12	0
This Day Forward	39934	2022-05-12	0
Becker & Fagen	39935	2022-05-12	0
Down By Law	39936	2022-05-12	0
Dvorak / Susan Kanzian / Ed Lewis	39937	2022-05-12	0
Max Cooper	39938	2022-05-12	0
Steel Pole Bath Tub	39939	2022-05-12	0
Mark Whitfield	39940	2022-05-12	0
So	39941	2022-05-12	0
Fermin Muguruza	39942	2022-05-12	0
Beres Hammond	39943	2022-05-12	0
Bill Wyman	39944	2022-05-12	0
Haggard	39945	2022-05-12	0
Dub Pistols feat. Rodney P & Terry Hall	39946	2022-05-12	0
GTA	39947	2022-05-12	0
Sway	39948	2022-05-12	0
Warlocks	39949	2022-05-12	0
Tommy Makem & Liam Clancy	39950	2022-05-12	0
DMZ	39951	2022-05-12	0
Windmills By The Ocean	39952	2022-05-12	0
2nd II None	39953	2022-05-12	0
Kokane	39954	2022-05-12	0
Paul Hardcastle	39955	2022-05-12	0
City of Prague Philharmonic and the Crouch End Festival Chorus	39956	2022-05-12	0
KDC	39957	2022-05-12	0
Götz Alsmann	39958	2022-05-12	0
Baby Wayne	39959	2022-05-12	0
George Baker Selection	39960	2022-05-12	0
The Envy Corps	39961	2022-05-12	0
Juelz Santana	39962	2022-05-12	0
The Queers	39963	2022-05-12	0
Junior Parker	39964	2022-05-12	0
Chiens De Paille	39965	2022-05-12	0
Sebo K	39966	2022-05-12	0
The Advantage	39967	2022-05-12	0
Anjali	39968	2022-05-12	0
Heraldo Do Monte	39969	2022-05-12	0
Shai	39970	2022-05-12	0
Dion_ The Belmonts	39971	2022-05-12	0
Molemen & Panik	39972	2022-05-12	0
Joe Vitale	39973	2022-05-12	0
Amine	39974	2022-05-12	0
Mark Dinning	39975	2022-05-12	0
Barney Kessel	39976	2022-05-12	0
Rory Block	39977	2022-05-12	0
Mohammad Nouri	39978	2022-05-12	0
Kimen	39979	2022-05-12	0
Skúli Sverrisson	39980	2022-05-12	0
The Toasters	39981	2022-05-12	0
Ricardo Igea	39982	2022-05-12	0
The Bluetones	39983	2022-05-12	0
Numatic Soul	39984	2022-05-12	0
Bomb 20	39985	2022-05-12	0
PackFM	39986	2022-05-12	0
Space Manoeuvres	39987	2022-05-12	0
SQ-1	39988	2022-05-12	0
Tiger	39989	2022-05-12	0
Fat Boys	39990	2022-05-12	0
Stevie Ray Vaughan;Double Trouble	39991	2022-05-12	0
Carleen Anderson	39992	2022-05-12	0
Som Imaginario	39993	2022-05-12	0
Bobcat Goldthwait	39994	2022-05-12	0
Roachford	39995	2022-05-12	0
Dickie Harrell	39996	2022-05-12	0
J-Kwon	39997	2022-05-12	0
Mouthwash	39998	2022-05-12	0
Alice DJ	39999	2022-05-12	0
U.Seed	40000	2022-05-12	0
Lye By Mistake	40001	2022-05-12	0
Clyde McPhatter & The Drifters	40002	2022-05-12	0
Lil Jon_ Lil Scrappy_ DJ Drama	40003	2022-05-12	0
Link Wray & The Wraymen	40004	2022-05-12	0
Lydia Lunch	40005	2022-05-12	0
Jelo	40006	2022-05-12	0
Laurie Anderson	40007	2022-05-12	0
Analogue Brain	40008	2022-05-12	0
The Dubs	40009	2022-05-12	0
The Golden Boys	40010	2022-05-12	0
Lyte Funkie Ones	40011	2022-05-12	0
Nappy Brown	40012	2022-05-12	0
Patrice DiPasquale_ Frederic Chopin	40013	2022-05-12	0
Tanto Metro & Devonte	40014	2022-05-12	0
Kreon & Lemons	40015	2022-05-12	0
Zachary Breaux	40016	2022-05-12	0
Baka Beyond	40017	2022-05-12	0
My Morning Jacket	40018	2022-05-12	0
Immortal Technique Presents: Akir	40019	2022-05-12	0
Kalmah	40020	2022-05-12	0
La Banda Del Diablo	40021	2022-05-12	0
TYR	40022	2022-05-12	0
Todd Rundgren	40023	2022-05-12	0
J-Luv feat. Azad	40024	2022-05-12	0
Dexter Gordon	40025	2022-05-12	0
The Gladiators	40026	2022-05-12	0
Aaron Hall	40027	2022-05-12	0
Bread	40028	2022-05-12	0
Gene Farris	40029	2022-05-12	0
The Cootees	40030	2022-05-12	0
Peppino Di Capri	40031	2022-05-12	0
Malena	40032	2022-05-12	0
Samara Lubelski	40033	2022-05-12	0
Vomitory	40034	2022-05-12	0
Throwdown	40035	2022-05-12	0
Joe Jones And Lucky Thompson	40036	2022-05-12	0
Gareth Emery	40037	2022-05-12	0
Rex Mundi	40038	2022-05-12	0
Junior Walker	40039	2022-05-12	0
Massimo Volume	40040	2022-05-12	0
Acorps de Rue	40041	2022-05-12	0
The Pioneers	40042	2022-05-12	0
Mind Funk	40043	2022-05-12	0
Monoceros	40044	2022-05-12	0
DDT	40045	2022-05-12	0
Bob Newhart	40046	2022-05-12	0
Kath Bloom	40047	2022-05-12	0
Sticky Fingaz_ Bokeem Woodbine & Michael K. Williams	40048	2022-05-12	0
Kasse Mady Diabate	40049	2022-05-12	0
Burn In Silence	40050	2022-05-12	0
Max B	40051	2022-05-12	0
The Perrys	40052	2022-05-12	0
Pascal FEOS	40053	2022-05-12	0
Haley Bonar	40054	2022-05-12	0
Lord Belial	40055	2022-05-12	0
John Barry	40056	2022-05-12	0
Rainer Von Vielen	40057	2022-05-12	0
The Honeydrips	40058	2022-05-12	0
Bad Joke	40059	2022-05-12	0
Maria Friedman_ Ruthie Henshall_ Millicent Martin & Lea Salonga	40060	2022-05-12	0
Dramarama	40061	2022-05-12	0
Praga Khan	40062	2022-05-12	0
Fred Eaglesmith	40063	2022-05-12	0
Adam & The Ants	40064	2022-05-12	0
Sick City	40065	2022-05-12	0
R.B. Morris	40066	2022-05-12	0
Pete Lazonby	40067	2022-05-12	0
Jacky Cheung	40068	2022-05-12	0
Devin Townsend	40069	2022-05-12	0
Azul Violeta	40070	2022-05-12	0
Jack Wagner	40071	2022-05-12	0
Pete Kilpatrick	40072	2022-05-12	0
The Flys	40073	2022-05-12	0
Negura Bunget	40074	2022-05-12	0
Teenage Bottlerocket	40075	2022-05-12	0
Jimmy Nail	40076	2022-05-12	0
Adam Hood	40077	2022-05-12	0
Don Covay	40078	2022-05-12	0
Cisco Houston	40079	2022-05-12	0
Gino D'Auri	40080	2022-05-12	0
The Menzingers	40081	2022-05-12	0
Curse feat. Gentleman	40082	2022-05-12	0
Worship Ensemble	40083	2022-05-12	0
Duquende	40084	2022-05-12	0
Billy Vaughn And His Orchestra	40085	2022-05-12	0
Stephan Micus_ Nobuko Micus	40086	2022-05-12	0
Reinhard Mey	40087	2022-05-12	0
D-Code (feat. Nerm)	40088	2022-05-12	0
Gonzalo Rubalcaba	40089	2022-05-12	0
Paul Brown / Jessy J	40090	2022-05-12	0
Hiram Bullock	40091	2022-05-12	0
The Big Screen	40092	2022-05-12	0
Hackensaw Boys	40093	2022-05-12	0
Tanya Donelly	40094	2022-05-12	0
Dolby Anol	40095	2022-05-12	0
Belly	40096	2022-05-12	0
Bilal	40097	2022-05-12	0
Mercan Dede	40098	2022-05-12	0
Anané	40099	2022-05-12	0
Recloose feat. Hollie Smith	40100	2022-05-12	0
Red Letter Day	40101	2022-05-12	0
Insane Clown Posse	40102	2022-05-12	0
Murray Head / The Trinidad Singers	40103	2022-05-12	0
Tin Foil Phoenix	40104	2022-05-12	0
Pale Saints	40105	2022-05-12	0
L.S.G.	40106	2022-05-12	0
Courtney Melody	40107	2022-05-12	0
Keith Anderson	40108	2022-05-12	0
PFM	40109	2022-05-12	0
Lena Horne & Gabor Szabo	40110	2022-05-12	0
Mad and Spectral	40111	2022-05-12	0
Logickal	40112	2022-05-12	0
Wideboys	40113	2022-05-12	0
Dickies	40114	2022-05-12	0
Fanon Flowers	40115	2022-05-12	0
The Original Five Blind Boys Of Alabama	40116	2022-05-12	0
Single Gun Theory	40117	2022-05-12	0
Doris Day with Paul Weston & his Music from Hollywood	40118	2022-05-12	0
Maino	40119	2022-05-12	0
Weavers	40120	2022-05-12	0
Delfins	40121	2022-05-12	0
Klaus Lage Band	40122	2022-05-12	0
Amanda	40123	2022-05-12	0
Freddie & The Dreamers	40124	2022-05-12	0
The Hitmen	40125	2022-05-12	0
Double Negative	40126	2022-05-12	0
Vicentico	40127	2022-05-12	0
It's Immaterial	40128	2022-05-12	0
Jah Stitch	40129	2022-05-12	0
Hannes Wader	40130	2022-05-12	0
Hi Lo's	40131	2022-05-12	0
Federation	40132	2022-05-12	0
Chrisette Michele / Ne-Yo	40133	2022-05-12	0
Carola	40134	2022-05-12	0
Hadag Nahash	40135	2022-05-12	0
Aoki Takamasa	40136	2022-05-12	0
Wendy MaHarry	40137	2022-05-12	0
The Little Willies	40138	2022-05-12	0
Pierre Pienaar	40139	2022-05-12	0
Robin Williamson	40140	2022-05-12	0
Esbjörn Svensson Trio	40141	2022-05-12	0
Aggro Berlin	40142	2022-05-12	0
Dancefloor Saints	40143	2022-05-12	0
Marvin Hamlisch	40144	2022-05-12	0
Summer Lei	40145	2022-05-12	0
The Ergs!	40146	2022-05-12	0
Frank London´s Klezmer Brass Allstars	40147	2022-05-12	0
Pintandwefall	40148	2022-05-12	0
Dezz White	40149	2022-05-12	0
Shazza	40150	2022-05-12	0
The New Cities	40151	2022-05-12	0
Gale Storm	40152	2022-05-12	0
Cryptopsy	40153	2022-05-12	0
The In Crowd	40154	2022-05-12	0
VIP	40155	2022-05-12	0
Daath	40156	2022-05-12	0
Jordan McCoy	40157	2022-05-12	0
Inspectah Deck	40158	2022-05-12	0
The Alarm	40159	2022-05-12	0
Singapore Sling	40160	2022-05-12	0
Burial	40161	2022-05-12	0
Bat For Lashes	40162	2022-05-12	0
Doro Pesch	40163	2022-05-12	0
The Xtraverts	40164	2022-05-12	0
Braid	40165	2022-05-12	0
Basic Element	40166	2022-05-12	0
Tommy McCook	40167	2022-05-12	0
Handsome Boy Modeling School	40168	2022-05-12	0
Tuti Fernandez	40169	2022-05-12	0
Use Artist # 1431	40170	2022-05-12	0
Cartel De Santa	40171	2022-05-12	0
DJ Spooky that Subliminal Kid	40172	2022-05-12	0
Ramblin' Jack Elliott	40173	2022-05-12	0
Zornik	40174	2022-05-12	0
Mila Mason	40175	2022-05-12	0
Diomedes Diaz;Juancho Rois	40176	2022-05-12	0
Hunger	40177	2022-05-12	0
Richie Ray & Bobby Cruz	40178	2022-05-12	0
Alex Baroni	40179	2022-05-12	0
Ceca Raznatovic	40180	2022-05-12	0
Th' Legendary Shack*Shakers	40181	2022-05-12	0
Dark Sanctuary	40182	2022-05-12	0
Daniel Barenboim/English Chamber Orchestra	40183	2022-05-12	0
Felix Da House Cat	40184	2022-05-12	0
Armored Saint	40185	2022-05-12	0
Fe de Ratas	40186	2022-05-12	0
Fotheringay	40187	2022-05-12	0
The Be Be See	40188	2022-05-12	0
RIOU	40189	2022-05-12	0
David Bowie	40190	2022-05-12	0
Danny Elfman	40191	2022-05-12	0
Sandy Denny	40192	2022-05-12	0
A. Skillz & Krafty Kuts	40193	2022-05-12	0
Noyau Dur	40194	2022-05-12	0
Deepface	40195	2022-05-12	0
JP Juice	40196	2022-05-12	0
Coldplay	40197	2022-05-12	0
Fetterline	40198	2022-05-12	0
Mac Dre & Da' Unda' Dogg	40199	2022-05-12	0
Life	40200	2022-05-12	0
Milk Inc.	40201	2022-05-12	0
Gary Portnoy	40202	2022-05-12	0
The Family	40203	2022-05-12	0
Looking Up	40204	2022-05-12	0
Team Doyobi	40205	2022-05-12	0
Emerg McVay	40206	2022-05-12	0
Fernan Dust	40207	2022-05-12	0
D-Tension	40208	2022-05-12	0
John Reuben	40209	2022-05-12	0
Satan's Host	40210	2022-05-12	0
Colm Wilkinson;Linda Eder	40211	2022-05-12	0
The Tremeloes	40212	2022-05-12	0
Kurt Vile	40213	2022-05-12	0
Supergrass	40214	2022-05-12	0
DISMEMBER	40215	2022-05-12	0
David Lowe's Dreamcatcher	40216	2022-05-12	0
This Will Destroy You	40217	2022-05-12	0
Secret Chiefs 3	40218	2022-05-12	0
KOM-teatteri	40219	2022-05-12	0
Bridges and Powerlines	40220	2022-05-12	0
Before Their Eyes	40221	2022-05-12	0
Janez Detd	40222	2022-05-12	0
Saint Saens	40223	2022-05-12	0
Abfahrt Hinwil	40224	2022-05-12	0
Spencer Davis	40225	2022-05-12	0
Silvina Garre	40226	2022-05-12	0
From Karaoke To Stardom	40227	2022-05-12	0
Jocelyne Béroard	40228	2022-05-12	0
Light This City	40229	2022-05-12	0
Corinne Bailey Rae	40230	2022-05-12	0
Theodore	40231	2022-05-12	0
Sal Ban	40232	2022-05-12	0
Alex M.O.R.P.H. and Woody van Eyden	40233	2022-05-12	0
The School	40234	2022-05-12	0
The Watts 103rd. Street Rhythm Band	40235	2022-05-12	0
Ali Kuru	40236	2022-05-12	0
Useless Wooden Toys	40237	2022-05-12	0
The 411	40238	2022-05-12	0
Bottomless Pit	40239	2022-05-12	0
Middle Class_ The	40240	2022-05-12	0
Sibylle Baier	40241	2022-05-12	0
World Of Twist	40242	2022-05-12	0
Truth Enola	40243	2022-05-12	0
Dave Derby	40244	2022-05-12	0
Toenut	40245	2022-05-12	0
Kris de Bruyne	40246	2022-05-12	0
WINTERSUN	40247	2022-05-12	0
Mike Shiver vs Matias Lehtola feat. Andrea Britton	40248	2022-05-12	0
Kenny Loggins	40249	2022-05-12	0
Los Natas	40250	2022-05-12	0
Hardy Kingston	40251	2022-05-12	0
Si Begg	40252	2022-05-12	0
Iwer George	40253	2022-05-12	0
Frankmusik	40254	2022-05-12	0
Ejected	40255	2022-05-12	0
Scarve	40256	2022-05-12	0
Vincenzo Bellini	40257	2022-05-12	0
Underworld	40258	2022-05-12	0
John Tesh	40259	2022-05-12	0
Antony & The Johnsons with Boy George	40260	2022-05-12	0
Ringworm	40261	2022-05-12	0
Ratt	40262	2022-05-12	0
Sugafree featuring Hustle Hard	40263	2022-05-12	0
Miguel Morales	40264	2022-05-12	0
Bronnt Industries Kapital	40265	2022-05-12	0
Luciana	40266	2022-05-12	0
Vahag Petian & Clarence Johnson III	40267	2022-05-12	0
Diomedes Diaz _ Juancho Rois	40268	2022-05-12	0
Damnation Plan	40269	2022-05-12	0
Fantan Mojah	40270	2022-05-12	0
U Totem	40271	2022-05-12	0
Toumani Diabaté	40272	2022-05-12	0
Meat Puppets	40273	2022-05-12	0
West Band	40274	2022-05-12	0
Cole Porter	40275	2022-05-12	0
Seven Mary Three	40276	2022-05-12	0
Dave Meniketti	40277	2022-05-12	0
Dave And Ansel Collins	40278	2022-05-12	0
Lopazz	40279	2022-05-12	0
System F	40280	2022-05-12	0
The New Musical Cast	40281	2022-05-12	0
Mickey Moonlight	40282	2022-05-12	0
The New Lost City Ramblers	40283	2022-05-12	0
Stephen Malkmus & The Jicks	40284	2022-05-12	0
Götterdämmerung	40285	2022-05-12	0
Vec	40286	2022-05-12	0
Martha Argerich	40287	2022-05-12	0
Nastassya Ney	40288	2022-05-12	0
Crosby / Nash	40289	2022-05-12	0
Richard Durand	40290	2022-05-12	0
Manuel Iman	40291	2022-05-12	0
Continental Drifters	40292	2022-05-12	0
Donnie	40293	2022-05-12	0
Disco D	40294	2022-05-12	0
M Ward	40295	2022-05-12	0
Riley	40296	2022-05-12	0
Só Pra Contrariar	40297	2022-05-12	0
Anjellee	40298	2022-05-12	0
The Waybacks	40299	2022-05-12	0
Beat Service	40300	2022-05-12	0
Los Ninos De Sara	40301	2022-05-12	0
Joyce Cooling	40302	2022-05-12	0
Talla 2XLC vs. Sean Tyas	40303	2022-05-12	0
Scot Ray Quintet	40304	2022-05-12	0
Mr Dubz	40305	2022-05-12	0
Flo & Eddie	40306	2022-05-12	0
LaBelle	40307	2022-05-12	0
Patsy Gallant	40308	2022-05-12	0
Ring_ Cicada	40309	2022-05-12	0
Eric Sneo	40310	2022-05-12	0
Champion Jack Dupree With TS McPhee	40311	2022-05-12	0
Pixies	40312	2022-05-12	0
Decimal Bass	40313	2022-05-12	0
Wynonna Judd	40314	2022-05-12	0
Mutya Buena	40315	2022-05-12	0
Niccokick	40316	2022-05-12	0
Mothers Little Helpers	40317	2022-05-12	0
Sasha	40318	2022-05-12	0
Geno Washington	40319	2022-05-12	0
Necro	40320	2022-05-12	0
Eugene Bridges	40321	2022-05-12	0
prinzhorn dance school	40322	2022-05-12	0
Cassette Kids	40323	2022-05-12	0
Nicki	40324	2022-05-12	0
Raymond Scott	40325	2022-05-12	0
S Club 7	40326	2022-05-12	0
Jan Van Bass-10	40327	2022-05-12	0
Ignition Technician	40328	2022-05-12	0
Little Richard	40329	2022-05-12	0
The Flaming Tsunamis	40330	2022-05-12	0
Oliver Nelson	40331	2022-05-12	0
Pablo Montero	40332	2022-05-12	0
Bobaflex	40333	2022-05-12	0
Blue Oyster Cult	40334	2022-05-12	0
Utah Jazz Vs Soulmatic	40335	2022-05-12	0
Matthew Sweet & Susanna Hoffs	40336	2022-05-12	0
Saez	40337	2022-05-12	0
Johnny & Hurricanes	40338	2022-05-12	0
Branford Marsalis	40339	2022-05-12	0
Joe Barry	40340	2022-05-12	0
Paquito D'Rivera_ The United Nation Orchestra	40341	2022-05-12	0
Calogero	40342	2022-05-12	0
Homelife	40343	2022-05-12	0
Anibal Troilo y su Orquesta Tipica	40344	2022-05-12	0
Ambelique	40345	2022-05-12	0
This Mortal Coil	40346	2022-05-12	0
Dirty Looks	40347	2022-05-12	0
Die Form	40348	2022-05-12	0
Tarrus Riley	40349	2022-05-12	0
Chanté Moore	40350	2022-05-12	0
Toxic Holocaust	40351	2022-05-12	0
Bang on a Can All-Stars	40352	2022-05-12	0
Sefyu_ RR	40353	2022-05-12	0
The Icarus Line	40354	2022-05-12	0
Edgar Bori	40355	2022-05-12	0
Ohm Square	40356	2022-05-12	0
Roine Stolt	40357	2022-05-12	0
Usher	40358	2022-05-12	0
Antti Tuisku	40359	2022-05-12	0
The Walkabouts	40360	2022-05-12	0
Katri Ylander	40361	2022-05-12	0
Letzte Instanz	40362	2022-05-12	0
Ranking Dread	40363	2022-05-12	0
Blood Red Shoes	40364	2022-05-12	0
Ladyhawke	40365	2022-05-12	0
The Beauty of Gemina	40366	2022-05-12	0
Delly Ranks	40367	2022-05-12	0
My Chemical Romance	40368	2022-05-12	0
Ray Conniff & His Orchestra	40369	2022-05-12	0
David Civera	40370	2022-05-12	0
Ufomammut	40371	2022-05-12	0
Ned Rorem	40372	2022-05-12	0
Charles Williams	40373	2022-05-12	0
Metro Area	40374	2022-05-12	0
Erin McKeown	40375	2022-05-12	0
Cher	40376	2022-05-12	0
The Edgar Broughton Band	40377	2022-05-12	0
Martin Lawrence	40378	2022-05-12	0
Janiva Magness	40379	2022-05-12	0
Chateau Flight	40380	2022-05-12	0
Robben Ford & The Blue Line	40381	2022-05-12	0
Aldebert	40382	2022-05-12	0
Bobby Brown	40383	2022-05-12	0
María José Hernández	40384	2022-05-12	0
Mr untel_ LucyMay	40385	2022-05-12	0
Antimatter	40386	2022-05-12	0
Ana Belén;Chico Buarque	40387	2022-05-12	0
Bonnie Guitar	40388	2022-05-12	0
Jenny Lewis	40389	2022-05-12	0
Bloc Party	40390	2022-05-12	0
Steve Reich	40391	2022-05-12	0
The Good Life	40392	2022-05-12	0
Holly Dolly	40393	2022-05-12	0
Nocturnus	40394	2022-05-12	0
Sheila Walsh	40395	2022-05-12	0
D-12	40396	2022-05-12	0
Big Boy	40397	2022-05-12	0
A.B. Quintanilla III Y Los Kumbia All Starz	40398	2022-05-12	0
The Gap Band	40399	2022-05-12	0
Sven-R-G	40400	2022-05-12	0
Los Llaneros De La Frontera	40401	2022-05-12	0
Level 42	40402	2022-05-12	0
Processor	40403	2022-05-12	0
FRANK T	40404	2022-05-12	0
Sergei Rachmaninoff	40405	2022-05-12	0
Last Step	40406	2022-05-12	0
Ohio Players	40407	2022-05-12	0
Nelly / Sean P / Pimp C	40408	2022-05-12	0
Enthroned	40409	2022-05-12	0
Time Factory	40410	2022-05-12	0
Jihad Muhammad	40411	2022-05-12	0
Héroes del Silencio	40412	2022-05-12	0
Placido Domingo	40413	2022-05-12	0
Bobby Helms	40414	2022-05-12	0
Sister Hazel	40415	2022-05-12	0
Magnet	40416	2022-05-12	0
Trancendental	40417	2022-05-12	0
Abandin All Hope	40418	2022-05-12	0
Splash	40419	2022-05-12	0
TOMMI LÄNTINEN	40420	2022-05-12	0
Joe Dassin	40421	2022-05-12	0
Astrix	40422	2022-05-12	0
Robbie Fulks	40423	2022-05-12	0
Lurrie Bell	40424	2022-05-12	0
Cali Agents	40425	2022-05-12	0
DMX	40426	2022-05-12	0
Avishai Cohen	40427	2022-05-12	0
Floyd Cramer;Barry McDonald	40428	2022-05-12	0
Julie London	40429	2022-05-12	0
Lemonheads	40430	2022-05-12	0
X-Raided featuring Big Hollis_ Fane	40431	2022-05-12	0
The Scaffold	40432	2022-05-12	0
Vanilla Muffins	40433	2022-05-12	0
Euge Groove	40434	2022-05-12	0
Bass Bumpers	40435	2022-05-12	0
The Bumblebeez	40436	2022-05-12	0
Akanoid	40437	2022-05-12	0
Yoko Ono	40438	2022-05-12	0
Beau Brummels	40439	2022-05-12	0
Earlimart	40440	2022-05-12	0
Ike Quebec	40441	2022-05-12	0
Amel Larrieux	40442	2022-05-12	0
Jan Eggum	40443	2022-05-12	0
Syreeta	40444	2022-05-12	0
Slacker	40445	2022-05-12	0
Seventy Niners	40446	2022-05-12	0
Dysrhythmia	40447	2022-05-12	0
Wax Poetic	40448	2022-05-12	0
Renee Rosnes	40449	2022-05-12	0
Chromatics	40450	2022-05-12	0
A Sides Ft. Break	40451	2022-05-12	0
MF DOOM / MF GRIMM	40452	2022-05-12	0
Carolyn Dawn Johnson	40453	2022-05-12	0
Joseph Arthur & The Lonely Astronauts	40454	2022-05-12	0
Cheb Mami	40455	2022-05-12	0
Ron Van Den Beuken	40456	2022-05-12	0
Ladyfuzz	40457	2022-05-12	0
Cheer-Accident	40458	2022-05-12	0
As We Fight	40459	2022-05-12	0
Set Fire To Flames	40460	2022-05-12	0
Studio	40461	2022-05-12	0
Oxbow	40462	2022-05-12	0
Cooly G	40463	2022-05-12	0
Empire Of The Sun	40464	2022-05-12	0
Solar Plexus / Bagge & Sons	40465	2022-05-12	0
Elisabeth Withers	40466	2022-05-12	0
Sunbeam	40467	2022-05-12	0
La Sonora Dinamita	40468	2022-05-12	0
Mariano Yanani	40469	2022-05-12	0
Menomena	40470	2022-05-12	0
Mind Reflection	40471	2022-05-12	0
Sexy Sadie	40472	2022-05-12	0
Story Of The Year	40473	2022-05-12	0
Wrangler Brutes	40474	2022-05-12	0
Sneak Thief	40475	2022-05-12	0
Organic	40476	2022-05-12	0
Didar Sandhu	40477	2022-05-12	0
Vicky Leandros	40478	2022-05-12	0
Joe Williams / Count Basie	40479	2022-05-12	0
Jazz Addixx feat. DJ Ragz_ DJ Boom_ & Mudd	40480	2022-05-12	0
Margarida Pinto	40481	2022-05-12	0
United Nations	40482	2022-05-12	0
Håkan Lidbo	40483	2022-05-12	0
Feel	40484	2022-05-12	0
Kenneth Bager	40485	2022-05-12	0
Novadriver	40486	2022-05-12	0
The Human League	40487	2022-05-12	0
Patrick Juvet	40488	2022-05-12	0
Chunk	40489	2022-05-12	0
The Go-Go's	40490	2022-05-12	0
Bobby McFerrin;The Saint Paul Chamber Orchestra	40491	2022-05-12	0
Freestylers	40492	2022-05-12	0
Alpha & Omega	40493	2022-05-12	0
Here And Now	40494	2022-05-12	0
Scott Wesley Brown	40495	2022-05-12	0
Stack Waddy	40496	2022-05-12	0
Marla Hansen	40497	2022-05-12	0
Diablo Swing Orchestra	40498	2022-05-12	0
Roby Rossini	40499	2022-05-12	0
The Pandoras	40500	2022-05-12	0
Chrisinti	40501	2022-05-12	0
MDC	40502	2022-05-12	0
Eddie Cano	40503	2022-05-12	0
Santiago Auserón	40504	2022-05-12	0
Bembeya Jazz National	40505	2022-05-12	0
Purple Ribbon All-Stars feat. Big Boi	40506	2022-05-12	0
Timo Pralle	40507	2022-05-12	0
Atman	40508	2022-05-12	0
Central Coast Clique	40509	2022-05-12	0
Shione Yukawa	40510	2022-05-12	0
Amira Saqati	40511	2022-05-12	0
Howling Bells	40512	2022-05-12	0
BIZ	40513	2022-05-12	0
Mark Harris	40514	2022-05-12	0
Abijah	40515	2022-05-12	0
Special Needs	40516	2022-05-12	0
Creme Fresh	40517	2022-05-12	0
Judee Sill	40518	2022-05-12	0
P.M. Dawn	40519	2022-05-12	0
Håkan Hellström	40520	2022-05-12	0
Dim Chris (Tecktonik)	40521	2022-05-12	0
Justincase	40522	2022-05-12	0
Lou Barlow	40523	2022-05-12	0
The Old Dead Tree	40524	2022-05-12	0
New Roanoke Jug Band	40525	2022-05-12	0
Andrea Doria	40526	2022-05-12	0
Destroyer	40527	2022-05-12	0
Korpiklaani	40528	2022-05-12	0
Whale	40529	2022-05-12	0
Westbound Train	40530	2022-05-12	0
Vainica Doble	40531	2022-05-12	0
Kierra Sheard	40532	2022-05-12	0
Incognito	40533	2022-05-12	0
Per Gessle	40534	2022-05-12	0
Leandro and Leonardo	40535	2022-05-12	0
Marian McPartland / Rosemary Clooney	40536	2022-05-12	0
General Midi	40537	2022-05-12	0
Bodycode	40538	2022-05-12	0
LCD Soundsystem	40539	2022-05-12	0
Vienna Teng	40540	2022-05-12	0
Phil Phillips	40541	2022-05-12	0
Lori McKenna	40542	2022-05-12	0
Morphine	40543	2022-05-12	0
Rita Lee / Milton Nascimento	40544	2022-05-12	0
Christie	40545	2022-05-12	0
Reginald Dixon	40546	2022-05-12	0
Vector Lovers	40547	2022-05-12	0
Above & Beyond vs. Andy Moor	40548	2022-05-12	0
Helge Schneider	40549	2022-05-12	0
Collin Raye	40550	2022-05-12	0
Simon Joyner	40551	2022-05-12	0
Mariah Carey	40552	2022-05-12	0
Illaj & Mikey Vegaz	40553	2022-05-12	0
Cosmo Vitelli	40554	2022-05-12	0
New Radicals	40555	2022-05-12	0
Diary of Dreams	40556	2022-05-12	0
The Varukers	40557	2022-05-12	0
Phoebus Feat Despina Vandi	40558	2022-05-12	0
Bluebloods	40559	2022-05-12	0
Kaliber	40560	2022-05-12	0
The Five Blind Boys Of Mississippi	40561	2022-05-12	0
Whitney Houston	40562	2022-05-12	0
Alain Goraguer	40563	2022-05-12	0
Frankenbok	40564	2022-05-12	0
Jamy Wing	40565	2022-05-12	0
Charlie "Bird" Parker	40566	2022-05-12	0
Rhany	40567	2022-05-12	0
Son Kite	40568	2022-05-12	0
David deMaria	40569	2022-05-12	0
Ivor Cutler	40570	2022-05-12	0
Untamed	40571	2022-05-12	0
Thou Art Lord	40572	2022-05-12	0
The Brian Jacket Letdown	40573	2022-05-12	0
Jah Warrior	40574	2022-05-12	0
Never More Than Less	40575	2022-05-12	0
Hatesphere	40576	2022-05-12	0
Freedom Fighters	40577	2022-05-12	0
Azad	40578	2022-05-12	0
Peer Gunt	40579	2022-05-12	0
Clubbazz	40580	2022-05-12	0
Turbo Tabla	40581	2022-05-12	0
Tonto Irie	40582	2022-05-12	0
Al Duvall	40583	2022-05-12	0
David Archuleta	40584	2022-05-12	0
La Castañeda	40585	2022-05-12	0
The Vaughan Brothers	40586	2022-05-12	0
Les Wriggles	40587	2022-05-12	0
Juan Carlos Vega	40588	2022-05-12	0
John Wilkes Booze	40589	2022-05-12	0
Jimmy Rushing	40590	2022-05-12	0
Brooklyn Bounce vs. Sample Rippers	40591	2022-05-12	0
Philharmonia Orchestra/John Lanchbery	40592	2022-05-12	0
Pink Razors	40593	2022-05-12	0
Little Milton	40594	2022-05-12	0
Toots Thielemans	40595	2022-05-12	0
Titãs	40596	2022-05-12	0
Noor Jehan	40597	2022-05-12	0
Andy Prinz	40598	2022-05-12	0
Cephalic Carnage	40599	2022-05-12	0
Ruben Blades	40600	2022-05-12	0
Murray Perahia	40601	2022-05-12	0
Randy Katana	40602	2022-05-12	0
Public Image Ltd	40603	2022-05-12	0
Jark Prongo	40604	2022-05-12	0
Atjazz	40605	2022-05-12	0
Army Navy	40606	2022-05-12	0
Rocky Orchestra	40607	2022-05-12	0
Eye 2 Eye	40608	2022-05-12	0
Joe Strummer;The Latino Rockabilly War	40609	2022-05-12	0
Rose Maddox	40610	2022-05-12	0
PJ Pooterhoots	40611	2022-05-12	0
Angels Entity	40612	2022-05-12	0
Andres Calamaro	40613	2022-05-12	0
Melissa Horn	40614	2022-05-12	0
Patenbrigade: Wolff	40615	2022-05-12	0
Sewergrooves	40616	2022-05-12	0
Mathias Kaden	40617	2022-05-12	0
Tue West	40618	2022-05-12	0
Ramblin' Thomas & The Dallas Blues Singers	40619	2022-05-12	0
THE AD LIBS	40620	2022-05-12	0
Carlos Y José	40621	2022-05-12	0
Marta Sanchez	40622	2022-05-12	0
Ana Belén	40623	2022-05-12	0
De Souza	40624	2022-05-12	0
Grand National	40625	2022-05-12	0
Wakey!Wakey!	40626	2022-05-12	0
Microwave Dave and the Nukes	40627	2022-05-12	0
Celtas Cortos	40628	2022-05-12	0
Envy & Other Sins	40629	2022-05-12	0
Ekseption	40630	2022-05-12	0
P & Q	40631	2022-05-12	0
Alva Noto	40632	2022-05-12	0
He Is Legend	40633	2022-05-12	0
Sarah Siskind	40634	2022-05-12	0
Hank IV	40635	2022-05-12	0
Ashley MacIsaac	40636	2022-05-12	0
Loquillo	40637	2022-05-12	0
Antiloop	40638	2022-05-12	0
Telegraph Melts	40639	2022-05-12	0
Tickley Feather	40640	2022-05-12	0
Ole	40641	2022-05-12	0
Halo Of Flies	40642	2022-05-12	0
The Four Lads	40643	2022-05-12	0
Deitrick Haddon	40644	2022-05-12	0
Mangataot	40645	2022-05-12	0
John Pinette	40646	2022-05-12	0
Michelle Tumes	40647	2022-05-12	0
Sleep For Sleepers	40648	2022-05-12	0
Spearmint	40649	2022-05-12	0
Bon-Bon	40650	2022-05-12	0
Kathleen Edwards	40651	2022-05-12	0
INSITE	40652	2022-05-12	0
Bruce Hornsby	40653	2022-05-12	0
Fat Jon	40654	2022-05-12	0
Red London	40655	2022-05-12	0
Richie Arndt	40656	2022-05-12	0
Bimbo	40657	2022-05-12	0
Aya RL	40658	2022-05-12	0
The Master Musicians of Jajouka featuring Bachir Attar	40659	2022-05-12	0
Andreas Johnson	40660	2022-05-12	0
Trashmonkeys	40661	2022-05-12	0
Guitar Gangsters	40662	2022-05-12	0
Rockit	40663	2022-05-12	0
Jaheim	40664	2022-05-12	0
Dissziplin	40665	2022-05-12	0
Lucid	40666	2022-05-12	0
El Coyote	40667	2022-05-12	0
Mychael Danna_ Rob Simonsen	40668	2022-05-12	0
Lenine	40669	2022-05-12	0
Octopus Project	40670	2022-05-12	0
Absent Elk	40671	2022-05-12	0
Sisters Of Mercy	40672	2022-05-12	0
Fannypack	40673	2022-05-12	0
Agitation Free	40674	2022-05-12	0
Charles Earland	40675	2022-05-12	0
Lighthouse Family	40676	2022-05-12	0
Toru Takemitsu	40677	2022-05-12	0
The Band of HM Royal Marines	40678	2022-05-12	0
Tyler Hilton	40679	2022-05-12	0
H`ô Chí Minh	40680	2022-05-12	0
Bert Kaempfert	40681	2022-05-12	0
Khujo Goodie	40682	2022-05-12	0
Agostinho Dos Santos	40683	2022-05-12	0
The MC5	40684	2022-05-12	0
Markus Enochson and The Subliminal Kid	40685	2022-05-12	0
Zane	40686	2022-05-12	0
LL Cool J / Funkmaster Flex	40687	2022-05-12	0
Snoog	40688	2022-05-12	0
National Eye	40689	2022-05-12	0
Dick Justice	40690	2022-05-12	0
Prince Theo	40691	2022-05-12	0
Decry	40692	2022-05-12	0
The New Tradition	40693	2022-05-12	0
Air Traffic	40694	2022-05-12	0
Feel Feat. Tiff Lacey	40695	2022-05-12	0
U-Roy	40696	2022-05-12	0
Stevie Vega	40697	2022-05-12	0
Rivulets	40698	2022-05-12	0
Murder By Death	40699	2022-05-12	0
Alabama 3	40700	2022-05-12	0
The Friday Night Boys	40701	2022-05-12	0
Ray Smith	40702	2022-05-12	0
Only Living Witness	40703	2022-05-12	0
Garden Of Delight	40704	2022-05-12	0
BB Steal	40705	2022-05-12	0
Groove Armada	40706	2022-05-12	0
Jim Cuddy	40707	2022-05-12	0
The Lodger	40708	2022-05-12	0
David Crowe	40709	2022-05-12	0
Area	40710	2022-05-12	0
3 Deep	40711	2022-05-12	0
Billy Butler	40712	2022-05-12	0
Axwell & Sebastian Ingrosso	40713	2022-05-12	0
Homo Twist	40714	2022-05-12	0
YGGDRASIL	40715	2022-05-12	0
Birth Control	40716	2022-05-12	0
Eddy Raven	40717	2022-05-12	0
Steve Lacy	40718	2022-05-12	0
Player & Remady	40719	2022-05-12	0
El Tío Calambres	40720	2022-05-12	0
Andre Nickatina	40721	2022-05-12	0
Crisk.	40722	2022-05-12	0
Hannah Morris	40723	2022-05-12	0
Raised Fist	40724	2022-05-12	0
Gérard Manset	40725	2022-05-12	0
Impulss	40726	2022-05-12	0
Cochi e Renato	40727	2022-05-12	0
Pepe Braddock	40728	2022-05-12	0
D-Black featuring Chaundon	40729	2022-05-12	0
Gravitar	40730	2022-05-12	0
Hatiras	40731	2022-05-12	0
Matthew Dekay	40732	2022-05-12	0
Duke Ellington	40733	2022-05-12	0
Regina Lund	40734	2022-05-12	0
Jackson 5	40735	2022-05-12	0
Kardinal Offishall	40736	2022-05-12	0
Stephy Tang	40737	2022-05-12	0
Redjetson	40738	2022-05-12	0
BeBe Winans_ CeCe Winans	40739	2022-05-12	0
Cuddly Toys	40740	2022-05-12	0
Negative Format	40741	2022-05-12	0
Joe Liggins / The Honeydrippers	40742	2022-05-12	0
Zombie Girl	40743	2022-05-12	0
Dwayne Sodahberk	40744	2022-05-12	0
Tinie Tempah featuring Cleo Sol	40745	2022-05-12	0
Peter Green Splinter Group	40746	2022-05-12	0
Zimbabwe Legit	40747	2022-05-12	0
3Rd Alley	40748	2022-05-12	0
Ian Pooley	40749	2022-05-12	0
Nacha Pop	40750	2022-05-12	0
Trap Them	40751	2022-05-12	0
Moishe's Bagel	40752	2022-05-12	0
Marco Antonio Solís	40753	2022-05-12	0
Harper Simon	40754	2022-05-12	0
Watermelon Slim &The Workers	40755	2022-05-12	0
Public Domain	40756	2022-05-12	0
Pat Green	40757	2022-05-12	0
Tracy Bonham	40758	2022-05-12	0
Jaula de Grillos	40759	2022-05-12	0
Agonoize	40760	2022-05-12	0
Alive Stone	40761	2022-05-12	0
Gigi Finizio	40762	2022-05-12	0
The Shizit	40763	2022-05-12	0
Zanzibar	40764	2022-05-12	0
The Winnerys	40765	2022-05-12	0
Aura Noir	40766	2022-05-12	0
Eric Morris	40767	2022-05-12	0
Vacabou	40768	2022-05-12	0
Nancy LaMott	40769	2022-05-12	0
Sr Chinarro	40770	2022-05-12	0
Joshua Kadison	40771	2022-05-12	0
Common Bond	40772	2022-05-12	0
Miasma & The Carousel Of Headless Horses	40773	2022-05-12	0
Meredith Brooks	40774	2022-05-12	0
Uto Karem	40775	2022-05-12	0
Mellow Man Ace	40776	2022-05-12	0
Soman	40777	2022-05-12	0
Acumen Nation	40778	2022-05-12	0
Aquaplex	40779	2022-05-12	0
Blue Demon	40780	2022-05-12	0
Lil' Love	40781	2022-05-12	0
Dinora_ La Juventud	40782	2022-05-12	0
Cul De Sac	40783	2022-05-12	0
Dir en grey	40784	2022-05-12	0
Sham 69	40785	2022-05-12	0
Ana Torroja y Miguel Bosé	40786	2022-05-12	0
Converge	40787	2022-05-12	0
Five Deez	40788	2022-05-12	0
Torch	40789	2022-05-12	0
Zafiris Melas	40790	2022-05-12	0
Patrick O'Hearn	40791	2022-05-12	0
Robert Rodriguez	40792	2022-05-12	0
Teresa Cristina	40793	2022-05-12	0
The Beach Boys	40794	2022-05-12	0
Susan Ashton	40795	2022-05-12	0
Russ Morgan	40796	2022-05-12	0
I Love You But I've Chosen Darkness	40797	2022-05-12	0
Sandra Dahlberg	40798	2022-05-12	0
The Sutherland Brothers;Quiver	40799	2022-05-12	0
The Last Of The Bad Men	40800	2022-05-12	0
Michael Nyman	40801	2022-05-12	0
Sade	40802	2022-05-12	0
Songs:Ohia	40803	2022-05-12	0
Patti Smith Group	40804	2022-05-12	0
Willie Barcena	40805	2022-05-12	0
Näd Mika	40806	2022-05-12	0
Charlie McCoy	40807	2022-05-12	0
Claes Rosen	40808	2022-05-12	0
Jenny Wilson	40809	2022-05-12	0
Straight No Chaser	40810	2022-05-12	0
Kaos-Frequenz	40811	2022-05-12	0
Charlie Walker	40812	2022-05-12	0
Anonimo	0	2022-05-12	0
Alfa	40814	2022-05-23	7
PIO	40815	2022-05-23	8
Ame	40816	2022-05-23	9
Deo	40817	2022-05-23	0
Stazion	40819	2022-05-24	0
Carlito	40821	2022-05-27	0
aaa	40825	2022-06-08	26
cgiallo1	40826	2022-06-10	27
\.


--
-- Data for Name: canzoni; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.canzoni (id, id_artista, durata, id_genere, file, riservato, data_inserimento, extension, titolo, scadenza, data_uscita, n_riproduzioni) FROM stdin;
92872	14879	177	203	\N	f	2022-05-12	\N	Ukulele Blues	\N	2022-05-12	23
116767	3	180	191	\\x	f	2022-05-04	mp3	POI	\N	2022-05-11	6
116770	2	180	223	\\x	f	\N	mp3	Simple song	\N	2022-05-20	11
116792	40814	180	191	\\x	f	2022-05-23	mp3	titolo	2022-05-30	2022-05-02	2
116769	2	180	219	\\x	f	\N	mp3	Theme	\N	2022-05-22	7
116759	2	180	217	\\x	f	2022-05-18	mp3	Calm	\N	2022-05-13	29
92744	29590	213	209	\N	f	2022-05-12	\N	Mi ayer	\N	1996-01-01	1
116802	40821	180	191	\\x	f	2022-05-27	mp3	asdf	\N	2022-05-02	2
116794	40819	180	191	\\x	f	2022-05-24	mp3	stazione1.1	\N	2022-05-02	0
92650	25571	322	207	\N	f	2022-05-12	\N	Pantomime	\N	2022-05-12	1
92655	22298	232	194	\N	f	2022-05-12	\N	Filme De Amor	\N	2022-05-12	1
92654	15084	233	218	\N	f	2022-05-12	\N	What Is This	\N	2022-05-12	5
92643	36880	375	220	\N	f	2022-05-12	\N	Like Tears In The Rain	\N	2022-05-12	0
92644	38273	264	194	\N	f	2022-05-12	\N	Le Baggage	\N	2002-01-01	0
92645	19728	308	203	\N	f	2022-05-12	\N	Lay Ya Down Ez	\N	2022-05-12	0
92646	17032	171	224	\N	f	2022-05-12	\N	Mil horas	\N	2009-01-01	0
92647	27885	203	226	\N	f	2022-05-12	\N	Will It Got Round In Circles	\N	2022-05-12	0
92648	35468	427	216	\N	f	2022-05-12	\N	Just A Thought	\N	2008-01-01	0
92649	25000	25	229	\N	f	2022-05-12	\N	Punk Rap	\N	1987-01-01	0
92651	40574	230	191	\N	f	2022-05-12	\N	Hornsman Dub	\N	2022-05-12	0
92652	19754	438	222	\N	f	2022-05-12	\N	Basis Kanal	\N	1999-01-01	0
92653	16579	243	191	\N	f	2022-05-12	\N	Still Alive	\N	2022-05-12	0
92656	31808	146	211	\N	f	2022-05-12	\N	Perfect Motion	\N	1992-01-01	0
92657	21916	199	200	\N	f	2022-05-12	\N	Setup	\N	2022-05-12	0
92658	34157	233	212	\N	f	2022-05-12	\N	Start Me Up	\N	1981-01-01	0
92659	40674	239	218	\N	f	2022-05-12	\N	Keep on (Bonustrack)	\N	1999-01-01	0
92660	27406	300	208	\N	f	2022-05-12	\N	Bubble Gum Gangster	\N	2022-05-12	0
92661	25187	143	216	\N	f	2022-05-12	\N	One Side Blind	\N	2022-05-12	0
92662	32146	187	228	\N	f	2022-05-12	\N	Suite for Strings/I. Sarabanda. Largo	\N	2022-05-12	0
92664	34631	225	195	\N	f	2022-05-12	\N	The Liberty Bell	\N	2022-05-12	0
92642	37361	125	226	\N	f	2022-05-12	\N	So Long To the Red River Valley	\N	2005-01-01	0
92665	23523	174	212	\N	f	2022-05-12	\N	Untitled Improvisation 7	\N	2022-05-12	0
92666	25523	380	221	\N	f	2022-05-12	\N	Death Is Alive	\N	2007-01-01	0
92667	37984	197	193	\N	f	2022-05-12	\N	The Pied Piper of Punk Rock	\N	2022-05-12	0
92668	31158	328	229	\N	f	2022-05-12	\N	When Pain Comes To Surface	\N	1997-01-01	0
92669	30277	155	214	\N	f	2022-05-12	\N	Wasting Your TIme	\N	2022-05-12	0
92670	29169	291	206	\N	f	2022-05-12	\N	Goin' Crazy	\N	2005-01-01	0
92671	27659	211	209	\N	f	2022-05-12	\N	Measure	\N	2022-05-12	0
92672	36323	219	193	\N	f	2022-05-12	\N	On Thin Ice	\N	2008-01-01	0
92673	30940	170	206	\N	f	2022-05-12	\N	El Pajaro Azul	\N	2022-05-12	0
92674	20777	181	198	\N	f	2022-05-12	\N	The Wanderer	\N	1987-01-01	0
92675	26938	238	228	\N	f	2022-05-12	\N	Bad News (At The Best Of Times) (Album Version)	\N	1992-01-01	0
92676	33087	191	202	\N	f	2022-05-12	\N	Sweet Bitter Love	\N	1974-01-01	0
92677	15108	188	195	\N	f	2022-05-12	\N	Smiling And Crying The Blues	\N	2022-05-12	0
92678	21976	174	193	\N	f	2022-05-12	\N	Rapaz De Bem	\N	2008-01-01	0
92680	15600	281	207	\N	f	2022-05-12	\N	Warm Hands_ Cold Heart	\N	2022-05-12	0
92682	38907	132	220	\N	f	2022-05-12	\N	Devil's Child (Album Version)	\N	2022-05-12	0
92683	16040	249	193	\N	f	2022-05-12	\N	Thatz West For You	\N	2022-05-12	0
92684	24856	235	219	\N	f	2022-05-12	\N	Cross My Broken Heart	\N	1994-01-01	0
92685	33346	194	211	\N	f	2022-05-12	\N	En Fa Menor	\N	2006-01-01	0
92686	27384	147	195	\N	f	2022-05-12	\N	Never Never Land (Ooh-La) (1999 Digital Remaster)	\N	2022-05-12	0
92687	30770	105	225	\N	f	2022-05-12	\N	Chiaroscuro	\N	2022-05-12	0
92688	16876	108	218	\N	f	2022-05-12	\N	River Of Salt (1999 Digital Remaster)	\N	1973-01-01	0
92689	39729	200	197	\N	f	2022-05-12	\N	Jackie	\N	2022-05-12	0
92690	18288	341	199	\N	f	2022-05-12	\N	Hear Me (Buraka Som Sistema Remix)	\N	2007-01-01	0
92691	22631	309	191	\N	f	2022-05-12	\N	Shaking like beyonce	\N	2022-05-12	0
92692	20271	246	209	\N	f	2022-05-12	\N	Jazz E Blues	\N	2022-05-12	0
92693	38800	221	215	\N	f	2022-05-12	\N	Island Echoes	\N	1994-01-01	0
92694	22395	156	207	\N	f	2022-05-12	\N	Tell It To The Rain (LP Version)	\N	2022-05-12	0
92695	27050	142	212	\N	f	2022-05-12	\N	Ain't That Loving You Baby	\N	1973-01-01	0
92696	26818	231	206	\N	f	2022-05-12	\N	Cryme to Rhyme	\N	2022-05-12	0
92697	26245	80	201	\N	f	2022-05-12	\N	Prologue	\N	2005-01-01	0
92698	18671	220	217	\N	f	2022-05-12	\N	It Takes More (MHS Version)	\N	2022-05-12	0
92699	32134	164	219	\N	f	2022-05-12	\N	Sanctus	\N	2022-05-12	0
92700	24627	479	214	\N	f	2022-05-12	\N	Smaq	\N	2022-05-12	0
92701	36357	165	200	\N	f	2022-05-12	\N	Bad Mongo (Live)	\N	2022-05-12	0
92702	20418	280	216	\N	f	2022-05-12	\N	He Vuelto Por Ti	\N	2022-05-12	0
92703	26228	377	220	\N	f	2022-05-12	\N	Il Non-illuminato	\N	2009-01-01	0
92704	40457	233	225	\N	f	2022-05-12	\N	Something About A Dog	\N	2006-01-01	0
92705	21880	235	221	\N	f	2022-05-12	\N	Baila	\N	1999-01-01	0
92706	27175	163	226	\N	f	2022-05-12	\N	Monochrome Rainbow	\N	2009-01-01	0
92707	35526	85	197	\N	f	2022-05-12	\N	Mad Man On The Loose	\N	2022-05-12	0
92708	22798	182	230	\N	f	2022-05-12	\N	I'm Sorry (LP Version)	\N	1992-01-01	0
92681	19102	122	202	\N	f	2022-05-12	\N	Westchester Hadassah (Album Version)	\N	2022-05-12	1
92711	34507	557	230	\N	f	2022-05-12	\N	Shoegazer Disco (Roberto Rodriguez Remix)	\N	2022-05-12	0
92712	26642	290	225	\N	f	2022-05-12	\N	Lean Back [Remix feat. Lil Jon_ Eminem_ Mase & Remy Martin] (Album Version - Explicit)	\N	2005-01-01	0
92713	40704	310	218	\N	f	2022-05-12	\N	Somniorum Iterpretatio	\N	1993-01-01	0
92714	27619	199	207	\N	f	2022-05-12	\N	Ora C'E' Patrizia	\N	2022-05-12	0
92715	21105	338	191	\N	f	2022-05-12	\N	Sonnendeck	\N	2001-01-01	0
92716	19018	224	219	\N	f	2022-05-12	\N	Another Lesson	\N	2005-01-01	0
92717	25822	256	199	\N	f	2022-05-12	\N	Paper Tigers	\N	1983-01-01	0
92718	33112	202	218	\N	f	2022-05-12	\N	Tennis Players Girlfriends	\N	1998-01-01	0
92719	32304	242	203	\N	f	2022-05-12	\N	Lover Boy	\N	1997-01-01	0
92720	23926	179	210	\N	f	2022-05-12	\N	Saudade fez um samba	\N	2022-05-12	0
92721	19441	245	230	\N	f	2022-05-12	\N	Huntsville Affair	\N	2006-01-01	0
92722	39477	173	217	\N	f	2022-05-12	\N	Maximum Overdrive	\N	1989-01-01	0
92723	29151	140	192	\N	f	2022-05-12	\N	Inútil	\N	1999-01-01	0
92724	34284	297	215	\N	f	2022-05-12	\N	Thousand Mile Wish	\N	2003-01-01	0
92725	25393	332	198	\N	f	2022-05-12	\N	Spice	\N	2022-05-12	0
92726	25161	264	216	\N	f	2022-05-12	\N	Something Out Of Nothing	\N	2009-01-01	0
92727	39929	183	202	\N	f	2022-05-12	\N	Tomorrow Man	\N	2008-01-01	0
92728	37818	152	220	\N	f	2022-05-12	\N	Red Hot	\N	1986-01-01	0
92729	17600	276	211	\N	f	2022-05-12	\N	Passe mezo a la bolognesa	\N	2022-05-12	0
92730	21218	344	208	\N	f	2022-05-12	\N	My World	\N	2022-05-12	0
92731	37992	355	228	\N	f	2022-05-12	\N	Climb On Top (D.O.N.S. Weired Sweety Mix)	\N	2022-05-12	0
92732	37609	98	210	\N	f	2022-05-12	\N	Best Form	\N	2022-05-12	0
92733	26661	266	220	\N	f	2022-05-12	\N	Love Missile F1-11	\N	1986-01-01	0
92734	39099	180	199	\N	f	2022-05-12	\N	Jah Heavy Load	\N	1978-01-01	0
92745	15357	181	198	\N	f	2022-05-12	\N	Playing In The Wood	\N	2022-05-12	5
92735	24255	260	215	\N	f	2022-05-12	\N	Birds Of A Feather (2002 Digital Remaster)	\N	2002-01-01	0
92736	32865	172	211	\N	f	2022-05-12	\N	Streetgang Pt. 2	\N	2008-01-01	0
92737	34982	147	226	\N	f	2022-05-12	\N	Rhyw Dachwedd Yn Hwyr	\N	2022-05-12	0
92738	17735	208	196	\N	f	2022-05-12	\N	Them Good Old Times Are Coming Back Again	\N	1998-01-01	0
92739	36732	213	198	\N	f	2022-05-12	\N	No Volvere	\N	2022-05-12	0
92740	17071	177	221	\N	f	2022-05-12	\N	You are the Song	\N	2022-05-12	0
92741	19028	223	216	\N	f	2022-05-12	\N	Diplômé De Toi	\N	2001-01-01	0
92742	34620	217	227	\N	f	2022-05-12	\N	Urge For Going [Single Version]	\N	2022-05-12	0
92746	32524	308	215	\N	f	2022-05-12	\N	Death In Fire (Live)	\N	2006-01-01	0
92747	35768	223	197	\N	f	2022-05-12	\N	Bastione di Saint Remy	\N	2022-05-12	0
92748	21345	128	227	\N	f	2022-05-12	\N	I Don't Want To Hear It	\N	2022-05-12	0
92749	15741	215	193	\N	f	2022-05-12	\N	Mountains	\N	2007-01-01	0
92750	17431	329	204	\N	f	2022-05-12	\N	To The Ends Of The Earth	\N	1995-01-01	0
92751	21741	381	230	\N	f	2022-05-12	\N	You Never Know What You Got	\N	1993-01-01	0
92752	34318	154	213	\N	f	2022-05-12	\N	Zilch The Pimp	\N	2003-01-01	0
92753	24789	182	221	\N	f	2022-05-12	\N	Plantation Boogie	\N	1971-01-01	0
92754	19283	342	207	\N	f	2022-05-12	\N	Vampires	\N	2007-01-01	0
92743	37045	253	222	\N	f	2022-05-12	\N	The Obituary (E.B.G.G.)	\N	2008-01-01	5
92755	38398	158	217	\N	f	2022-05-12	\N	All About My Woman	\N	2022-05-12	0
92757	19026	485	216	\N	f	2022-05-12	\N	Eternal Glory	\N	2022-05-12	0
92758	40023	322	219	\N	f	2022-05-12	\N	Change Myself (2006 Remastered Version)	\N	2022-05-12	0
92759	29335	285	218	\N	f	2022-05-12	\N	Uninvited Visitor	\N	2022-05-12	0
92760	18687	57	201	\N	f	2022-05-12	\N	Postmeridian	\N	2002-01-01	0
92761	37175	185	228	\N	f	2022-05-12	\N	Water Shed	\N	2022-05-12	0
92762	21048	454	193	\N	f	2022-05-12	\N	Kawaii (Literon remix)	\N	2022-05-12	0
92763	17898	340	199	\N	f	2022-05-12	\N	Never Seen Your Face (Adam Sky Tantric Bass Mix)	\N	2022-05-12	0
92764	23551	217	199	\N	f	2022-05-12	\N	Come On Ya'll (Instrumental)	\N	2022-05-12	0
92765	25180	288	214	\N	f	2022-05-12	\N	Roll Over	\N	2009-01-01	0
92766	32272	96	230	\N	f	2022-05-12	\N	The Holocaust Cantata: Singing from Birth to Death	\N	2022-05-12	0
92767	38011	171	197	\N	f	2022-05-12	\N	Quietly As I Sleep	\N	2022-05-12	0
92768	35793	291	210	\N	f	2022-05-12	\N	Always There	\N	2008-01-01	0
92769	19586	27	223	\N	f	2022-05-12	\N	Work Ethic	\N	2006-01-01	0
92770	25027	59	210	\N	f	2022-05-12	\N	Magtanim Ay Di Biro (Planting Rice)	\N	2022-05-12	0
92771	16084	194	198	\N	f	2022-05-12	\N	Quest Pistols pati	\N	2022-05-12	0
92772	30959	171	206	\N	f	2022-05-12	\N	Working On A Building	\N	2022-05-12	0
92773	31594	481	223	\N	f	2022-05-12	\N	Voices of Istanbul	\N	2022-05-12	0
92774	25121	199	213	\N	f	2022-05-12	\N	Kidnapped	\N	2022-05-12	0
92775	28547	163	199	\N	f	2022-05-12	\N	Layer #1	\N	2022-05-12	0
92776	17299	488	204	\N	f	2022-05-12	\N	Planet	\N	2001-01-01	0
92777	19106	266	202	\N	f	2022-05-12	\N	Uschba	\N	1996-01-01	0
92778	15492	266	222	\N	f	2022-05-12	\N	Gratitude	\N	2022-05-12	0
92780	20076	170	202	\N	f	2022-05-12	\N	Candy And Women	\N	2022-05-12	0
92781	31658	263	222	\N	f	2022-05-12	\N	Rosie	\N	1992-01-01	0
92782	15842	99	229	\N	f	2022-05-12	\N	M.E.X.I.C.O.	\N	2008-01-01	0
92783	39089	316	215	\N	f	2022-05-12	\N	Help Is On The Way	\N	2008-01-01	0
92784	33029	377	199	\N	f	2022-05-12	\N	Pressure	\N	2005-01-01	0
92785	37639	76	203	\N	f	2022-05-12	\N	Alone In His Presence (Reprise)	\N	2022-05-12	0
92786	33194	153	211	\N	f	2022-05-12	\N	But Not For Me (2005 Digital Remaster)	\N	2022-05-12	0
92787	34938	192	209	\N	f	2022-05-12	\N	No Man's Land	\N	2022-05-12	0
92788	28512	299	192	\N	f	2022-05-12	\N	Lilac Wine	\N	1981-01-01	0
92789	17009	326	213	\N	f	2022-05-12	\N	Leave Me	\N	2022-05-12	0
92790	36432	192	200	\N	f	2022-05-12	\N	Non C'sera Non (Omri Omri)	\N	2022-05-12	0
92791	31997	195	195	\N	f	2022-05-12	\N	Crimson	\N	2001-01-01	0
92792	38701	274	211	\N	f	2022-05-12	\N	The Day You Went Away	\N	1992-01-01	0
92793	26450	193	195	\N	f	2022-05-12	\N	Let You Down	\N	2022-05-12	0
92794	34930	116	209	\N	f	2022-05-12	\N	Bashy.com Skit	\N	2008-01-01	0
92795	36462	216	194	\N	f	2022-05-12	\N	Your 45 (LP Version)	\N	2004-01-01	0
92796	40700	225	229	\N	f	2022-05-12	\N	Shake A Tailfether	\N	2022-05-12	0
92797	34755	426	230	\N	f	2022-05-12	\N	Magilla	\N	2022-05-12	0
92798	35885	240	226	\N	f	2022-05-12	\N	Superfly (LP Version)	\N	2022-05-12	0
92799	22891	496	230	\N	f	2022-05-12	\N	Departures	\N	2022-05-12	0
92800	38109	237	192	\N	f	2022-05-12	\N	My Fate	\N	2022-05-12	0
92801	36755	257	204	\N	f	2022-05-12	\N	Somewhere More	\N	2003-01-01	0
92802	31242	194	226	\N	f	2022-05-12	\N	Zip (from Pal Joey)	\N	2022-05-12	0
92803	21526	496	195	\N	f	2022-05-12	\N	Hide Away	\N	2022-05-12	0
92804	21104	105	202	\N	f	2022-05-12	\N	Intocable	\N	2004-01-01	0
92806	32946	210	198	\N	f	2022-05-12	\N	As Soon As I Find My Voice	\N	2022-05-12	0
92807	21992	278	198	\N	f	2022-05-12	\N	I'll Be Alright (Album Version)	\N	2001-01-01	0
92808	35352	266	223	\N	f	2022-05-12	\N	Royal Jelly	\N	2007-01-01	0
92809	26451	89	211	\N	f	2022-05-12	\N	Showdown	\N	1996-01-01	0
92810	31003	252	201	\N	f	2022-05-12	\N	Que Je T'Aime	\N	1969-01-01	0
92811	22772	206	218	\N	f	2022-05-12	\N	The Sound	\N	2022-05-12	0
92813	40595	212	211	\N	f	2022-05-12	\N	O Futebol	\N	1993-01-01	0
92814	16995	78	195	\N	f	2022-05-12	\N	Fingertips 9 - Please Pass The Milk (LP Version)	\N	1992-01-01	0
92815	30897	281	220	\N	f	2022-05-12	\N	Too Long	\N	1996-01-01	0
92816	29841	236	224	\N	f	2022-05-12	\N	Follow the Leader	\N	2002-01-01	0
92817	33620	212	213	\N	f	2022-05-12	\N	Bregendance	\N	2022-05-12	0
92818	33103	191	198	\N	f	2022-05-12	\N	Just Apathy (Album Version)	\N	2005-01-01	0
92819	31798	100	218	\N	f	2022-05-12	\N	Frogbashing	\N	2022-05-12	0
92820	30634	133	203	\N	f	2022-05-12	\N	Joy To The World	\N	1997-01-01	0
92821	35466	169	207	\N	f	2022-05-12	\N	Juez Y Testigo	\N	2022-05-12	0
92822	35074	208	208	\N	f	2022-05-12	\N	The Dance At Delmonico's	\N	2022-05-12	0
92823	37717	460	201	\N	f	2022-05-12	\N	Himalaya (Remastered Promo Single)	\N	1997-01-01	0
92824	32528	216	192	\N	f	2022-05-12	\N	Let It Be Known	\N	2007-01-01	0
92825	0	279	212	\N	f	2022-05-12	\N	Some Things	\N	1999-01-01	0
92826	23579	430	195	\N	f	2022-05-12	\N	Last Night I Dreamt That Somebody Loved Me	\N	2022-05-12	0
92827	28425	230	222	\N	f	2022-05-12	\N	Answering Machine	\N	2022-05-12	0
92830	18980	265	215	\N	f	2022-05-12	\N	Al Mercato Dell'usato	\N	2022-05-12	0
92831	34964	275	212	\N	f	2022-05-12	\N	Where Do You Start	\N	1992-01-01	0
92832	27343	32	220	\N	f	2022-05-12	\N	1:00 P.M. - Saturday	\N	2022-05-12	0
92835	23205	236	224	\N	f	2022-05-12	\N	Quiero Que Vuelvas	\N	2022-05-12	0
92836	23005	195	213	\N	f	2022-05-12	\N	Mid Tempo Song	\N	2022-05-12	0
92837	21853	187	210	\N	f	2022-05-12	\N	Päivänsäde ja menninkäinen	\N	2022-05-12	0
92839	26264	212	214	\N	f	2022-05-12	\N	Its The Hornet	\N	2022-05-12	0
92840	25552	261	229	\N	f	2022-05-12	\N	Plan 9	\N	1992-01-01	0
92841	23826	205	199	\N	f	2022-05-12	\N	Blah Blah Café	\N	2022-05-12	0
92842	26493	190	199	\N	f	2022-05-12	\N	Substitute for love	\N	2005-01-01	0
92843	18733	155	223	\N	f	2022-05-12	\N	My Baby is Gone (Album Version)	\N	2022-05-12	0
92844	40604	314	224	\N	f	2022-05-12	\N	Don't Stop	\N	1999-01-01	0
92845	35805	208	217	\N	f	2022-05-12	\N	Rhythm Of The Night	\N	2022-05-12	0
92846	23935	235	226	\N	f	2022-05-12	\N	Lift (Lift Album Version)	\N	2001-01-01	0
92847	18568	463	221	\N	f	2022-05-12	\N	Plainsong (Album Version)	\N	2022-05-12	0
92848	37057	289	196	\N	f	2022-05-12	\N	A Mexican Funderal in Paris	\N	1995-01-01	0
92849	33982	273	218	\N	f	2022-05-12	\N	Here Come The Ghosts	\N	2005-01-01	0
92828	15786	251	223	\N	f	2022-05-12	\N	Wasteland	\N	2005-01-01	1
92756	25261	105	196	\N	f	2022-05-12	\N	Real Thing	\N	2022-05-12	3
92833	15360	221	218	\N	f	2022-05-12	\N	I Don't Wanna	\N	1999-01-01	11
92850	33884	141	217	\N	f	2022-05-12	\N	Lightshow	\N	2002-01-01	0
92851	26279	126	203	\N	f	2022-05-12	\N	Magic Balls_ Conclusion	\N	2022-05-12	0
92852	21093	365	209	\N	f	2022-05-12	\N	Bura Musow Diougou	\N	2022-05-12	0
92853	39675	170	218	\N	f	2022-05-12	\N	Whoopin' Thighs	\N	2022-05-12	0
92854	39317	307	226	\N	f	2022-05-12	\N	Everything Falls (Album Version)	\N	2006-01-01	0
92855	17822	158	220	\N	f	2022-05-12	\N	Christmas Prayer	\N	2022-05-12	0
92856	30815	277	192	\N	f	2022-05-12	\N	La Florecita	\N	2022-05-12	0
92857	25861	227	195	\N	f	2022-05-12	\N	A Little Bit	\N	2001-01-01	0
92858	37870	181	205	\N	f	2022-05-12	\N	Eau	\N	2001-01-01	0
92859	40702	134	218	\N	f	2022-05-12	\N	Little Miss Blue	\N	2022-05-12	0
92861	33803	144	201	\N	f	2022-05-12	\N	Once Upon a Time	\N	2008-01-01	0
92863	37115	265	221	\N	f	2022-05-12	\N	Girl_ You´ll Be A Women Soon	\N	2022-05-12	0
92864	32721	323	203	\N	f	2022-05-12	\N	5 O'Clock Suff	\N	2022-05-12	0
92865	23886	273	227	\N	f	2022-05-12	\N	Rain	\N	1976-01-01	0
92866	36257	205	220	\N	f	2022-05-12	\N	Peace Time Now	\N	1999-01-01	0
92867	33096	106	198	\N	f	2022-05-12	\N	Happiness	\N	2005-01-01	0
92868	27848	282	197	\N	f	2022-05-12	\N	Por Causa De Você / Dindi	\N	2022-05-12	0
92869	18220	233	218	\N	f	2022-05-12	\N	Kick Luck	\N	2022-05-12	0
92870	19123	217	200	\N	f	2022-05-12	\N	Quisiera	\N	2022-05-12	0
92871	23798	239	196	\N	f	2022-05-12	\N	Le Dandy	\N	2022-05-12	0
92873	20629	294	201	\N	f	2022-05-12	\N	LoveStoned/I Think She Knows	\N	2007-01-01	0
92874	17808	167	216	\N	f	2022-05-12	\N	Jestes Fajna Kobieta	\N	2006-01-01	0
92875	18028	215	200	\N	f	2022-05-12	\N	Do You Mind? (Instrumental Version)	\N	2022-05-12	0
92876	27597	329	194	\N	f	2022-05-12	\N	The Hexagon	\N	2022-05-12	0
92877	36816	187	218	\N	f	2022-05-12	\N	M is for Memo	\N	2022-05-12	0
92878	37578	398	222	\N	f	2022-05-12	\N	E-Merge	\N	2002-01-01	0
92879	31442	434	191	\N	f	2022-05-12	\N	Trip Like I Do	\N	1997-01-01	0
92880	18214	192	216	\N	f	2022-05-12	\N	These Birds Will Kill Us All	\N	2022-05-12	0
92881	29196	267	219	\N	f	2022-05-12	\N	Some Places	\N	2022-05-12	0
92882	25894	315	204	\N	f	2022-05-12	\N	Rebellious Love	\N	2022-05-12	0
92883	17760	377	227	\N	f	2022-05-12	\N	Yad V Serdtse	\N	2022-05-12	0
92884	22612	252	222	\N	f	2022-05-12	\N	Street Tax (Clean Version)	\N	2001-01-01	0
92885	30379	283	214	\N	f	2022-05-12	\N	Saving Time	\N	2022-05-12	0
92886	19593	278	211	\N	f	2022-05-12	\N	Nothing	\N	2022-05-12	0
92887	37511	209	209	\N	f	2022-05-12	\N	Get Busy	\N	2022-05-12	0
92888	18259	217	197	\N	f	2022-05-12	\N	Phone Booth Man (P.B.M.) (LP Version)	\N	2022-05-12	0
92889	32793	284	217	\N	f	2022-05-12	\N	Give Some Space	\N	2022-05-12	0
92890	40808	480	206	\N	f	2022-05-12	\N	Genuine	\N	2022-05-12	0
92891	31134	254	221	\N	f	2022-05-12	\N	BROTHER	\N	2022-05-12	0
92892	31474	148	228	\N	f	2022-05-12	\N	Bells Never Had A Sweeter Sound	\N	2022-05-12	0
92893	32494	236	201	\N	f	2022-05-12	\N	Crocodile Skin	\N	2022-05-12	0
92894	32828	170	192	\N	f	2022-05-12	\N	Ring-A-Levio	\N	2001-01-01	0
92895	38977	188	191	\N	f	2022-05-12	\N	Why Doesn't Anybody Like Me?	\N	1999-01-01	0
92896	24323	401	226	\N	f	2022-05-12	\N	Hands Around My Throat	\N	2022-05-12	0
92897	35313	210	209	\N	f	2022-05-12	\N	Blitzkrieg Bop	\N	2004-01-01	0
92898	19746	179	207	\N	f	2022-05-12	\N	Catamaran (LP Version)	\N	1995-01-01	0
92899	30850	245	228	\N	f	2022-05-12	\N	Golden	\N	2022-05-12	0
92900	30535	263	214	\N	f	2022-05-12	\N	Lonely Girl	\N	2009-01-01	0
92901	23473	322	193	\N	f	2022-05-12	\N	Symphony No. 3 in D major D200 (1996 Digital Remaster): IV.    Presto vivace	\N	2022-05-12	0
92902	19180	510	224	\N	f	2022-05-12	\N	Guns.Guns...Guns	\N	2022-05-12	0
92904	15433	331	230	\N	f	2022-05-12	\N	Armónicos en el Silencio	\N	2022-05-12	0
92905	25250	49	192	\N	f	2022-05-12	\N	World War 4 (Live)	\N	2022-05-12	0
92906	31163	423	193	\N	f	2022-05-12	\N	Tabla and Mridangam	\N	2022-05-12	0
92908	26539	201	210	\N	f	2022-05-12	\N	All Out	\N	2022-05-12	0
92909	37643	213	230	\N	f	2022-05-12	\N	Prison Bound Blues (LP Version)	\N	2022-05-12	0
92910	40639	271	193	\N	f	2022-05-12	\N	Canto Primo	\N	1999-01-01	0
92912	23489	112	207	\N	f	2022-05-12	\N	Sailing	\N	2007-01-01	0
92913	35493	124	229	\N	f	2022-05-12	\N	Dave Normaway MacDonald's Wedding	\N	2022-05-12	0
92914	21657	129	222	\N	f	2022-05-12	\N	Quem	\N	2022-05-12	0
92915	35766	246	211	\N	f	2022-05-12	\N	Drinkin' Rum	\N	2022-05-12	0
92916	28338	221	222	\N	f	2022-05-12	\N	No Room 4 Growth (clean version)	\N	2022-05-12	0
92917	15747	189	205	\N	f	2022-05-12	\N	Move It Up (Muévela)	\N	2022-05-12	0
92918	31032	180	195	\N	f	2022-05-12	\N	One More Time Billy Brown	\N	2022-05-12	0
92919	38221	456	203	\N	f	2022-05-12	\N	After The Storm	\N	2008-01-01	0
92920	33333	268	224	\N	f	2022-05-12	\N	Show it 4 Da Camera	\N	2022-05-12	0
92921	28385	147	204	\N	f	2022-05-12	\N	My Balls/Your Chin	\N	1987-01-01	0
92922	25538	270	199	\N	f	2022-05-12	\N	Eyeleo	\N	2022-05-12	0
92923	24412	158	221	\N	f	2022-05-12	\N	Pull up your belt and dance	\N	2022-05-12	0
92924	34313	33	213	\N	f	2022-05-12	\N	Skit	\N	2022-05-12	0
92925	20206	167	229	\N	f	2022-05-12	\N	If There Is Someone Lovlier Than You	\N	2022-05-12	0
92926	40450	334	201	\N	f	2022-05-12	\N	Mask	\N	2007-01-01	0
92927	28102	179	214	\N	f	2022-05-12	\N	Tight Time Blues	\N	2022-05-12	0
92928	30690	287	229	\N	f	2022-05-12	\N	Daleka Obala	\N	2022-05-12	0
92929	29907	184	191	\N	f	2022-05-12	\N	Rancher's Daughter	\N	2022-05-12	0
92930	17953	146	213	\N	f	2022-05-12	\N	Princess Resistance	\N	2007-01-01	0
92931	26854	370	223	\N	f	2022-05-12	\N	Please Send Me Someone to Love	\N	1957-01-01	0
92932	17288	256	200	\N	f	2022-05-12	\N	Chocolate Swastika	\N	2022-05-12	0
92933	16797	266	201	\N	f	2022-05-12	\N	Sedm statecnych	\N	2022-05-12	0
92934	37251	191	229	\N	f	2022-05-12	\N	Gunslinger Man	\N	1987-01-01	0
92935	21075	164	226	\N	f	2022-05-12	\N	Blanca	\N	2022-05-12	0
92936	39603	145	192	\N	f	2022-05-12	\N	Sleep On	\N	1992-01-01	0
92937	22323	190	216	\N	f	2022-05-12	\N	Fat Gut Strut	\N	2005-01-01	0
92938	26842	217	209	\N	f	2022-05-12	\N	Son Of Man (Eden's Bridge 2002 Remixed And Remastered)	\N	2022-05-12	0
92939	27279	321	203	\N	f	2022-05-12	\N	The Warmth	\N	1999-01-01	0
92940	26307	368	220	\N	f	2022-05-12	\N	Sophie Tucker and Tallulah Bankhead Give Advice	\N	2022-05-12	0
92941	32015	242	202	\N	f	2022-05-12	\N	Setting of the Sun	\N	2002-01-01	0
92860	15241	156	213	\N	f	2022-05-12	\N	Hot Toddy	\N	2002-01-01	2
92911	16399	198	210	\N	f	2022-05-12	\N	Her Best Words Were Goodbye	\N	2022-05-12	2
92903	37830	223	197	\N	f	2022-05-12	\N	Lua (Não Há Outra Assim)	\N	2022-05-12	2
92942	40395	247	203	\N	f	2022-05-12	\N	Jesus Call Your Lambs	\N	2022-05-12	0
92943	21707	168	208	\N	f	2022-05-12	\N	I See It In Us	\N	2022-05-12	0
92944	32068	240	192	\N	f	2022-05-12	\N	Ya Yo No	\N	2004-01-01	0
92945	18448	382	221	\N	f	2022-05-12	\N	Tabou	\N	2022-05-12	0
92947	32827	244	194	\N	f	2022-05-12	\N	Who We Are	\N	2002-01-01	0
92948	17563	286	211	\N	f	2022-05-12	\N	Aquário	\N	2022-05-12	0
92950	36042	14	194	\N	f	2022-05-12	\N	Dan Dan Dan	\N	1998-01-01	0
92951	40713	465	218	\N	f	2022-05-12	\N	Together	\N	2005-01-01	0
92952	23671	303	192	\N	f	2022-05-12	\N	The blade of cain	\N	2004-01-01	0
92953	18791	246	193	\N	f	2022-05-12	\N	The Birthday Song	\N	2003-01-01	0
92954	34831	718	220	\N	f	2022-05-12	\N	Lord Worm	\N	2002-01-01	0
92955	32720	390	223	\N	f	2022-05-12	\N	Holy One	\N	2022-05-12	0
92956	16265	203	201	\N	f	2022-05-12	\N	What Have I Done	\N	2008-01-01	0
92957	21728	328	212	\N	f	2022-05-12	\N	What Deers May Come	\N	2001-01-01	0
92958	22159	354	214	\N	f	2022-05-12	\N	YOU'VE GOT A FRIEND	\N	2022-05-12	0
92959	34643	314	228	\N	f	2022-05-12	\N	At the Still Point of the Turning World	\N	2005-01-01	0
92960	26686	293	201	\N	f	2022-05-12	\N	The Big Dipper	\N	1996-01-01	0
92961	27931	142	201	\N	f	2022-05-12	\N	The Q5 Piano Tune (1999 Digital Remaster)	\N	2022-05-12	0
92962	16949	212	199	\N	f	2022-05-12	\N	2 Good 2 B True	\N	2002-01-01	0
92963	32651	219	205	\N	f	2022-05-12	\N	It's A Hard Life	\N	1992-01-01	0
92964	38510	333	197	\N	f	2022-05-12	\N	my theme song	\N	2022-05-12	0
92965	23265	216	203	\N	f	2022-05-12	\N	Happy	\N	2022-05-12	0
92966	27249	256	200	\N	f	2022-05-12	\N	Can't Be Asked	\N	2007-01-01	0
92967	0	417	191	\N	f	2022-05-12	\N	Immersion	\N	2022-05-12	0
92968	0	214	193	\N	f	2022-05-12	\N	Voices On A String (Album Version)	\N	2007-01-01	0
92969	38369	200	217	\N	f	2022-05-12	\N	Lopez O.S.T	\N	2022-05-12	0
92970	28203	22	193	\N	f	2022-05-12	\N	De E Slut	\N	2022-05-12	0
92971	33420	220	229	\N	f	2022-05-12	\N	Ein Stern_ der deinen Namen trägt	\N	2022-05-12	0
92972	33824	211	215	\N	f	2022-05-12	\N	Flesh 'N' Blood	\N	2022-05-12	0
92973	19048	357	230	\N	f	2022-05-12	\N	Round And Round	\N	2007-01-01	0
92974	15677	458	201	\N	f	2022-05-12	\N	Playing In The Band (Album Version)	\N	2022-05-12	0
92975	20169	21	224	\N	f	2022-05-12	\N	Here's the song_ Cindy	\N	2022-05-12	0
92976	22591	38	201	\N	f	2022-05-12	\N	Sick Of Talk (Negative Approach)	\N	2009-01-01	0
92977	0	220	207	\N	f	2022-05-12	\N	Nowhere To Run	\N	1992-01-01	0
92978	17042	209	219	\N	f	2022-05-12	\N	I'm Comin' Back	\N	2022-05-12	0
92979	32973	406	220	\N	f	2022-05-12	\N	Island Twenty-four	\N	2022-05-12	0
92980	23423	145	200	\N	f	2022-05-12	\N	Faut pas s'leurrer (Live)	\N	2022-05-12	0
92981	27113	239	198	\N	f	2022-05-12	\N	Anamnisis	\N	2022-05-12	0
92982	34780	161	218	\N	f	2022-05-12	\N	Tribal War	\N	2022-05-12	0
92983	24531	294	201	\N	f	2022-05-12	\N	Out On The Streets (New Acoustic Version 2009)	\N	2022-05-12	0
92984	37218	118	210	\N	f	2022-05-12	\N	Trust Me (Andy Kershaw Session - 16th Oct 90)	\N	2022-05-12	0
92985	36245	21	229	\N	f	2022-05-12	\N	Small Town	\N	2005-01-01	0
92986	37735	193	192	\N	f	2022-05-12	\N	Do It Again	\N	1959-01-01	0
92987	38991	164	196	\N	f	2022-05-12	\N	You Just Can't Have It All	\N	2003-01-01	0
92988	17531	219	192	\N	f	2022-05-12	\N	You're Like The Breeze	\N	2004-01-01	0
92989	25247	174	226	\N	f	2022-05-12	\N	Progression	\N	1994-01-01	0
92990	38184	205	206	\N	f	2022-05-12	\N	Banks Of the Bann	\N	1983-01-01	0
92991	39372	304	226	\N	f	2022-05-12	\N	Into the Fire	\N	2022-05-12	0
92992	28912	248	224	\N	f	2022-05-12	\N	Black Sheep	\N	2001-01-01	0
92993	31832	313	208	\N	f	2022-05-12	\N	De Oya Y Abacua	\N	2001-01-01	0
92994	20108	167	220	\N	f	2022-05-12	\N	Kitchen Sink (Sixtoo Remix)	\N	2007-01-01	0
92995	19450	251	196	\N	f	2022-05-12	\N	Bout Dat	\N	2007-01-01	0
92996	40248	468	203	\N	f	2022-05-12	\N	Captured	\N	2022-05-12	0
92997	38882	220	215	\N	f	2022-05-12	\N	Get Blown Away	\N	2022-05-12	0
92998	21417	326	198	\N	f	2022-05-12	\N	Gardens Of The Sinner (live)	\N	2022-05-12	0
93000	16901	223	199	\N	f	2022-05-12	\N	Rise	\N	2006-01-01	0
116766	3	180	191	\\x	f	2022-06-01	mp3	As it was	\N	2022-05-02	25
92946	24678	359	191	\N	f	2022-05-12	\N	Mi Vida	\N	2022-05-12	1
116760	3	180	191	\\x	f	2022-05-01	mp3	Else	\N	2022-05-13	9
92999	39623	222	214	\N	f	2022-05-12	\N	Home	\N	2008-01-01	2
92949	28558	85	198	\N	f	2022-05-12	\N	Main Title (Film Version from 'Anthony Adverse')	\N	2022-05-12	1
\.


--
-- Data for Name: generi_musicali; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.generi_musicali (id_genere, descrizione, nome) FROM stdin;
191	Un esperimento pop con influenze jazz (Incognito/ Dirotta su Cuba).	Acid Jazz
192	Una musica popolare figlia degli spiritual e spesso malinconica (il colore blue infatti in America è simbolo della malinconia) nata sotto la matrice dei canti di lavoro degli schiavi neri americani.	Blues
193	E' l'evoluzione classico / melodica (spesso con inserti di tastiere) ma contemporaneamente più brutale del Death Metal	Black Metal
194	Musica inventata negli ultimi due anni in cui l'elemento base diventa il campionatore con cui i gruppi attingono ai più diversi e strani generi musicali unendoli tra di loro in una sorta di ordinata confusione (vedi Prodigy, Chimical Brothers & Daft Punk)	Chemical Beat
195	Rappresenta culturalmente il liscio USA, è un genere più movimentato rispetto a quello italiano ed è suonato con chitarre, banjo e violini. Deriva dalle musiche folk importate dai coloni inglesi in America	Country
196	Attualmente è una corrente in cui vengono mischiati elementi rap e metal (e a volte anche altri generi)	Crossover
197	Musica rock / pop in cui i testi e le musiche sono incentrati sulla malinconia o sulla tristezza (Cure ecc.)	Dark
198	E' un metal spinto in versione horror, il kaos e la violenza organizzati, l'unione di suoni melodici con suoni molto grezzi	Death Metal
199	Tendenza del metal classico caratterizzata da testi epicheggianti e rimandi storici di battaglie ed eroi (Manowar)	Epic Metal
200	Il genere folkloristico è basato sulle musiche storiche / temi tradizionali di un determinato paese.	Folk
201	Il funky è una musica simile all'hip-hop molto allegra e ritmata proveniente dagli USA, nata negli anni '70 nei ghetti americani	Funky
202	Hard rock con cantanti o gruppi vestiti e truccati per far scena e spettacolo (Kiss e Twised Sister)	Glam Rock
203	La musica corale nera nata nelle parrocchie della zona del Mississippie poi diffusasi nel resto degli Usa.	Gospel
204	Nato nella famiglia del metal, più che un genere è un'attitudine che si rispecchia nel modo di rapppresentarsi / vestire del gruppo e dai testi intimisti delle canzoni (Nirvana / Soundgarden).	Grunge
205	Il punk mischiato a elementi metal	Hard Core
206	Una musica veloce basata su un campionato ad alta velocità	Hard Core (da discoteca)
207	Mix tra la cultura underground e progressive proiettata verso il futuro.	Hard House / Trance da discoteca
208	Il rock duro, un passo sotto il metal classico (Aerosmith, ecc.)	Hard Rock
209	Una musica freestyle su basi lente che spaziano tra molti generi, è poi uno stile di vita basato sulla non-violenza ed è nato anch'esso dall'evoluzione della musica nera. (Rappresentanti dell'Hip-hop italiano: Neffa, Frankie-Hi-Nrg & altri)	Hip-Hop
210	Corrente metal in cui si fa largo uso dei campionatori elettronici per creare ritmi violenti ed ossessivi (Ministry ecc.)	Industrial
211	Non cambia eccessivamente rispetto alla corrente metal, se non per il fatto che non si fa uso di chitarre elettriche (Lenny D)	Industrial (da discoteca)
212	Il jazz è una musica molto complessa di difficile interpretazione nata nei primi del secolo, basata sulla bravura e sulla capacità d'improvvisazione dei suoi compositori e musicisti. Il jazz pone le sue radici nel blues. (Louis Armstrong).	Jazz
213	E' il tentativo di trasportare il kaos urbano in musica, stretta erede dell'hip-hop, tecnicamente basata su un mix tra ritmiche veloci e melodie lente.	Jungle / Drumm 'n' bass
214	Presente Raul Casadei?	Liscio
215	Nato negli anni '70 è una musica rock dura, cattiva e appunto dai toni metallici che usa chitarre con suoni distorti. Dal metal sono nati poi una miriade di sottogeneri.	Metal
216	Una miscela sperimentale difficile da suonare e cantare che usa accordi molto complessi e innovativi. E' nata in Inghilterra alla fine degli anni '70 e ha come gruppo rappresentativo attuale la metal band americana Dream Theater	Metalprogressive e Rockprogressive
217	E' nata dalla lunga evoluzione della semplice musica strumentale medioevale europea ed è anche una delle musiche più espressive per la gamma di emozioni che riesce a trasmettere (Bach e Mozart ecc.)	Musica classica
218	E' la frangia più melodica della musica da discoteca, quella che più si avvicina al pop, solitamente di scarso valore per contenuti ma molto piacevole da ascoltare (Alexia & DJ. Dado).	Musica dance
219	Rappresenta il dark elettronico	New-Wave
220	Un'ennesima evoluzione della psichedelia, utilizza anche suoni estranei alla musica ( fischi, ronzii ecc.).	Noise
221	La parola deriva da popular, appunto musica del popolo	Pop
222	La musica commerciale più ascoltata dal popolo italiano per tradizione (come rappresentanti ha De Gregori, Baglioni e migliaia di altri autori).	Pop italiano
223	Genere nato negli ultimi anni con l'evoluzione del rapporto musica - computer, melodie facili con assoluta mancanza di testi	Progressive da discoteca
224	Corrente delle particolari sperimentazioni rock anni '60 basate sui temi dell'inconscio, una musica stordente fatta per esaltare le sensazioni della psiche (Doors e altri)	Psichedelia
225	Il punk è una musica vivace, provocatoria e con pochi accordi (Sex Pistols docet).	Punk Rock
226	I vecchi successi da discoteca anni '70 / '80	Revival da discoteca
227	Il capostipite di tutti i generi. Nato come musica giovanile da ballare nella prima metà degli anni '50 negli USA, è composto da una commistione di generi country, blues e pop americano. Il punto d'incontro tra musica bianca e nera.	Rock'n'roll
228	Una musica molto allegra basata in parte sul reggae, su ritmi latino-americani e sul punk (Divine Madness).	SKA
229	Verso l'inizio degli anni '80 si cominciò a spingere il metal verso maggiori velocità e picchi di violenza sonora più forti, arrivando alla cosiddetta musica "spazzatura" usa e getta.	Thrash
230	Rappresenta il "jazz elettronico" degli anni '90, creata con largo uso del computer e del campionatori, raggruppa sotto di sé una serie di sottogeneri (garage, house ecc.)	Underground (da discoteca)
\.


--
-- Data for Name: playlist; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.playlist (id_playlist, id_utente, restricted, titolo) FROM stdin;
26	4	f	Toad
27	5	t	lab music
32	11	f	Gg
39	26	f	a
40	2	f	prova1
42	29	f	Lazy
43	29	f	Cool
44	30	f	SSSS
\.


--
-- Data for Name: playlist_canzoni; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.playlist_canzoni (id_playlist, id_canzone) FROM stdin;
26	116760
26	92782
26	92930
26	92661
27	92654
27	92999
39	116770
39	92872
39	92903
40	116769
44	92872
44	116770
\.


--
-- Data for Name: richieste_diventa_artista; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.richieste_diventa_artista (nome_arte, motivazione, stato_richiesta, id_utente) FROM stdin;
SuperMarioOneBrother	Energico e come al solito bravo!	2	2
Anto	Because i'm special	2	4
aaa	aa	2	26
cgiallo1	prova	2	27
\.


--
-- Data for Name: utenti; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.utenti (nome, cognome, id, username, mail, id_artista, premium, psw, data_di_nascita) FROM stdin;
Mario	Rossi	2	Marione29	m.rossi@mail.com	2	t	sha256$4KVzBcYkcP6Gsu7S$70f38442b9d252e34bac1c6712538622d8f44233b3b23166a051975bee09ce92	2002-06-04
Giulia	Verdi	3	Giulietta22	g.verdi@mail.com	\N	f	sha256$4KVzBcYkcP6Gsu7S$70f38442b9d252e34bac1c6712538622d8f44233b3b23166a051975bee09ce92	1997-06-04
Antonio	Legale	4	anto	antoniolegale@gmail.com	3	f	sha256$4KVzBcYkcP6Gsu7S$70f38442b9d252e34bac1c6712538622d8f44233b3b23166a051975bee09ce92	2022-07-06
Sara	Giallo	5	sara	s.giallo@mail.com	\N	f	sha256$or2iL069GjlaQohV$c7be7780a205a6cd2bac0b91893e562a8bd5b5af7986bb68e8d7517aeec0ba37	1977-10-19
Fede	Frizz	11	Frizza	frzfe01@gmail.com	\N	f	sha256$NU1CfwCb0zuLlQEA$1bb18a70753fc6ad9bfef81a621378f2c352911e1a9cea65e4baa43cc27806e1	2001-08-07
Luigi	Bros	14	Luigino	luigibros@gmail.com	\N	f	sha256$zdQYMz4h1QnjRZ2W$b2f48c6b25540ad0c11badc3b67adedf633dcd0f1fa41bea301b8ecb10a6df30	2022-05-06
A	B	16	A	abc@gmail.com	\N	f	sha256$YXKUQC2lsEVa2Jw5$ba085ac1fc5f1aee2c71df665fb0b854cd296a9c7ef0a8825848ef5fa269901c	2022-05-17
Lucia	Ludani	21	Lucy	mio@gmail.com	\N	f	sha256$dsN6ZzCUH3JIXPf0$5a92033a3841b3f04d48918551141d4ce7defc248c1c5248e9c4750210aba7fb	2022-06-08
Alessia Michela	Di Campi	26	alexiscatmiao	alessiadicampi@yahoo.it	40825	f	sha256$09ZmGoVodmwP6Sbt$a72c7740bb451c89875fd667fbda13bab8fa1b0ed2076596f5677f525943b11b	1997-05-08
Camilla	Giallo	27	CGIALLO	c.giallo@mail.com	40826	f	sha256$TAuEf5QRITxPSWbQ$e1e7c70d35a1152e0fb4213f5f279eb0419b0241a952bd4a10f6facaed4dd283	2022-06-23
Jack	Sparrow	29	Jack@gmail.com	Jack@gmail.com	\N	f	sha256$apXKNIMebEHlxh2U$ee95b9ea33e12b5ea5e109c90fe9c313f9051069c81c972e484b06ae2d56d3d2	0001-01-01
Bobby	Bobby	30	Bobby	Bobby@gmail.com	\N	f	sha256$Kqf7c7bQ2hQuu3nh$ac84f36240c6965670253230a70c2489bfe830686e7d49e16a210a1df6803220	0001-01-01
Matrix	Matrix	31	Matrix	matrix@matrix.com	\N	f	sha256$xWW3eBoSZ1rcoPUY$4ac89c5a3430c2c52369cd547dc67c5c12255b8463a1544753b99bb90451332f	2000-01-10
test	test	32	test	test@gmail.com	\N	f	sha256$hO6MJUgIYKZssl8I$cf08dcb26b6b69042bb0cbc7c47824f1e40185e7487e9aa57fab5943e0596961	2000-01-01
beta	beta	33	beta	beta@gmail.com	\N	f	sha256$fzLuwgtxa2Wf8BP9$a4684bdbcc8aea8c7df80559b0e72b67d280e1158fbad0c78415c23c68c3077a	2022-08-01
\.


--
-- Data for Name: utenti_ascolti; Type: TABLE DATA; Schema: public; Owner: echos
--

COPY public.utenti_ascolti (id_utente, id_canzone, n_ascolti) FROM stdin;
2	116760	5
2	92833	11
2	92756	3
2	92911	2
11	116766	1
2	92828	1
11	116769	1
11	116759	1
5	116759	2
5	92999	2
5	92654	5
5	92872	3
2	116759	9
2	92872	9
2	92860	2
2	116768	3
2	116767	1
2	92949	1
2	92743	4
4	116760	1
4	116766	1
2	92744	1
2	92650	1
2	92681	1
26	116770	2
26	92903	2
26	116792	1
26	92743	1
26	92745	1
4	92872	1
29	116769	2
29	116792	1
2	116766	17
2	92946	1
2	92745	4
2	92655	1
33	116802	2
33	116769	2
\.


--
-- Name: album_id_album_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.album_id_album_seq', 41, true);


--
-- Name: artisti_id_artista_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.artisti_id_artista_seq', 40826, true);


--
-- Name: canzoni_id_artista_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.canzoni_id_artista_seq', 1, false);


--
-- Name: canzoni_id_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.canzoni_id_seq', 116806, true);


--
-- Name: generi_musicali_id_genere_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.generi_musicali_id_genere_seq', 230, true);


--
-- Name: playlist_id_playlist_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.playlist_id_playlist_seq', 44, true);


--
-- Name: richieste_diventa_artista_id_utente_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.richieste_diventa_artista_id_utente_seq', 1, false);


--
-- Name: utenti_id_seq; Type: SEQUENCE SET; Schema: public; Owner: echos
--

SELECT pg_catalog.setval('public.utenti_id_seq', 33, true);


--
-- Name: album_canzoni album_canzoni_pkey; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.album_canzoni
    ADD CONSTRAINT album_canzoni_pkey PRIMARY KEY (id_album, id_canzone);


--
-- Name: album album_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.album
    ADD CONSTRAINT album_pk PRIMARY KEY (id_album);


--
-- Name: artisti artisti_nome_arte_key; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.artisti
    ADD CONSTRAINT artisti_nome_arte_key UNIQUE (nome_arte);


--
-- Name: artisti artisti_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.artisti
    ADD CONSTRAINT artisti_pk PRIMARY KEY (id_artista);


--
-- Name: canzoni canzoni_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.canzoni
    ADD CONSTRAINT canzoni_pk PRIMARY KEY (id);


--
-- Name: generi_musicali generi_musicali_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.generi_musicali
    ADD CONSTRAINT generi_musicali_pk PRIMARY KEY (id_genere);


--
-- Name: playlist_canzoni playlist_canzoni_pkey; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.playlist_canzoni
    ADD CONSTRAINT playlist_canzoni_pkey PRIMARY KEY (id_playlist, id_canzone);


--
-- Name: playlist playlist_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT playlist_pk PRIMARY KEY (id_playlist);


--
-- Name: richieste_diventa_artista richieste_diventa_artista_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.richieste_diventa_artista
    ADD CONSTRAINT richieste_diventa_artista_pk PRIMARY KEY (id_utente);


--
-- Name: utenti_ascolti utenti_ascolti_pk_2; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti_ascolti
    ADD CONSTRAINT utenti_ascolti_pk_2 PRIMARY KEY (id_utente, id_canzone);


--
-- Name: utenti utenti_id_artista_key; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT utenti_id_artista_key UNIQUE (id_artista);


--
-- Name: utenti utenti_mail_key; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT utenti_mail_key UNIQUE (mail);


--
-- Name: utenti utenti_pk; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT utenti_pk PRIMARY KEY (id);


--
-- Name: utenti utenti_username_key; Type: CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT utenti_username_key UNIQUE (username);


--
-- Name: utenti_ascolti check_utenti_ascolti; Type: TRIGGER; Schema: public; Owner: echos
--

CREATE TRIGGER check_utenti_ascolti BEFORE INSERT OR UPDATE ON public.utenti_ascolti FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION public.check_riproduzione();


--
-- Name: playlist doppioni_playlist; Type: TRIGGER; Schema: public; Owner: echos
--

CREATE TRIGGER doppioni_playlist BEFORE INSERT OR UPDATE OF titolo ON public.playlist FOR EACH ROW EXECUTE FUNCTION public.check_equals_name_playlist();


--
-- Name: playlist_canzoni no_double_song; Type: TRIGGER; Schema: public; Owner: echos
--

CREATE TRIGGER no_double_song BEFORE INSERT OR UPDATE ON public.playlist_canzoni FOR EACH ROW EXECUTE FUNCTION public.check_double_song();


--
-- Name: album_canzoni id_album_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.album_canzoni
    ADD CONSTRAINT "id_album_FK" FOREIGN KEY (id_album) REFERENCES public.album(id_album) ON DELETE CASCADE NOT VALID;


--
-- Name: album id_artista_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.album
    ADD CONSTRAINT "id_artista_FK" FOREIGN KEY (id_artista) REFERENCES public.artisti(id_artista) ON DELETE CASCADE NOT VALID;


--
-- Name: canzoni id_artista_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.canzoni
    ADD CONSTRAINT "id_artista_FK" FOREIGN KEY (id_artista) REFERENCES public.artisti(id_artista) ON DELETE CASCADE NOT VALID;


--
-- Name: utenti id_artista_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT "id_artista_FK" FOREIGN KEY (id_artista) REFERENCES public.artisti(id_artista) ON DELETE CASCADE NOT VALID;


--
-- Name: playlist_canzoni id_canzone_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.playlist_canzoni
    ADD CONSTRAINT "id_canzone_FK" FOREIGN KEY (id_canzone) REFERENCES public.canzoni(id) ON DELETE CASCADE NOT VALID;


--
-- Name: utenti_ascolti id_canzone_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti_ascolti
    ADD CONSTRAINT "id_canzone_FK" FOREIGN KEY (id_canzone) REFERENCES public.canzoni(id) ON DELETE CASCADE NOT VALID;


--
-- Name: album_canzoni id_canzoni_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.album_canzoni
    ADD CONSTRAINT "id_canzoni_FK" FOREIGN KEY (id_canzone) REFERENCES public.canzoni(id) ON DELETE CASCADE NOT VALID;


--
-- Name: canzoni id_genere; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.canzoni
    ADD CONSTRAINT id_genere FOREIGN KEY (id_genere) REFERENCES public.generi_musicali(id_genere) ON DELETE CASCADE NOT VALID;


--
-- Name: playlist_canzoni id_playlist_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.playlist_canzoni
    ADD CONSTRAINT "id_playlist_FK" FOREIGN KEY (id_playlist) REFERENCES public.playlist(id_playlist) ON DELETE CASCADE NOT VALID;


--
-- Name: playlist id_utente_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT "id_utente_FK" FOREIGN KEY (id_utente) REFERENCES public.utenti(id) ON DELETE CASCADE NOT VALID;


--
-- Name: richieste_diventa_artista id_utente_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.richieste_diventa_artista
    ADD CONSTRAINT "id_utente_FK" FOREIGN KEY (id_utente) REFERENCES public.utenti(id) ON DELETE CASCADE NOT VALID;


--
-- Name: utenti_ascolti id_utente_FK; Type: FK CONSTRAINT; Schema: public; Owner: echos
--

ALTER TABLE ONLY public.utenti_ascolti
    ADD CONSTRAINT "id_utente_FK" FOREIGN KEY (id_utente) REFERENCES public.utenti(id) ON DELETE CASCADE NOT VALID;


--
-- Name: TABLE album; Type: ACL; Schema: public; Owner: echos
--

GRANT ALL ON TABLE public.album TO artista;


--
-- Name: TABLE album_canzoni; Type: ACL; Schema: public; Owner: echos
--

GRANT ALL ON TABLE public.album_canzoni TO artista;


--
-- Name: TABLE album_artisti_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.album_artisti_view TO artista;


--
-- Name: TABLE canzoni; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,UPDATE ON TABLE public.canzoni TO utente;
GRANT ALL ON TABLE public.canzoni TO artista;


--
-- Name: TABLE album_canzoni_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.album_canzoni_view TO artista;


--
-- Name: SEQUENCE album_id_album_seq; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,USAGE ON SEQUENCE public.album_id_album_seq TO artista;


--
-- Name: TABLE artisti; Type: ACL; Schema: public; Owner: echos
--

GRANT ALL ON TABLE public.artisti TO artista;
GRANT SELECT,UPDATE ON TABLE public.artisti TO utente;


--
-- Name: SEQUENCE canzoni_id_seq; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,USAGE ON SEQUENCE public.canzoni_id_seq TO artista;


--
-- Name: TABLE generi_musicali; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.generi_musicali TO utente;
GRANT SELECT ON TABLE public.generi_musicali TO artista;


--
-- Name: TABLE canzoni_per_riproduzioni_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.canzoni_per_riproduzioni_view TO utente;


--
-- Name: TABLE canzoni_popolari_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.canzoni_popolari_view TO home;


--
-- Name: TABLE canzoni_recenti_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.canzoni_recenti_view TO home;


--
-- Name: TABLE n_riproduzioni_album_canzoni_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.n_riproduzioni_album_canzoni_view TO artista;


--
-- Name: TABLE playlist; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,INSERT,DELETE,TRIGGER,UPDATE ON TABLE public.playlist TO utente;


--
-- Name: TABLE playlist_canzoni; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,INSERT,DELETE,TRIGGER,UPDATE ON TABLE public.playlist_canzoni TO utente;


--
-- Name: TABLE playlist_canzoni_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.playlist_canzoni_view TO utente;


--
-- Name: SEQUENCE playlist_id_playlist_seq; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,USAGE ON SEQUENCE public.playlist_id_playlist_seq TO utente;


--
-- Name: TABLE richieste_diventa_artista; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,INSERT ON TABLE public.richieste_diventa_artista TO utente;


--
-- Name: TABLE utenti_ascolti; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.utenti_ascolti TO utente;


--
-- Name: TABLE statistiche_utente_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.statistiche_utente_view TO utente;


--
-- Name: TABLE top_five_artists_view; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT ON TABLE public.top_five_artists_view TO home;


--
-- Name: TABLE utenti; Type: ACL; Schema: public; Owner: echos
--

GRANT ALL ON TABLE public.utenti TO utente;


--
-- Name: SEQUENCE utenti_id_seq; Type: ACL; Schema: public; Owner: echos
--

GRANT SELECT,USAGE ON SEQUENCE public.utenti_id_seq TO utente;


--
-- PostgreSQL database dump complete
--

