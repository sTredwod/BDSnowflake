CREATE TABLE public.mock_data (
    id TEXT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age TEXT,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    product_price TEXT,
    product_quantity TEXT,
    sale_date TEXT,
    sale_customer_id TEXT,
    sale_seller_id TEXT,
    sale_product_id TEXT,
    sale_quantity TEXT,
    sale_total_price TEXT,
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_weight TEXT,
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_rating TEXT,
    product_reviews TEXT,
    product_release_date TEXT,
    product_expiry_date TEXT,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT
);

DO $$
DECLARE
    filename TEXT;
BEGIN
    FOR filename IN
        SELECT name
        FROM pg_ls_dir('/csv') AS t(name)
        WHERE name ~ '^MOCK_DATA( \([0-9]+\))?\.csv$'
        ORDER BY name
    LOOP
        EXECUTE format(
            'COPY public.mock_data FROM %L WITH (FORMAT csv, HEADER true)',
            '/csv/' || filename
        );

        RAISE NOTICE 'Loaded: %', filename;
    END LOOP;
END $$;

SELECT COUNT(*) AS total_rows FROM public.mock_data;
