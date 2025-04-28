class EmprestimosModel {
  String codigo;
  String nome;
  String dataEmprestimo;
  String dataDevolucao;
  bool selecionadoRenov = false;
  EmprestimosModel(
      this.codigo, this.nome, this.dataEmprestimo, this.dataDevolucao);
}
