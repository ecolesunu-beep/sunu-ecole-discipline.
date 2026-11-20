-- SUNU ÉCOLE — schéma PostgreSQL pour un projet Supabase NEUF.
-- Exécuter UNE fois dans Supabase > SQL Editor, puis connecter DATABASE_URL côté serveur.
-- Authentification par e-mail et mot de passe haché Argon2id ; sessions opaques sans cookies.
-- Les anciennes tables d'essais sont conservées uniquement pour compatibilité.
-- Le navigateur ne doit JAMAIS avoir un accès SQL/REST direct aux tables sensibles.
-- Les politiques ci-dessous protègent aussi les éventuels accès via Supabase Auth.
-- Ne pas exécuter sur une base contenant déjà ces tables : utiliser Drizzle pour les évolutions.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE public.ecoles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nom_ecole text NOT NULL,
    type_etablissement text NOT NULL,
    ville text DEFAULT ''::text NOT NULL,
    pays text DEFAULT ''::text NOT NULL,
    annee_scolaire text DEFAULT ''::text NOT NULL,
    email_ecole text,
    logo_ecole text,
    code_parrainage_unique character varying(24) NOT NULL,
    cree_par_id uuid,
    seuil_retards integer DEFAULT 3 NOT NULL,
    seuil_absences integer DEFAULT 3 NOT NULL,
    seuil_renvois integer DEFAULT 1 NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: eleves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eleves (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ecole_id uuid NOT NULL,
    prenom text NOT NULL,
    nom text NOT NULL,
    classe text NOT NULL,
    dedupe_key character varying(64) NOT NULL,
    photo_id uuid,
    telephone_parent text,
    email_parent text,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: fiches_renvoi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fiches_renvoi (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ecole_id uuid NOT NULL,
    eleve_id uuid NOT NULL,
    date date NOT NULL,
    motif text NOT NULL,
    duree_jours integer NOT NULL,
    date_retour date NOT NULL,
    cumul integer NOT NULL,
    pdf_url text,
    saisi_par_id uuid,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: historique; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historique (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ecole_id uuid NOT NULL,
    date_heure timestamp with time zone DEFAULT now() NOT NULL,
    utilisateur_id uuid,
    qui text NOT NULL,
    action text NOT NULL,
    details text DEFAULT ''::text NOT NULL,
    ip_adresse text
);


--
-- Name: journal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ecole_id uuid NOT NULL,
    eleve_id uuid NOT NULL,
    date date NOT NULL,
    type text NOT NULL,
    heure text DEFAULT ''::text NOT NULL,
    justifie text DEFAULT 'Non'::text NOT NULL,
    motif text DEFAULT ''::text NOT NULL,
    decision text DEFAULT ''::text NOT NULL,
    parents_informes text DEFAULT 'Non'::text NOT NULL,
    photo_justificatif_url text,
    saisi_par_id uuid,
    saisi_par_nom text NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: login_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scope text NOT NULL,
    scope_key character varying(128) NOT NULL,
    email text,
    ip_adresse text,
    user_agent text,
    tentatives_echouees integer DEFAULT 0 NOT NULL,
    derniere_tentative_at timestamp with time zone,
    bloque_jusqua_at timestamp with time zone,
    statut text DEFAULT 'actif'::text NOT NULL
);


--
-- Name: login_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email_lookup character varying(64),
    ip_adresse text NOT NULL,
    user_agent text,
    statut text NOT NULL,
    date_heure timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_resets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    utilisateur_id uuid NOT NULL,
    token_hash character varying(64) NOT NULL,
    expire_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pieces_jointes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pieces_jointes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ecole_id uuid NOT NULL,
    contenu_chiffre bytea NOT NULL,
    mime_type text NOT NULL,
    nom_fichier text NOT NULL,
    ajoute_par_id uuid NOT NULL,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    utilisateur_id uuid NOT NULL,
    token_hash character varying(64) NOT NULL,
    expire_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    ip_adresse text,
    user_agent text,
    date_creation timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: utilisateurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.utilisateurs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ecole_id uuid NOT NULL,
    nom text NOT NULL,
    email text NOT NULL,
    email_lookup character varying(64) NOT NULL,
    password_hash character varying(255) NOT NULL,
    password_history jsonb DEFAULT '[]'::jsonb NOT NULL,
    password_changed_at timestamp with time zone DEFAULT now() NOT NULL,
    must_change_password boolean DEFAULT false NOT NULL,
    role text DEFAULT 'Surveillant'::text NOT NULL,
    permissions jsonb DEFAULT '{}'::jsonb NOT NULL,
    actif boolean DEFAULT true NOT NULL,
    invite_par_id uuid,
    date_arrivee timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ecoles ecoles_code_parrainage_unique_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ecoles
    ADD CONSTRAINT ecoles_code_parrainage_unique_unique UNIQUE (code_parrainage_unique);


--
-- Name: ecoles ecoles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ecoles
    ADD CONSTRAINT ecoles_pkey PRIMARY KEY (id);


--
-- Name: eleves eleves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_pkey PRIMARY KEY (id);


--
-- Name: fiches_renvoi fiches_renvoi_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fiches_renvoi
    ADD CONSTRAINT fiches_renvoi_pkey PRIMARY KEY (id);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (id);


--
-- Name: journal journal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_pkey PRIMARY KEY (id);


--
-- Name: login_attempts login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (id);


--
-- Name: login_events login_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_events
    ADD CONSTRAINT login_events_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_token_hash_unique UNIQUE (token_hash);


--
-- Name: pieces_jointes pieces_jointes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pieces_jointes
    ADD CONSTRAINT pieces_jointes_pkey PRIMARY KEY (id);


--
-- Name: refresh_sessions refresh_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_sessions
    ADD CONSTRAINT refresh_sessions_pkey PRIMARY KEY (id);


--
-- Name: refresh_sessions refresh_sessions_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_sessions
    ADD CONSTRAINT refresh_sessions_token_hash_unique UNIQUE (token_hash);


--
-- Name: utilisateurs utilisateurs_email_lookup_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_email_lookup_unique UNIQUE (email_lookup);


--
-- Name: utilisateurs utilisateurs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_pkey PRIMARY KEY (id);


--
-- Name: eleves_ecole_classe_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eleves_ecole_classe_idx ON public.eleves USING btree (ecole_id, classe);


--
-- Name: eleves_ecole_dedupe_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX eleves_ecole_dedupe_idx ON public.eleves USING btree (ecole_id, dedupe_key);


--
-- Name: fiches_ecole_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fiches_ecole_idx ON public.fiches_renvoi USING btree (ecole_id);


--
-- Name: historique_ecole_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX historique_ecole_date_idx ON public.historique USING btree (ecole_id, date_heure);


--
-- Name: journal_ecole_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX journal_ecole_date_idx ON public.journal USING btree (ecole_id, date);


--
-- Name: journal_ecole_eleve_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX journal_ecole_eleve_idx ON public.journal USING btree (ecole_id, eleve_id);


--
-- Name: login_attempts_scope_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX login_attempts_scope_idx ON public.login_attempts USING btree (scope, scope_key);


--
-- Name: login_events_ip_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX login_events_ip_date_idx ON public.login_events USING btree (ip_adresse, date_heure);


--
-- Name: pieces_ecole_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pieces_ecole_idx ON public.pieces_jointes USING btree (ecole_id);


--
-- Name: utilisateurs_ecole_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX utilisateurs_ecole_idx ON public.utilisateurs USING btree (ecole_id);


--
-- Name: eleves eleves_ecole_id_ecoles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_ecole_id_ecoles_id_fk FOREIGN KEY (ecole_id) REFERENCES public.ecoles(id);


--
-- Name: fiches_renvoi fiches_renvoi_ecole_id_ecoles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fiches_renvoi
    ADD CONSTRAINT fiches_renvoi_ecole_id_ecoles_id_fk FOREIGN KEY (ecole_id) REFERENCES public.ecoles(id);


--
-- Name: fiches_renvoi fiches_renvoi_eleve_id_eleves_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fiches_renvoi
    ADD CONSTRAINT fiches_renvoi_eleve_id_eleves_id_fk FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;


--
-- Name: historique historique_ecole_id_ecoles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_ecole_id_ecoles_id_fk FOREIGN KEY (ecole_id) REFERENCES public.ecoles(id);


--
-- Name: journal journal_ecole_id_ecoles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_ecole_id_ecoles_id_fk FOREIGN KEY (ecole_id) REFERENCES public.ecoles(id);


--
-- Name: journal journal_eleve_id_eleves_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_eleve_id_eleves_id_fk FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;


--
-- Name: password_resets password_resets_utilisateur_id_utilisateurs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_utilisateur_id_utilisateurs_id_fk FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: pieces_jointes pieces_jointes_ecole_id_ecoles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pieces_jointes
    ADD CONSTRAINT pieces_jointes_ecole_id_ecoles_id_fk FOREIGN KEY (ecole_id) REFERENCES public.ecoles(id);


--
-- Name: refresh_sessions refresh_sessions_utilisateur_id_utilisateurs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_sessions
    ADD CONSTRAINT refresh_sessions_utilisateur_id_utilisateurs_id_fk FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;


--
-- Name: utilisateurs utilisateurs_ecole_id_ecoles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.utilisateurs
    ADD CONSTRAINT utilisateurs_ecole_id_ecoles_id_fk FOREIGN KEY (ecole_id) REFERENCES public.ecoles(id);


--

-- END OF PORTABLE SCHEMA
-- RLS activé sur toutes les tables. Les tables d'authentification et les justificatifs
-- restent exclusivement accessibles par le serveur (aucune politique navigateur).
CREATE OR REPLACE FUNCTION public.sunu_ecole_courante()
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT ecole_id FROM public.utilisateurs WHERE id = auth.uid() AND actif = true LIMIT 1 $$;
REVOKE ALL ON FUNCTION public.sunu_ecole_courante() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.sunu_ecole_courante() TO authenticated;

ALTER TABLE public.ecoles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eleves ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.utilisateurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historique ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fiches_renvoi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pieces_jointes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refresh_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.password_resets ENABLE ROW LEVEL SECURITY;

-- Politiques d'isolation supplémentaires pour des identités Supabase Auth liées
-- au même UUID utilisateur. La plateforme actuelle n'utilise pas le client Supabase
-- dans le navigateur ; tous les accès effectifs passent par les API serveur filtrées.
CREATE POLICY sunu_ecoles_lecture ON public.ecoles FOR SELECT TO authenticated
  USING (id = public.sunu_ecole_courante());
CREATE POLICY sunu_eleves_isolation ON public.eleves FOR ALL TO authenticated
  USING (ecole_id = public.sunu_ecole_courante()) WITH CHECK (ecole_id = public.sunu_ecole_courante());
CREATE POLICY sunu_journal_isolation ON public.journal FOR ALL TO authenticated
  USING (ecole_id = public.sunu_ecole_courante()) WITH CHECK (ecole_id = public.sunu_ecole_courante());
CREATE POLICY sunu_utilisateurs_lecture ON public.utilisateurs FOR SELECT TO authenticated
  USING (ecole_id = public.sunu_ecole_courante());
CREATE POLICY sunu_historique_isolation ON public.historique FOR SELECT TO authenticated
  USING (ecole_id = public.sunu_ecole_courante());
CREATE POLICY sunu_fiches_isolation ON public.fiches_renvoi FOR ALL TO authenticated
  USING (ecole_id = public.sunu_ecole_courante()) WITH CHECK (ecole_id = public.sunu_ecole_courante());

-- Défense en profondeur : aucun accès direct REST aux tables, même si une future
-- clé publique Supabase est ajoutée à l'interface. Seul le serveur possède DATABASE_URL.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
