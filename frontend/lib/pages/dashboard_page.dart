import 'package:cownter/controllers/dashboard_controller.dart';
import 'package:cownter/pages/loading_page.dart';
import 'package:cownter/pages/maps.dart';
import 'package:cownter/utils/appRoutes.dart';
import 'package:cownter/utils/extensions.dart';
import 'package:cownter/widgets/bois_comendo_bebendo_card.dart';
import 'package:cownter/widgets/bois_pe_deitado_card.dart';
import 'package:cownter/widgets/drawer.dart';
import 'package:cownter/widgets/relatorio_geral_row.dart';
import 'package:cownter/widgets/tabela_piquetes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    DashboardController controller = GetIt.I.get<DashboardController>();

    final arguments = ModalRoute.of(context)!.settings.arguments;

    DateTime? dataVoo;

    if (arguments != null) {
      var piquetesArgs = arguments as PiquetesRouteArguments;

      dataVoo = piquetesArgs.dataVoo;
    }

    controller.requisitarDados(dataVoo);

    return Scaffold(
      appBar: AppBar(
          title: const Text("Cownter"),
          backgroundColor: Theme.of(context).colorScheme.primary),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            controller.limpadadosFiltradosMapa();
                            const AppMaps().limpaMapa();
                            //controller.requisitarDados();
                          }),
                      const Text(
                        "Relatório geral",
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton(
                          offset: const Offset(0, 40),
                          icon: const Icon(Icons.calendar_today),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                                value: 'Selecionar Data',
                                child: Observer(builder: (_) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            height: 400,
                                            width: 500,
                                            child: CalendarDatePicker(
                                              firstDate: DateTime(2023, 1, 1),
                                              lastDate: DateTime.now(),
                                              initialDate: controller.data,
                                              onDateChanged: (DateTime value) {
                                                controller.setData(value);
                                                controller
                                                    .atualizarDadosRelatorioGeral();
                                                controller
                                                    .atualizarDadosBoisPeDeitado();
                                                controller
                                                    .atualizarDadosBoisComendoBebendo();
                                                controller
                                                    .atualizarDadosTabelaPiquete(
                                                        '');
                                                Navigator.pop(context);
                                              },
                                            )),
                                      ),
                                    ],
                                  );
                                })),
                          ],
                        ),
                      ),
                      Observer(builder: (_) {
                        return Text(controller.data.formattedDate);
                      }),
                    ],
                  )),
              Observer(builder: (_) {
                return controller.loading
                    ? LoadingPage()
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          RelatorioGeralRow(
                              dados: controller.dadosRelatorioGeral),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      "Fazenda ",
                                      textAlign: TextAlign.start,
                                    ),
                                    AppMaps(),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    const Text("Bois em pé/deitado"),
                                    Observer(builder: (_) {
                                      return controller.loading
                                          ? const Text("Carregando")
                                          : BoisPeDeitadoCard(
                                              dados: controller
                                                  .dadosBoisPeDeitado);
                                    }),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        child: const Text(
                                            "Bois comendo/bebendo",
                                            textAlign: TextAlign.start)),
                                    Observer(builder: (_) {
                                      return controller.loading
                                          ? const Text("Carregando")
                                          : BoisComendoBebendoCard(
                                              dados: controller
                                                  .dadosBoisComendoBebendo);
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  child: const Text("Lista de piquetes",
                                      style: TextStyle(fontSize: 18))),
                              Observer(builder: (_) {
                                return controller.loading
                                    ? Container()
                                    : SizedBox(
                                        width: double.infinity,
                                        child: TabelaPiquetes(
                                            dadosTabela:
                                                controller.dadosTabelaPiquete));
                              }),
                            ],
                          )
                        ],
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
