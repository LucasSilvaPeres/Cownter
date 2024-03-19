from unittest import TestCase
from unittest.mock import MagicMock, patch, call
from ...tests.utils import verificar_attrs_instancias

from use_cases.contar_bois_piquete import (ContarBoisPiqueteInputPort,
                                               ContarBoisPiqueteOutputPort,
                                               ContarBoisPiqueteUseCase,
                                               Bebedouro,
                                               Boi,
                                               Coucho,
                                               YoloContarBois,
                                               YoloIdentificarBebedouroCoucho,
                                               YoloRecortarImagemPiquete)


def test_instancias_use_cases():
    instancias = (
        ContarBoisPiqueteInputPort,
        ContarBoisPiqueteOutputPort,
        ContarBoisPiqueteUseCase,
        Bebedouro,
        Boi,
        Coucho,
        YoloRecortarImagemPiquete,
        YoloContarBois,
        YoloIdentificarBebedouroCoucho)
    
    verificar_attrs_instancias(instancias)


class BoiTestCase(TestCase):
    def setUp(self):
        self.boi = Boi(MagicMock(), MagicMock())

    def test_alterar_estado(self):
        self.boi.alterar_estado("Standing-Cow")

        self.assertEqual(self.boi.estado, "Standing-Cow")



class YoloContarBoisTestCase(TestCase):
    def setUp(self):
        self.algoritmo = YoloContarBois(MagicMock())

    @patch("use_cases.contar_bois_piquete.yolo_contar_bois.YOLO")
    def test_pegar_modelo(self, mock_yolo: MagicMock):
        modelo = self.algoritmo.pegar_modelo()

        mock_yolo.assert_called_once_with(self.algoritmo.caminho_modelo)

        self.assertEqual(mock_yolo(), modelo)

    @patch("use_cases.contar_bois_piquete.yolo_contar_bois.Boi")
    def test_contar(self, mock_boi: MagicMock):
        mock_modelo = MagicMock()
        mock_img = MagicMock()

        mock_boi1 = MagicMock()
        mock_boi2 = MagicMock()

        mock_boi1.boxes.boxes.__getitem__.return_value = [1, 1, 1, 0]
        mock_boi1.boxes.xyxy.__getitem__.return_value = [255.1, 255.1, 255.1, 255.1]

        mock_boi2.boxes.boxes.__getitem__.return_value = [0, 0, 0, 1]
        mock_boi2.boxes.xyxy.__getitem__.return_value = [355.1, 355.1, 355.1, 355.1]

        mock_bois = (
            mock_boi1,
            mock_boi2)

        mock_modelo.predict.return_value.__getitem__.return_value = mock_bois

        calls_bois = (
            call((255, 255, 255, 255), "Lying-Cow"),
            call((355, 355, 355, 355), "Standing-Cow"))

        resultado = list(self.algoritmo.contar(mock_modelo, mock_img))

        mock_modelo.predict.assert_called_once_with(
            source=(mock_img.dados, ),
            box=False,
            hide_labels=True,
            hide_conf=True)
        
        mock_boi.assert_has_calls(calls_bois)

        self.assertEqual([mock_boi(), mock_boi()], resultado)


