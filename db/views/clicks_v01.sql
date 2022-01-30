SELECT
  COALESCE(events.data->>'selector', 'html > body') AS selector,
  events.data->>'x' as coordinates_x,
  events.data->>'y' as coordinates_y,
  events.timestamp as clicked_at,
  recordings.viewport_x as viewport_x,
  recordings.viewport_y as viewport_y,
  pages.url as page_url,
  recordings.site_id as site_id
FROM
  pages
INNER JOIN
  recordings ON recordings.id = pages.recording_id
INNER JOIN
  events ON events.recording_id = recordings.id
WHERE
  recordings.status IN (0, 2) AND
  events.timestamp >= pages.entered_at AND
  events.timestamp <= pages.exited_at AND
  events.event_type = 3 AND
  (events.data->>'source')::integer = 2 AND
  (events.data->>'type')::integer = 2;
