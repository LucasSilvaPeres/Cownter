import 'package:cownter/controllers/dashboard_principal_controller.dart';
import 'package:cownter/pages/loading_page.dart';
import 'package:cownter/widgets/drawer.dart';
import 'package:cownter/widgets/grafico_acao_bois_voo.dart';
import 'package:cownter/widgets/grafico_posicao_bois_voo.dart';
import 'package:cownter/widgets/grafico_total_bois_voo.dart';
import 'package:cownter/widgets/tabela_voos_fazenda.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SelectFazendaDTO {
  final String idFazenda;
  final String nomeFazenda;

  SelectFazendaDTO(this.idFazenda, this.nomeFazenda);
} 

List<SelectFazendaDTO> mockFazendas = [
  SelectFazendaDTO("4efcc9ee-396f-469c-b570-6e0cbd6aa575", "Fazenda Santa Cruz"),
  SelectFazendaDTO("4efcc9ee-396f-469c-b570-6e0cbd6aa576", "Fazenda Malta alvares"),
];


class SelectFazenda extends StatefulWidget {
  const SelectFazenda({super.key});

  @override
  State<SelectFazenda> createState() => _SelectFazendaState();
}

class _SelectFazendaState extends State<SelectFazenda> {
  DashboardPrincipalController dashboardPrincipalController = GetIt.I.get<DashboardPrincipalController>();
  SelectFazendaDTO fazendaSelecionada = mockFazendas.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: fazendaSelecionada.idFazenda,
      items:  mockFazendas.map<DropdownMenuItem<String>>((e) {
        return DropdownMenuItem<String>(
          value: e.idFazenda,
          child: Text(e.nomeFazenda));
      }).toList(),
      onChanged: (e) {
        setState(() {
          fazendaSelecionada = mockFazendas.where((f) => f.idFazenda == e).first;

          dashboardPrincipalController.atualizarDTO(fazendaSelecionada.idFazenda);
        });
      }
    );
  }
}


class DashboardPrincipalPage extends StatelessWidget {
  const DashboardPrincipalPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    DashboardPrincipalController dashboardPrincipalController = GetIt.I.get<DashboardPrincipalController>();

    Future<void> taskAtualizarDTO = dashboardPrincipalController.atualizarDTO(mockFazendas.first.idFazenda);

    return Scaffold(
      appBar: AppBar(
          title: const Text("Cownter"),
          backgroundColor: Theme.of(context).colorScheme.primary),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: taskAtualizarDTO,
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
          ? LoadingPage()
          :
         Column(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("VOOS", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text("Fazenda: "),
                      SelectFazenda(),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Expanded(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()))
                else Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(padding: const EdgeInsets.all(32.0), child: SizedBox(height: 300, child: GraficoTotalBoisVoo(dashboardPrincipalController.graficoTotalBoisDTO))),
                    ),
                  ),
                ),
            
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Expanded(child: CircularProgressIndicator())
                else Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(padding: const EdgeInsets.all(32.0), child: SizedBox(height: 300, child: GraficoPosicaoBoisVoo(dashboardPrincipalController.graficoTotalBoisDTO))),
                    ),
                  ),
                ),
              ]
            ),
          ),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Expanded(flex: 2, child: CircularProgressIndicator())
          else
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(padding: const EdgeInsets.all(32.0), child: SizedBox(height: 300, child: GraficoAcaoBoisVoo(dashboardPrincipalController.graficoTotalBoisDTO))),
                ),
              ),
            ),
          Expanded(flex: 4, child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabelaVoosFazenda(dashboardPrincipalController.graficoTotalBoisDTO),
          )
            )
        ],
      ))
    );
  }
}