class YoloIdentificarBebedouroCouchoTestCase(TestCase):
    def setUp(self):
        mock_caminho_modelo = MagicMock()

        self.algoritmo = YoloIdentificarBebedouroCoucho(mock_caminho_modelo)
    
    @patch("use_cases.contar_bois_piquete.yolo_identificar_bebedouro_coucho.YOLO")
    def test_pegar_modelo(self, mock_yolo: MagicMock):
        modelo = self.algoritmo.pegar_modelo()

        mock_yolo.assert_called_once_with(self.algoritmo.caminho_modelo)

        self.assertEqual(mock_yolo(), modelo)

    @patch("use_cases.contar_bois_piquete.yolo_identificar_bebedouro_coucho.cv")
    def test_pegar_contorno(self, mock_cv: MagicMock):
        mock_mascara = MagicMock()

        mock_cv.findContours.return_value = (1, 1)

        resultado = self.algoritmo._pegar_contornos(mock_mascara)

        mock_cv.findContours.assert_called_once_with(mock_mascara, mock_cv.RETR_EXTERNAL, mock_cv.CHAIN_APPROX_SIMPLE)

        self.assertEqual(mock_cv.findContours()[0], resultado)
    
    @patch.object(YoloIdentificarBebedouroCoucho, "_pegar_contornos")
    @patch("use_cases.contar_bois_piquete.yolo_identificar_bebedouro_coucho.np")
    @patch("use_cases.contar_bois_piquete.yolo_identificar_bebedouro_coucho.Coucho")
    @patch("use_cases.contar_bois_piquete.yolo_identificar_bebedouro_coucho.Bebedouro")
    def test_identificar_couchos_bebedouros(self,
                                            mock_bebedouro: MagicMock,
                                            mock_coucho: MagicMock,
                                            mock_np: MagicMock,
                                            mock_pegar_contornos: MagicMock):
        mock_modelo = MagicMock()
        mock_img = MagicMock()

        mock_modelo.predict.return_value.__getitem__.return_value = MagicMock(boxes=MagicMock(),
                                                                              masks=MagicMock())

        mock_mascaras = mock_modelo.predict.return_value[0].masks.cpu.return_value.numpy.return_value
        mock_caixas = mock_modelo.predict.return_value[0].boxes

        mock_mascara1 = MagicMock()
        mock_mascara2 = MagicMock()

        mock_caixa1 = MagicMock()
        mock_caixa1.boxes.__getitem__.return_value = [0, 0, 0, 1]

        mock_caixa2 = MagicMock()
        mock_caixa2.boxes.__getitem__.return_value = [1, 1, 1, 0]

        mock_mascaras.__iter__.return_value = [mock_mascara1, mock_mascara2]
        mock_caixas.__iter__.return_value = [mock_caixa1, mock_caixa2]

        resultado = list(self.algoritmo.identificar_couchos_bebedouros(mock_modelo, mock_img))

        mock_modelo.predict.assert_called_once_with(
            source=(mock_img.dados, ),
            box=False,
            hide_labels=True,
            hide_conf=True)
        
        mock_modelo.predict()[0].masks.cpu.assert_called_once()
        mock_modelo.predict()[0].masks.cpu().numpy.assert_called_once()

        for mock_mascara in mock_mascaras:
            mock_mascara.masks.astype.assert_called_once_with(mock_np.uint8)

        calls_pegar_contornos = (
            call(mock_mascara1.masks.astype()),
            call(mock_mascara2.masks.astype())
        )

        mock_pegar_contornos.assert_has_calls(calls_pegar_contornos)

        mock_bebedouro.assert_called_once_with(mock_pegar_contornos())
        mock_coucho.assert_called_once_with(mock_pegar_contornos())

        self.assertEqual([mock_coucho(), mock_bebedouro()], resultado)


class YoloRecortarImagemPiqueteTestCase(TestCase):
    def setUp(self):
        mock_caminho_modelo = MagicMock()

        self.algoritmo = YoloRecortarImagemPiquete(mock_caminho_modelo)

    @patch("use_cases.contar_bois_piquete.yolo_recortar_imagem_piquete.YOLO")
    def test_pegar_modelo(self, mock_yolo: MagicMock):
        modelo = self.algoritmo.pegar_modelo()

        mock_yolo.assert_called_once_with(self.algoritmo.caminho_modelo)

        self.assertEqual(mock_yolo(), modelo)

    def test_solucionar_resultado(self):
        mock_resultados = [1, 2, 3]

        resultado = self.algoritmo._selecionar_resultado(mock_resultados)

        self.assertEqual(mock_resultados[0], resultado)

    @patch("use_cases.contar_bois_piquete.yolo_recortar_imagem_piquete.np")
    @patch.object(YoloRecortarImagemPiquete, "_selecionar_resultado")
    def test_detectar_mascara_piquete(self, mock_selecionar_resultado: MagicMock, mock_np: MagicMock):
        mock_modelo = MagicMock()
        mock_img = MagicMock()

        resultado = self.algoritmo._detectar_mascara_piquete(mock_modelo, mock_img)

        mock_modelo.predict.assert_called_once_with(
            source=(mock_img, ),
            box=False,
            hide_labels=True,
            hide_conf=True)
        
        mock_selecionar_resultado.assert_called_once_with(mock_modelo.predict())

        mock_masks = mock_selecionar_resultado().masks.masks
        
        mock_masks.__getitem__.assert_called_once_with(0)
        mock_masks.__getitem__().cpu.assert_called_once()
        mock_masks.__getitem__().cpu().numpy.assert_called_once()
        mock_masks.__getitem__().cpu().numpy().astype.assert_called_once_with(mock_np.uint8)

        mock_mascara = mock_masks.__getitem__().cpu().numpy().astype()

        self.assertEqual(mock_mascara, resultado)


