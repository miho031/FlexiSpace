-- Storage bucket za slike prostorija u admin panelu.
INSERT INTO storage.buckets (id, name, public)
VALUES ('spaces', 'spaces', true)
ON CONFLICT (id) DO UPDATE SET public = true;

CREATE POLICY "Public can read space images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'spaces');

CREATE POLICY "Admins can upload space images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'spaces'
    AND public.is_admin()
  );

CREATE POLICY "Admins can update space images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'spaces'
    AND public.is_admin()
  )
  WITH CHECK (
    bucket_id = 'spaces'
    AND public.is_admin()
  );

CREATE POLICY "Admins can delete space images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'spaces'
    AND public.is_admin()
  );
