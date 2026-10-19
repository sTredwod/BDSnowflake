-- LAB 1: Snowflake schema (DML)
-- The raw source IDs are repeated and are NOT reliable cross-file join keys.
-- Use source_row_id to associate fields originating in the same CSV record.
BEGIN;

INSERT INTO public.dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT NULLIF(BTRIM(customer_country), '') AS country_name FROM public.mock_data
    UNION ALL
    SELECT NULLIF(BTRIM(seller_country), '') FROM public.mock_data
    UNION ALL
    SELECT NULLIF(BTRIM(store_country), '') FROM public.mock_data
    UNION ALL
    SELECT NULLIF(BTRIM(supplier_country), '') FROM public.mock_data
) x
WHERE country_name IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO public.dim_category (category_name)
SELECT DISTINCT NULLIF(BTRIM(product_category), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_category), '') IS NOT NULL
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO public.dim_pet_category (category_name)
SELECT DISTINCT NULLIF(BTRIM(pet_category), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(pet_category), '') IS NOT NULL
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO public.dim_brand (brand_name)
SELECT DISTINCT NULLIF(BTRIM(product_brand), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_brand), '') IS NOT NULL
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO public.dim_date(date_key, year_num, quarter_num, month_num, day_num)
SELECT DISTINCT d,
       EXTRACT(YEAR FROM d)::INTEGER,
       EXTRACT(QUARTER FROM d)::SMALLINT,
       EXTRACT(MONTH FROM d)::SMALLINT,
       EXTRACT(DAY FROM d)::SMALLINT
FROM (
    SELECT TO_DATE(NULLIF(BTRIM(sale_date), ''), 'MM/DD/YYYY') AS d
    FROM public.mock_data
) dates
WHERE d IS NOT NULL
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO public.dim_customer
    (source_row_id, first_name, last_name, age, email, country_key,
     postal_code, pet_type, pet_name, pet_breed)
SELECT m.source_row_id,
       m.customer_first_name, m.customer_last_name,
       NULLIF(BTRIM(m.customer_age), '')::INTEGER,
       m.customer_email, c.country_key,
       m.customer_postal_code, m.customer_pet_type,
       m.customer_pet_name, m.customer_pet_breed
FROM public.mock_data m
LEFT JOIN public.dim_country c
  ON c.country_name = NULLIF(BTRIM(m.customer_country), '')
ON CONFLICT (source_row_id) DO NOTHING;

INSERT INTO public.dim_seller
    (source_row_id, first_name, last_name, email, country_key, postal_code)
SELECT m.source_row_id,
       m.seller_first_name, m.seller_last_name, m.seller_email,
       c.country_key, m.seller_postal_code
FROM public.mock_data m
LEFT JOIN public.dim_country c
  ON c.country_name = NULLIF(BTRIM(m.seller_country), '')
ON CONFLICT (source_row_id) DO NOTHING;

INSERT INTO public.dim_store
    (source_row_id, store_name, location, city, state, country_key, phone, email)
SELECT m.source_row_id, m.store_name, m.store_location, m.store_city,
       m.store_state, c.country_key, m.store_phone, m.store_email
FROM public.mock_data m
LEFT JOIN public.dim_country c
  ON c.country_name = NULLIF(BTRIM(m.store_country), '')
ON CONFLICT (source_row_id) DO NOTHING;

INSERT INTO public.dim_supplier
    (source_row_id, supplier_name, contact, email, phone, address, city, country_key)
SELECT m.source_row_id, m.supplier_name, m.supplier_contact,
       m.supplier_email, m.supplier_phone, m.supplier_address,
       m.supplier_city, c.country_key
FROM public.mock_data m
LEFT JOIN public.dim_country c
  ON c.country_name = NULLIF(BTRIM(m.supplier_country), '')
ON CONFLICT (source_row_id) DO NOTHING;

INSERT INTO public.dim_product
    (source_row_id, product_name, category_key, pet_category_key, brand_key,
     price, stock_quantity, weight, color, size, material, description,
     rating, reviews, release_date, expiry_date)
SELECT m.source_row_id, m.product_name, pc.category_key,
       pet.pet_category_key, b.brand_key,
       NULLIF(BTRIM(m.product_price), '')::NUMERIC(12,2),
       NULLIF(BTRIM(m.product_quantity), '')::INTEGER,
       NULLIF(BTRIM(m.product_weight), '')::NUMERIC(10,2),
       m.product_color, m.product_size, m.product_material, m.product_description,
       NULLIF(BTRIM(m.product_rating), '')::NUMERIC(3,1),
       NULLIF(BTRIM(m.product_reviews), '')::INTEGER,
       TO_DATE(NULLIF(BTRIM(m.product_release_date), ''), 'MM/DD/YYYY'),
       TO_DATE(NULLIF(BTRIM(m.product_expiry_date), ''), 'MM/DD/YYYY')
FROM public.mock_data m
LEFT JOIN public.dim_category pc
  ON pc.category_name = NULLIF(BTRIM(m.product_category), '')
LEFT JOIN public.dim_pet_category pet
  ON pet.category_name = NULLIF(BTRIM(m.pet_category), '')
LEFT JOIN public.dim_brand b
  ON b.brand_name = NULLIF(BTRIM(m.product_brand), '')
ON CONFLICT (source_row_id) DO NOTHING;

INSERT INTO public.fact_sales
    (source_row_id, original_id, source_customer_id, source_seller_id,
     source_product_id, customer_key, seller_key, product_key,
     store_key, supplier_key, date_key, quantity, total_price)
SELECT m.source_row_id,
       NULLIF(BTRIM(m.id), '')::INTEGER,
       NULLIF(BTRIM(m.sale_customer_id), '')::INTEGER,
       NULLIF(BTRIM(m.sale_seller_id), '')::INTEGER,
       NULLIF(BTRIM(m.sale_product_id), '')::INTEGER,
       c.customer_key, s.seller_key, p.product_key,
       st.store_key, su.supplier_key,
       d.date_key,
       NULLIF(BTRIM(m.sale_quantity), '')::INTEGER,
       NULLIF(BTRIM(m.sale_total_price), '')::NUMERIC(12,2)
FROM public.mock_data m
JOIN public.dim_customer c ON c.source_row_id = m.source_row_id
JOIN public.dim_seller s ON s.source_row_id = m.source_row_id
JOIN public.dim_product p ON p.source_row_id = m.source_row_id
JOIN public.dim_store st ON st.source_row_id = m.source_row_id
JOIN public.dim_supplier su ON su.source_row_id = m.source_row_id
LEFT JOIN public.dim_date d
  ON d.date_key = TO_DATE(NULLIF(BTRIM(m.sale_date), ''), 'MM/DD/YYYY')
ON CONFLICT (source_row_id) DO NOTHING;

COMMIT;
