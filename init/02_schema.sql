-- LAB 1: Snowflake schema (DDL)
-- Requires public.mock_data with source_row_id from 01b_source_row_id.sql.
BEGIN;

CREATE TABLE IF NOT EXISTS public.dim_country (
    country_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.dim_category (
    category_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.dim_pet_category (
    pet_category_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.dim_brand (
    brand_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.dim_date (
    date_key DATE PRIMARY KEY,
    year_num INTEGER NOT NULL,
    quarter_num SMALLINT NOT NULL,
    month_num SMALLINT NOT NULL,
    day_num SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.dim_customer (
    customer_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    first_name TEXT,
    last_name TEXT,
    age INTEGER,
    email TEXT,
    country_key INTEGER REFERENCES public.dim_country(country_key),
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT
);

CREATE TABLE IF NOT EXISTS public.dim_seller (
    seller_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    country_key INTEGER REFERENCES public.dim_country(country_key),
    postal_code TEXT
);

CREATE TABLE IF NOT EXISTS public.dim_store (
    store_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    store_name TEXT,
    location TEXT,
    city TEXT,
    state TEXT,
    country_key INTEGER REFERENCES public.dim_country(country_key),
    phone TEXT,
    email TEXT
);

CREATE TABLE IF NOT EXISTS public.dim_supplier (
    supplier_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    supplier_name TEXT,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country_key INTEGER REFERENCES public.dim_country(country_key)
);

CREATE TABLE IF NOT EXISTS public.dim_product (
    product_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    product_name TEXT,
    category_key INTEGER REFERENCES public.dim_category(category_key),
    pet_category_key INTEGER REFERENCES public.dim_pet_category(pet_category_key),
    brand_key INTEGER REFERENCES public.dim_brand(brand_key),
    price NUMERIC(12,2),
    stock_quantity INTEGER,
    weight NUMERIC(10,2),
    color TEXT,
    size TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC(3,1),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE IF NOT EXISTS public.fact_sales (
    sale_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    original_id INTEGER,
    source_customer_id INTEGER,
    source_seller_id INTEGER,
    source_product_id INTEGER,
    customer_key BIGINT NOT NULL REFERENCES public.dim_customer(customer_key),
    seller_key BIGINT NOT NULL REFERENCES public.dim_seller(seller_key),
    product_key BIGINT NOT NULL REFERENCES public.dim_product(product_key),
    store_key BIGINT NOT NULL REFERENCES public.dim_store(store_key),
    supplier_key BIGINT NOT NULL REFERENCES public.dim_supplier(supplier_key),
    date_key DATE REFERENCES public.dim_date(date_key),
    quantity INTEGER,
    total_price NUMERIC(12,2)
);

COMMIT;
