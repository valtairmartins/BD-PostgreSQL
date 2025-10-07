# 🚀 Projeto de Data-Driven Strategy: Alavancando a Receita de Seguros

Este projeto documenta o processo de saneamento, validação e análise de um conjunto de dados de vendas de seguros. Usando **PostgreSQL** e técnicas avançadas de SQL, transformamos dados brutos em **insights de negócio claros e acionáveis** para o corpo executivo.

## 🎯 Sumário Executivo: Foco Estratégico

Nossas análises revelaram uma disparidade crítica: **50% de nossa receita depende de apenas 25% de nossos produtos (Seguro de Vida)**. Além disso, a performance é **altamente sazonal**, com picos de alto valor concentrados em Março e Novembro.

| Métrica | Seguro de Vida | Seguro Prestamista | Ação Imediata |
| :---: | :---: | :---: | :---: |
| **Ticket Médio** | **R$ 1.681,37** | R$ 219,14 | **Priorizar Vendas de Vida:** Redirecionar 80% do foco comercial. |
| **Participação na Receita** | **50.58%** | 6.34% | **Automatizar Prestamista:** Avaliar o custo-benefício de vendas manuais de baixo valor. |
| **Maiores Vendas (TOP 5)** | **100% Vida** | 0% | **Replicar Estratégias** que fecharam esses tickets. |

---

## 1. 🧹 Fase de Qualidade de Dados (DQ): A Base da Confiança

A auditoria inicial revelou e corrigiu falhas críticas de integridade, garantindo que as análises fossem construídas sobre dados 100% limpos.

### 🛠️ Principais Ações de Limpeza:

1. **Remoção de Duplicatas:** Exclusão de **896 linhas completamente nulas** (`NULL`), saneando a completude dos dados.  
2. **Correção de Tipagem:** Correção do tipo da coluna de valor para **`NUMERIC(10, 2)`** (antes incorretamente definido como `NUM`).  
3. **Normalização de Texto:** Padronização da grafia de "Seguro Assistência" para eliminar inconsistências de agregação.

### 💡 Código SQL de Saneamento:

```sql
-- 1. Remoção de 896 Duplicatas de NULLs
DELETE FROM public.vendas_seguros 
WHERE data_venda IS NULL AND produto IS NULL AND valor_venda IS NULL;

-- 2. Correção de Inconsistência de Texto (Padronização)
UPDATE public.vendas_seguros
SET produto = 'Seguro Assistencia'
WHERE produto = 'Seguro Assistência';

## 2. 📊 Análise de Impacto de Negócio: Foco no Retorno

As análises a seguir fornecem a inteligência necessária para o planejamento de metas e alocação de recursos.

---

### 2.1. O Motor da Receita: Ticket Médio

A alta participação do **Seguro de Vida** na receita é explicada pelo seu valor por transação.

| Produto | Ticket Médio |
| :--- | ---: |
| **Seguro de Vida** | **R$ 1.681,37** |
| Seguro Residencial | R$ 938,08 |
| Seguro Assistencia | R$ 494,23 |
| Seguro Prestamista | R$ 219,14 |

**Exportar para as Planilhas**

**SQL:**
```sql
SELECT
    produto,
    ROUND(AVG(valor_venda), 2) AS ticket_medio
FROM public.vendas_seguros
GROUP BY produto
ORDER BY ticket_medio DESC;

### 2.2. Tendência Mensal: Sazonalidade e Volatilidade

A receita é volátil, concentrando-se em períodos específicos, apesar de o número de vendas ser constante.

| Mês de Pico |   Receita Mensal | Desafio                                          |
| :---------: | ---------------: | :----------------------------------------------- |
|  **Março**  | **R$ 15.476,75** | Pico absoluto de receita (Alto Ticket)           |
|   Novembro  |     R$ 14.776,90 | Segundo maior pico (Alto Ticket)                 |
|   Dezembro  |      R$ 1.668,10 | Queda Alarmante (Vendas de baixo ticket dominam) |

SELECT
    DATE_TRUNC('month', data_venda)::DATE AS mes_referencia,
    SUM(valor_venda) AS receita_mensal
FROM public.vendas_seguros
WHERE data_venda IS NOT NULL
GROUP BY mes_referencia
ORDER BY mes_referencia;

### 2.3. O Topo e a Base: Vendas Extremas

As 5 maiores vendas são compostas 100% por Seguro de Vida, e as menores, 100% por Seguro Prestamista, reforçando a concentração de valor.
WITH RankedSales AS (
    SELECT data_venda, produto, valor_venda,
        ROW_NUMBER() OVER (ORDER BY valor_venda DESC) AS rank_maior,
        ROW_NUMBER() OVER (ORDER BY valor_venda ASC) AS rank_menor
    FROM public.vendas_seguros
    WHERE valor_venda IS NOT NULL
)
SELECT data_venda, produto, valor_venda,
    CASE WHEN rank_maior <= 5 THEN 'TOP 5 MAIORES' ELSE 'TOP 5 MENORES' END AS categoria
FROM RankedSales
WHERE rank_maior <= 5 OR rank_menor <= 5
ORDER BY valor_venda DESC;

## Recomendações Estratégicas para o Corpo Executivo

1. Foco em Alto Ticket (Vida e Residencial):
Redirecionar o orçamento de marketing e incentivo comercial para os produtos com ticket mais alto.
Cada venda de Vida tem um ROI (Retorno sobre Investimento) 7 vezes maior que uma venda de Prestamista.

2. Mitigação da Queda de Dezembro:
Planejar uma campanha de alto valor específica para Dezembro, incentivando a venda de Seguro de Vida para reverter a queda histórica da receita.

3. Automatização de Baixo Valor:
Transferir a venda de Seguro Prestamista e Assistência para canais de cross-sell automatizado (e-mail, site), liberando o tempo da equipe comercial para focar exclusivamente nos produtos de alta receita.
