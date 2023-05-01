-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Andrew Brown','andrew@exampro.co' , 'andrewbrown' ,'MOCK'),
  ('Andrew Bayko','bayko@exampro.co' , 'bayko' ,'MOCK'),
  ('Londo Mollari','lmollari@centari.com' ,'londo' ,'MOCK'),
  ('ganesh live','ganeshpondy@gmail.com' , 'ganeshpondy' ,'MOCK'),
  ('ganesh live','ganeshpondy@live.com' , 'ganeshlive' ,'MOCK'),
  ('ganesh nir','ganeshnir@rediffmail.com' , 'ganeshnir' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'andrewbrown' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )