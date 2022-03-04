SELECT
  COALESCE(events.data->>'selector', 'html > body') AS selector,
  events.data->>'x' as coordinates_x,
  events.data->>'y' as coordinates_y,
  events.data->>'href' as page_url,
  events.timestamp as clicked_at,
  recordings.viewport_x as viewport_x,
  recordings.viewport_y as viewport_y,
  recordings.site_id as site_id
FROM
  events
INNER JOIN
  recordings ON recordings.id = events.recording_id
WHERE
  recordings.status IN (0, 2) AND
  events.event_type = 3 AND
  (events.data->>'source')::integer = 2 AND
  (events.data->>'type')::integer = 2;
