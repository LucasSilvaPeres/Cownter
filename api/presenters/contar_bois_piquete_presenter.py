from use_cases.contar_bois_piquete import ContarBoisPiqueteOutputPort


class ContarBoisPiquetePresenter:
    def __init__(self, output_port: ContarBoisPiqueteOutputPort):
        self.output_port = output_port

    def present(self):
        contagem = self.output_port.contagem

        return {
                "Bois em pé": contagem.qtde_bois_em_pe,
                "Bois deitados": contagem.qtde_bois_deitado,
                "Bois comendo": contagem.qtde_bois_comendo,
                "Bois bebendo": contagem.qtde_bois_bebendo,
                "Qtde de bois": contagem.qtde_total_bois}
