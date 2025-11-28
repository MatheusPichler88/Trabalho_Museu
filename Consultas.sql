USE MuseuTrezeDeMaio;
GO

-- Consultas:

-- Livros mais emprestados por categoria
SELECT COUNT(*) AS total_emprestimos,mb.titulo AS 'titulo_livro', c.nome AS 'categoria'
FROM materiais_biblioteca AS MB
INNER JOIN categorias AS C ON (MB.id_categoria = C.id_categoria)
INNER JOIN emprestimos AS E ON (E.id_material = MB.id_material)
GROUP BY MB.titulo, C.nome
ORDER BY COUNT(*) DESC

-- Empréstimos atrasados

SELECT U.nome,MB.titulo, E.data_emprestimo, E.data_devolucao_prevista, E.data_devolucao_real , DATEDIFF(DAY, E.data_devolucao_prevista, GETDATE()) AS dias_atraso
FROM usuarios AS U
INNER JOIN emprestimos AS E ON (E.id_usuario = U.id_usuario)
INNER JOIN materiais_biblioteca AS MB ON(MB.id_material = E.id_material)
WHERE E.status_emprestimo = 'Ativo' AND
E.data_devolucao_real IS NULL AND
E.data_devolucao_prevista < GETDATE()
ORDER BY dias_atraso DESC

-- Usuários mais ativos

SELECT U.nome, U.tipo, COUNT(E.id_emprestimo) AS qtd_emprestimos
FROM usuarios AS U
INNER JOIN emprestimos AS E ON (U.id_usuario = E.id_usuario)
GROUP BY U.nome, U.tipo
ORDER BY qtd_emprestimos DESC

-- Livros nunca emprestados

SELECT MB.titulo, A.nome AS autor_nome, C.nome AS categoria_nome, E.id_material
FROM materiais_biblioteca AS MB
LEFT JOIN emprestimos AS E ON (E.id_material = MB.id_material)
INNER JOIN autores AS A ON (A.id_autor = MB.id_autor)
INNER JOIN categorias AS C ON (C.id_categoria = MB.id_categoria)
WHERE E.id_material IS NULL

-- Relátorio do museu 13 de maio
SELECT U.nome as usuario, U.tipo as tipo_usuario, MB.titulo as livro, A.nome as autor, C.nome as categoria, E.data_emprestimo, E.data_devolucao_prevista,E.status_emprestimo,
    CASE 
        WHEN E.data_devolucao_prevista < GETDATE() AND E.status_emprestimo = 'Ativo' 
        THEN 'Em Atraso'
        ELSE E.status_emprestimo
    END as situacao
FROM usuarios AS U
INNER JOIN emprestimos AS E ON (U.id_usuario = E.id_usuario)
INNER JOIN materiais_biblioteca AS MB ON (E.id_material = MB.id_material)
INNER JOIN autores AS A ON (MB.id_autor = A.id_autor)
INNER JOIN categorias AS C ON (MB.id_categoria = C.id_categoria)
ORDER BY E.data_emprestimo DESC;