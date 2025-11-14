# Nome da equipe: 
AP3-02208A-Grupo-B

# Nomes dos alunos: 
Ângelo Renostro Remus, Bruno Ricardo Seixas, Guilherme Cândido Barreiros, Guilherme Sant'ana Silva, Gustavo Parucker Lueders, Lucas Fernandes Bigolin.

# Breve descrição do tema a ser resolvido com o sistema digital:
O problema que o sistema visa resolver é o fato de um vídeo ou imagem que utiliza o formato RGB armazena a informação completa das cores dos três canais, se tornando inviável para diversas aplicações, pois utiliza uma quantidade enorme de dados.
O formato YCbCr pode resolver esse problema separando a imagem em 3 componentes: a luminância, a cor azul e a cor vermelha. Como o olho humano percebe melhor as mudanças no brilho do que nas cores, ele consegue reduzir bastante a quantidade de dados utilizada pelo RGB, sem perdas de qualidade. Então, o sistema seria um conversor de imagens RGB para YCbCr.
# Escolhas realizadas
Nessa entrega da atividade prática, decidimos que as entradas vão ser genéricas, podendo ter 8 ou 10 bits,com as saídas tendo o mesmo número de bits. Além disso, decidimos usar aritmética de ponto fixo, para facilitar na hora de fazer multiplicações. Por fim, vamos fazer um sistema que converte RGB para YCbCR, tanto com BT.709 e BT.2020 de maneira configurável usando uma entrada sel, onde sel = '0' indica o uso de BT.709, e sel = '1' indica BT.2020. As multiplicações serão feitas por meio de blocos spiral, que geram circuitos otimizados para as constantes de cada matriz.
