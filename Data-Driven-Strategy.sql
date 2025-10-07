CREATE TABLE vendas_seguros (
    data_venda DATE,
    produto VARCHAR(50),
    valor_venda NUMERIC(10, 2) 
);
SELECT * FROM public.vendas_seguros;


-- Dados Duplicados
SELECT data_venda, produto, valor_venda, COUNT(*) FROM public.vendas_seguros GROUP BY 1, 2, 3 HAVING COUNT(*) > 1;

-- Valores Ausentes/NULLS
SELECT COUNT(*) AS nulos_produto FROM public.vendas_seguros WHERE produto IS NULL OR TRIM(produto) = '';

-- Remoção NULLS
DELETE FROM public.vendas_seguros 
WHERE data_venda IS NULL 
  AND produto IS NULL 
  AND valor_venda IS NULL;

-- Erros de Digitação/Inconsistência

SELECT produto, COUNT(*) 
FROM public.vendas_seguros 
WHERE LOWER(produto) NOT IN ('seguro residencial', 'seguro de vida', 'seguro assistencia', 'seguro prestamista') 
GROUP BY 1 
ORDER BY 2 DESC;

--  Tipo de Dados/Validade

SELECT COUNT(*) AS valores_negativos FROM public.vendas_seguros WHERE valor_venda < 0;

-- Quantidade de linhas

SELECT COUNT(*) FROM public.vendas_seguros;


 -- Outliers (Valores Anômalos)

  SELECT valor_venda FROM public.vendas_seguros
  WHERE valor_venda > (SELECT AVG(valor_venda) + (3 * STDDEV_POP(valor_venda)) FROM public.vendas_seguros);

  UPDATE public.vendas_seguros
SET produto = 'Seguro Assistencia'
WHERE produto = 'Seguro Assistência';

-- 1. Análise de Composição de Receita (Onde Está o Dinheiro?)

SELECT
    produto,
    COUNT(*) AS total_vendas,
    SUM(valor_venda) AS receita_total,
    -- Calcula a % que cada produto representa na receita total
    ROUND(
        (SUM(valor_venda) * 100.0) / SUM(SUM(valor_venda)) OVER (),
        2
    ) AS percentual_receita
FROM
    public.vendas_seguros
WHERE
    valor_venda IS NOT NULL -- Exclui nulos da análise de valor
GROUP BY
    produto
ORDER BY
    receita_total DESC;

-- 2. Análise da Média de Venda por Produto (O Ticket Médio)
SELECT
    produto,
    COUNT(*) AS total_vendas,
    ROUND(AVG(valor_venda), 2) AS ticket_medio
FROM
    public.vendas_seguros
WHERE
    valor_venda IS NOT NULL
GROUP BY
    produto
ORDER BY
    ticket_medio DESC;
-- 3. Análise de Tendência Mensal (Sazonalidade e Crescimento)
SELECT
    DATE_TRUNC('month', data_venda)::DATE AS mes_referencia,
    COUNT(*) AS total_vendas,
    SUM(valor_venda) AS receita_mensal
FROM
    public.vendas_seguros
WHERE
    data_venda IS NOT NULL
GROUP BY
    mes_referencia
ORDER BY
    mes_referencia;
-- 4. Análise de Vendas no Topo e na Base (Desempenho Extremo)
WITH RankedSales AS (
    SELECT
        data_venda,
        produto,
        valor_venda,
        -- Classifica as vendas da maior para a menor
        ROW_NUMBER() OVER (ORDER BY valor_venda DESC) AS rank_maior,
        -- Classifica as vendas da menor para a maior
        ROW_NUMBER() OVER (ORDER BY valor_venda ASC) AS rank_menor
    FROM
        public.vendas_seguros
    WHERE
        valor_venda IS NOT NULL
)
-- Retorna as 5 maiores e as 5 menores vendas
SELECT
    data_venda,
    produto,
    valor_venda,
    CASE WHEN rank_maior <= 5 THEN 'TOP 5 MAIORES' ELSE 'TOP 5 MENORES' END AS categoria
FROM
    RankedSales
WHERE
    rank_maior <= 5 OR rank_menor <= 5
ORDER BY
    valor_venda DESC;