class ContarBoisPiqueteUseCaseTestCase(TestCase):
    def setUp(self):
        mock_input_port = MagicMock()

        self.use_case = ContarBoisPiqueteUseCase(mock_input_port)
    
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    def test_dot(self, mock_np: MagicMock):
        mock_v1, mock_v2 = MagicMock(), MagicMock()

        resultado = self.use_case._dot(mock_v1, mock_v2)

        mock_np.dot.assert_called_once_with(mock_v1, mock_v2)

        self.assertEqual(mock_np.dot(), resultado)

    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    def test_project(self, mock_np: MagicMock):
        mock_vertices = MagicMock()
        mock_axis = MagicMock()

        self.use_case._project(mock_vertices, mock_axis)

        mock_np.dot.assert_called_once_with(mock_vertices, mock_axis)

        mock_np.min.assert_called_once_with(mock_np.dot())
        mock_np.max.assert_called_once_with(mock_np.dot())

        esperado = (mock_np.min(), mock_np.max())
        resultado = self.use_case._project(mock_vertices, mock_axis)

        self.assertEqual(resultado, esperado)

    def test_overlap(self):
        mock_a = (0, 0)
        mock_b = (1, 1)

        esperado = mock_a[0] <= mock_b[1] and mock_b[0] <= mock_a[1]

        resultado = self.use_case._overlap(mock_a, mock_b)

        self.assertEqual(esperado, resultado)
    
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    def test_get_edges(self, mock_np: MagicMock):
        mock_vertices = MagicMock()

        esperado = mock_vertices - mock_np.roll.return_value

        resultado = self.use_case._get_edges(mock_vertices)

        mock_np.roll.assert_called_once_with(mock_vertices, shift=1, axis=0)

        self.assertEqual(esperado, resultado)

    
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    def test_get_normals(self, mock_np: MagicMock):
        mock_edges = MagicMock()
        
        resultado = self.use_case._get_normals(mock_edges)
        
        mock_np.column_stack.assert_called_once_with(
            (-mock_edges[:, 1], mock_edges[:, 0]))
        
        self.assertEqual(mock_np.column_stack(), resultado)

    
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    def test_box_vertices(self, mock_np: MagicMock):
        mock_box = MagicMock()

        resultado = self.use_case._box_vertices(mock_box)

        mock_np.array.assert_called_once_with([
            (mock_box[0], mock_box[1]),
            (mock_box[2], mock_box[1]),
            (mock_box[2], mock_box[3]),
            (mock_box[0], mock_box[3]),])

        self.assertEqual(mock_np.array(), resultado)

    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    @patch.object(ContarBoisPiqueteUseCase, "_box_vertices")
    @patch.object(ContarBoisPiqueteUseCase, "_get_edges")
    @patch.object(ContarBoisPiqueteUseCase, "_get_normals")
    @patch.object(ContarBoisPiqueteUseCase, "_project")
    @patch.object(ContarBoisPiqueteUseCase, "_overlap", return_value=True)
    def test_box_vs_polygon_collision_overlap(self,
                                              mock_overlap: MagicMock,
                                              mock_project: MagicMock,
                                              mock_get_normals: MagicMock,
                                              mock_get_edges: MagicMock,
                                              mock_box_vertices: MagicMock,
                                              mock_np: MagicMock):
        mock_box = MagicMock()
        mock_polygon = MagicMock()

        mock_get_normals.return_value = (
            MagicMock(),)

        resultado =self.use_case._box_vs_polygon_collision(mock_box, mock_polygon)

        mock_box_vertices.assert_called_once_with(mock_box)
        mock_np.array(mock_polygon, dtype=mock_np.float32)

        calls_get_edges = (
            call(mock_box_vertices.return_value),
            call(mock_np.array()))
        
        mock_get_edges.assert_has_calls(calls_get_edges)

        calls_get_edges[0].reshape.assert_called_once_with(-1, 2)
        calls_get_edges[1].reshape.assert_called_once_with(-1, 2)

        mock_np.concatenate.assert_called_once_with(
            (mock_get_edges().reshape(), mock_get_edges().reshape()), axis=0)
        
        mock_get_normals.assert_called_once_with(mock_np.concatenate())

        calls_project = (
            call(mock_box_vertices(), mock_get_normals()[0]),
            call(mock_np.array(), mock_get_normals()[0]))

        mock_project.assert_has_calls(calls_project)

        mock_overlap.assert_called_once_with(mock_project(), mock_project())
        
        self.assertEqual(True, resultado)

    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    @patch.object(ContarBoisPiqueteUseCase, "_box_vertices")
    @patch.object(ContarBoisPiqueteUseCase, "_get_edges")
    @patch.object(ContarBoisPiqueteUseCase, "_get_normals")
    @patch.object(ContarBoisPiqueteUseCase, "_project")
    @patch.object(ContarBoisPiqueteUseCase, "_overlap", return_value=False)
    def test_box_vs_polygon_collision_not_overlap(self,
                                                  mock_overlap: MagicMock,
                                                  mock_project: MagicMock,
                                                  mock_get_normals: MagicMock,
                                                  mock_get_edges: MagicMock,
                                                  mock_box_vertices: MagicMock,
                                                  mock_np: MagicMock):
        mock_box = MagicMock()
        mock_polygon = MagicMock()

        mock_get_normals.return_value = (
            MagicMock(),)

        resultado =self.use_case._box_vs_polygon_collision(mock_box, mock_polygon)

        mock_box_vertices.assert_called_once_with(mock_box)
        mock_np.array(mock_polygon, dtype=mock_np.float32)

        calls_get_edges = (
            call(mock_box_vertices.return_value),
            call(mock_np.array()))
        
        mock_get_edges.assert_has_calls(calls_get_edges)

        calls_get_edges[0].reshape.assert_called_once_with(-1, 2)
        calls_get_edges[1].reshape.assert_called_once_with(-1, 2)

        mock_np.concatenate.assert_called_once_with(
            (mock_get_edges().reshape(), mock_get_edges().reshape()), axis=0)
        
        mock_get_normals.assert_called_once_with(mock_np.concatenate())

        calls_project = (
            call(mock_box_vertices(), mock_get_normals()[0]),
            call(mock_np.array(), mock_get_normals()[0]))

        mock_project.assert_has_calls(calls_project)

        mock_overlap.assert_called_once_with(mock_project(), mock_project())
        
        self.assertEqual(False, resultado)

    def test_identificar_bebedouro_coucho(self):
        mock_img = MagicMock()

        resultado = self.use_case._identificar_bebedouro_coucho(mock_img)

        mock_algoritmo = self.use_case.input_port.algoritmo_recortar_bebedouro_coucho

        mock_algoritmo.pegar_modelo.assert_called_once()

        mock_algoritmo.identificar_couchos_bebedouros.assert_called_once_with(
            mock_algoritmo.pegar_modelo(),
            mock_img)
        
        self.assertEqual(mock_algoritmo.identificar_couchos_bebedouros(), resultado)

    def test_identificar_bois(self):
        mock_img = MagicMock()

        resultado = self.use_case._identificar_bois(mock_img)

        mock_algoritmo = self.use_case.input_port.algoritmo_contar_bois

        mock_algoritmo.pegar_modelo.assert_called_once()

        mock_algoritmo.contar.assert_called_once_with(
            mock_algoritmo.pegar_modelo(), mock_img)

        self.assertEqual(mock_algoritmo.contar(), resultado)

    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Imagem")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.uuid4")
    def test_pegar_img_piquete(self, mock_uuid4: MagicMock, mock_imagem: MagicMock):
        mock_imagem_param = MagicMock()

        resultado = self.use_case._pegar_img_piquete(mock_imagem_param)

        mock_algoritmo = self.use_case.input_port.algoritmo_identificar_piquete

        mock_algoritmo.pegar_modelo.assert_called_once()

        mock_algoritmo.recortar_imagem_piquete.assert_called_once_with(
            mock_algoritmo.pegar_modelo(), mock_imagem_param)
        
        mock_uuid4.assert_called_once()

        mock_imagem.assert_called_once_with(
            mock_uuid4(),
            mock_imagem_param.latitude,
            mock_imagem_param.longitude,
            mock_imagem_param.altitude,
            mock_algoritmo.recortar_imagem_piquete(),
            mock_imagem_param.data,)
        
        self.assertEqual(mock_imagem(), resultado)
    
    @patch.object(ContarBoisPiqueteUseCase, "_box_vs_polygon_collision", return_value=True)
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Boi")
    def test_validar_bois_comendo_bebendo_colisao_bebe(self, mock_boi: MagicMock, mock_box_vs_poly_collision: MagicMock):
        mock_bebedouro = Bebedouro(MagicMock())

        mock_bois = (MagicMock(), MagicMock())
        mock_bebedouros_couchos = (mock_bebedouro, )

        resultado = self.use_case._validar_bois_comendo_bebendo(mock_bois, mock_bebedouros_couchos)

        calls_boi = (
            call(mock_bois[0].caixa, "Drinking-Cow"),
            call(mock_bois[1].caixa, "Drinking-Cow"))
        
        mock_boi.assert_has_calls(calls_boi)

        self.assertEqual([mock_boi(), mock_boi()], resultado)
    
    @patch.object(ContarBoisPiqueteUseCase, "_box_vs_polygon_collision", return_value=True)
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Boi")
    def test_validar_bois_comendo_bebendo_colisao_com(self, mock_boi: MagicMock, mock_box_vs_poly_collision: MagicMock):
        mock_coucho = Coucho(MagicMock())

        mock_bois = (MagicMock(), MagicMock())
        mock_bebedouros_couchos = (mock_coucho, )

        resultado = self.use_case._validar_bois_comendo_bebendo(mock_bois, mock_bebedouros_couchos)

        calls_boi = (
            call(mock_bois[0].caixa, "Eating-Cow"),
            call(mock_bois[1].caixa, "Eating-Cow"))
        
        mock_boi.assert_has_calls(calls_boi)

        self.assertEqual([mock_boi(), mock_boi()], resultado)
    
    @patch.object(ContarBoisPiqueteUseCase, "_box_vs_polygon_collision", return_value=False)
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Boi")
    def test_validar_bois_comendo_bebendo_sem_colisao(self, mock_boi: MagicMock, mock_box_vs_poly_collision: MagicMock):
        mock_coucho = Coucho(MagicMock())

        mock_bois = (MagicMock(estado="Lying-Cow"), MagicMock(estado="Standing-Cow"))
        mock_bebedouros_couchos = (mock_coucho, )

        resultado = self.use_case._validar_bois_comendo_bebendo(mock_bois, mock_bebedouros_couchos)

        calls_boi = (
            call(mock_bois[0].caixa, "Lying-Cow"),
            call(mock_bois[1].caixa, "Standing-Cow"))
        
        mock_boi.assert_has_calls(calls_boi)

        self.assertEqual([mock_boi(), mock_boi()], resultado)

    def test_contar_bois(self):
        esperado = {
            "Lying-Cow": 4,
            "Standing-Cow": 3,
            "Drinking-Cow": 2,
            "Eating-Cow": 1
        }

        mock_bois = (
            MagicMock(estado="Lying-Cow"),
            MagicMock(estado="Lying-Cow"),
            MagicMock(estado="Lying-Cow"),
            MagicMock(estado="Lying-Cow"),
            MagicMock(estado="Standing-Cow"),
            MagicMock(estado="Standing-Cow"),
            MagicMock(estado="Standing-Cow"),
            MagicMock(estado="Drinking-Cow"),
            MagicMock(estado="Drinking-Cow"),
            MagicMock(estado="Eating-Cow"))

        resultado = self.use_case._contar_bois(mock_bois)

        self.assertEqual(esperado, resultado)

    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Cores")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.cv")
    def test_desenhar_bois_imagem(self, mock_cv: MagicMock, mock_cores: MagicMock, mock_np: MagicMock):
        mock_dados_imagem = MagicMock()

        mock_boi1 = MagicMock(estado="Lying-Cow")
        mock_boi1.caixa = [1, 2, 3, 4]

        mock_boi2 = MagicMock(estado="Standing-Cow")
        mock_boi2.caixa = [5, 6, 7, 8]

        mock_boi3 = MagicMock(estado="Eating-Cow")
        mock_boi3.caixa = [9, 10, 11, 12]

        mock_boi4 = MagicMock(estado="Drinking-Cow")
        mock_boi4.caixa = [13, 14, 15, 16]

        mock_bois = mock_boi1, mock_boi2, mock_boi3, mock_boi4

        resultado = self.use_case._desenhar_bois_imagem(mock_dados_imagem, mock_bois)

        mock_np.copy.assert_called_once_with(mock_dados_imagem)

        calls_rectangle = (
            call(mock_np.copy(), [1, 2], [3, 4], mock_cores.azul, 1),
            call(mock_np.copy(), [5, 6], [7, 8], mock_cores.vermelho, 1),
            call(mock_np.copy(), [9, 10], [11, 12], mock_cores.verde, 1),
            call(mock_np.copy(), [13, 14], [15, 16], mock_cores.amarelo, 1))

        mock_cv.rectangle.assert_has_calls(calls_rectangle)

        self.assertEqual(mock_np.copy(), resultado)

    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.np")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.cv")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Cores")
    def test_desenhar_bebedouros_couchos(self, mock_cores: MagicMock, mock_cv: MagicMock, mock_np: MagicMock):
        mock_dados_imagem = MagicMock()

        mock_bebedouro = Bebedouro(MagicMock())
        mock_coucho = Coucho(MagicMock())

        mock_bebedouros_couchos = [mock_bebedouro, mock_coucho]

        resultado = self.use_case._desenhar_bebedouros_couchos(mock_dados_imagem,
                                                               mock_bebedouros_couchos)

        mock_np.copy.assert_called_once_with(mock_dados_imagem)
        
        calls_polylines = (
            call(mock_np.copy(), mock_bebedouro.poligono, isClosed=True, color=mock_cores.ciano),
            call(mock_np.copy(), mock_coucho.poligono, isClosed=True, color=mock_cores.magenta))

        mock_cv.polylines.assert_has_calls(calls_polylines)

        self.assertEqual(mock_np.copy(), resultado)

    @patch.object(ContarBoisPiqueteUseCase, "_desenhar_bois_imagem")
    @patch.object(ContarBoisPiqueteUseCase, "_desenhar_bebedouros_couchos")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Imagem")
    def test_desenhar_resultados_imagem(self,
                                        mock_imagem_classe: MagicMock,
                                        mock_desenhar_bebedouros_couchos: MagicMock,
                                        mock_desenhar_bois_imagem: MagicMock):
        mock_bebedouros_couchos = MagicMock()
        mock_bois = MagicMock()
        mock_imagem = MagicMock()

        resultado = self.use_case._desenhar_resultados_imagem(mock_imagem,
                                                               mock_bois,
                                                               mock_bebedouros_couchos)
        
        mock_desenhar_bois_imagem.assert_called_once_with(mock_imagem.dados, mock_bois)
        mock_desenhar_bebedouros_couchos.assert_called_once_with(mock_desenhar_bois_imagem(),
                                                                 mock_bebedouros_couchos)

        mock_imagem_classe.assert_called_once_with(
            mock_imagem.id_imagem,
            mock_imagem.latitude,
            mock_imagem.longitude,
            mock_imagem.altitude,
            mock_desenhar_bebedouros_couchos(),
            mock_imagem.data)

        self.assertEqual(mock_imagem_classe(), resultado)

    @patch.object(ContarBoisPiqueteUseCase, "_pegar_img_piquete")
    @patch.object(ContarBoisPiqueteUseCase, "_identificar_bebedouro_coucho")
    @patch.object(ContarBoisPiqueteUseCase, "_identificar_bois")
    @patch.object(ContarBoisPiqueteUseCase, "_validar_bois_comendo_bebendo")
    @patch.object(ContarBoisPiqueteUseCase, "_contar_bois")
    @patch.object(ContarBoisPiqueteUseCase, "_desenhar_resultados_imagem")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.uuid4")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.list")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.Contagem")
    def test_contar(self,
                    mock_contagem: MagicMock,
                    mock_list: MagicMock,
                    mock_uuid4: MagicMock,
                    mock_desenhar_resultados_imagem: MagicMock,
                    mock_contar_bois: MagicMock,
                    mock_validar_bois_comendo_bebendo: MagicMock,
                    mock_identificar_bois: MagicMock,
                    mock_identificar_bebedouro_coucho: MagicMock,
                    mock_pegar_img_piquete: MagicMock):
        mock_imagem = MagicMock()

        resultado = self.use_case._contar(mock_imagem)

        mock_pegar_img_piquete.assert_called_once_with(mock_imagem)

        mock_identificar_bebedouro_coucho.assert_called_once_with(mock_pegar_img_piquete())

        mock_identificar_bois.assert_called_once_with(mock_pegar_img_piquete())

        list_calls = (
            call(mock_identificar_bebedouro_coucho()),
            call(mock_identificar_bois()))

        mock_list.assert_has_calls(list_calls)

        mock_validar_bois_comendo_bebendo.assert_called_once_with(
            mock_list(), mock_list())
        
        mock_contar_bois.assert_called_once_with(mock_validar_bois_comendo_bebendo())

        mock_desenhar_resultados_imagem.assert_called_once_with(mock_pegar_img_piquete(),
                                                                mock_validar_bois_comendo_bebendo(),
                                                                mock_list())

        mock_uuid4.assert_called_once()

        mock_contagem.assert_called_once_with(
            mock_uuid4(),
            mock_contar_bois()["Lying-Cow"],
            mock_contar_bois()["Standing-Cow"],
            mock_contar_bois()["Eating-Cow"],
            mock_contar_bois()["Drinking-Cow"],
            mock_imagem.data,
            mock_desenhar_resultados_imagem())
        
        self.assertEqual(mock_contagem(), resultado)

    @patch.object(ContarBoisPiqueteUseCase, "_contar")
    @patch("use_cases.contar_bois_piquete.contar_bois_piquete_use_case.ContarBoisPiqueteOutputPort")
    def test_run(self,
                 mock_output_port: MagicMock,
                 mock_contar: MagicMock):
        mock_imagem1 = MagicMock()
        mock_imagem2 = MagicMock()

        mock_imagens = [mock_imagem1, mock_imagem2]

        self.use_case.input_port.imagens = mock_imagens

        resultado = self.use_case.run()

        calls_contar = [call(mock_imagem1), call(mock_imagem2)]

        mock_output_port.assert_called_once_with([mock_contar(), mock_contar()])

        mock_contar.assert_has_calls(calls_contar)

        self.assertEqual(mock_output_port(), resultado)
