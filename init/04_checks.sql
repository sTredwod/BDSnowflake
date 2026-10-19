-- Check row preservation in the analytical model.
SELECT 'mock_data' AS table_name, COUNT(*) AS records FROM public.mock_data
UNION ALL SELECT 'fact_sales', COUNT(*) FROM public.fact_sales
UNION ALL SELECT 'dim_customer', COUNT(*) FROM public.dim_customer
UNION ALL SELECT 'dim_seller', COUNT(*) FROM public.dim_seller
UNION ALL SELECT 'dim_product', COUNT(*) FROM public.dim_product
UNION ALL SELECT 'dim_store', COUNT(*) FROM public.dim_store
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM public.dim_supplier
UNION ALL SELECT 'dim_country', COUNT(*) FROM public.dim_country
UNION ALL SELECT 'dim_category', COUNT(*) FROM public.dim_category
UNION ALL SELECT 'dim_pet_category', COUNT(*) FROM public.dim_pet_category
UNION ALL SELECT 'dim_brand', COUNT(*) FROM public.dim_brand
UNION ALL SELECT 'dim_date', COUNT(*) FROM public.dim_date
ORDER BY table_name;

-- The fact table should contain one sale for each raw source row.
SELECT (SELECT COUNT(*) FROM public.mock_data) AS raw_count,
       (SELECT COUNT(*) FROM public.fact_sales) AS fact_count,
       (SELECT COUNT(*) FROM public.mock_data m
        LEFT JOIN public.fact_sales f USING(source_row_id)
        WHERE f.sale_key IS NULL) AS missing_sales;

-- Example analytics: gross recorded sales amounts by product name.
SELECT p.product_name,
       COUNT(*) AS sales_count,
       SUM(f.quantity) AS units_sold,
       SUM(f.total_price) AS total_sales
FROM public.fact_sales f
JOIN public.dim_product p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;
