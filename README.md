# Nome da equipe: 
AP3-02208A-Grupo-B

# Nomes dos alunos: 
Ângelo Renostro Remus, Bruno Ricardo Seixas, Guilherme Cândido Barreiros, Guilherme Sant'ana Silva, Gustavo Parucker Lueders, Lucas Fernandes Bigolin.

# Breve descrição do tema a ser resolvido com o sistema digital:
O problema que o sistema visa resolver é o fato de um vídeo ou imagem que utiliza o formato RGB armazena a informação completa das cores dos três canais, se tornando inviável para diversas aplicações, pois utiliza uma quantidade enorme de dados.
O formato YCbCr pode resolver esse problema separando a imagem em 3 componentes: a luminância, a cor azul e a cor vermelha. Como o olho humano percebe melhor as mudanças no brilho do que nas cores, ele consegue reduzir bastante a quantidade de dados utilizada pelo RGB, sem perdas de qualidade. Então, o sistema seria um conversor de imagens RGB para YCbCr.
# Entrega 3
Na entrega 3 da atividade prática, criamos os arquivos VHDL com base nos diagramas feitos na Entrega 2. Por isso, criamos 11 arquivos para fazer a compilação do projeto, sendo o BC, o BO, o top-level e operações dentro do BO. Como não sabíamos como funcionavam os blocos spiral (que fazem multiplicações por constante usando apenas deslocamentos e somas de maneira otimizada), tivemos que mudar os tamanhos de seus valores de entrada e saídas para N bits, ao invés de N+9 bits como estava no diagrama datapath, o que mudou o tamanho dos valores de praticamente todas as operações realizadas após isso. Além disso, criamos testbenches simples para o somador, para o mux2para1 e para o mux8para1, apenas para verificar se funcionam corretamente, e um testbench mais completo, para a entidade conversor (top-level). A maior dificuldade foi implementar os generics da maneira correta, por causa de algumas operações diferentes, como os blocos spiral e a saturação, para evitar que os valores fiquem fora do intervalo desejado.
