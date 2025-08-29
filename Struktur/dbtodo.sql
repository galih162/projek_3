CREATE TABLE public.profiles (
  id uuid NOT NULL,
  name text,
  bio text,
  birth_date date,
  phone_number text,
  course text,
  email text,
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

CREATE TABLE public.tasks (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text,
  category text,
  priority text,
  date timestamp without time zone,
  notes text NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  time text,
  done boolean DEFAULT false,
  user_id uuid,
  CONSTRAINT tasks_pkey PRIMARY KEY (id)
);