-- Existing mock_data.id repeats across 10 CSV files.
-- This staging key uniquely identifies every imported record.
ALTER TABLE public.mock_data
    ADD COLUMN IF NOT EXISTS source_row_id BIGINT GENERATED ALWAYS AS IDENTITY;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mock_data_source_row_id
    ON public.mock_data (source_row_id);
