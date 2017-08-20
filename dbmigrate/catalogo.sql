-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-06-2017 a las 00:31:48
-- Versión del servidor: 10.1.21-MariaDB
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `catalogo`
--
CREATE DATABASE IF NOT EXISTS `catalogo` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `catalogo`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `busqueda`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `busqueda` (IN `consulta` VARCHAR(250), IN `rol` VARCHAR(50))  BEGIN
DECLARE keyword VARCHAR(100) DEFAULT ' ';
DECLARE i INT DEFAULT 1;
DECLARE j INT DEFAULT 1;
DECLARE wordCount INT DEFAULT 0;
DECLARE auxKeyword VARCHAR(250);
DECLARE wherecomun VARCHAR(250) DEFAULT '';
DECLARE condicion VARCHAR(250) DEFAULT '';



DROP TABLE IF EXISTS Recurso_Encontrado;
CREATE TEMPORARY TABLE Recurso_Encontrado (
    `idRecurso` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `icono` varchar(250) NOT NULL,
  `descripcion` TEXT NOT NULL,
  `docente` tinyint(1) DEFAULT '0',
  `puntuacion` decimal(2,1) DEFAULT '0.0',
  `idCategoria` int(11) DEFAULT NULL,
  `idTipoRecurso` int(11) NOT NULL,
  `guiaDeAplicacion` varchar(250) DEFAULT NULL,
  `guiaDeUsuario` varchar(250) DEFAULT NULL,
  `guiaTecnica` varchar(250) DEFAULT NULL,
  `idModoUso` int(11) NOT NULL,
  `revisado` tinyint(1) DEFAULT '0',
  `descargas` bigint(20) DEFAULT '0',
  `tamano` int(11) DEFAULT 0,
  `peso` int(11) DEFAULT 0,
  PRIMARY KEY (`idRecurso`)
    );




WHILE keyword not like '' DO
	SET keyword = SPLIT_STR(consulta, ' ',i);
	IF keyword not like '' THEN
		SET wordCount = wordCount + 1;
    END IF;
    SET i = i + 1;
END WHILE;



SET i=1;




WHILE keyword not like '' DO

	SET keyword = SPLIT_STR(consulta,' ',i);

	IF keyword not like '' then



			INSERT INTO Recurso_Encontrado


            (
				SELECT r.*,i+10
				FROM recurso r
				where MATCH(r.nombre) against(CONCAT(keyword,'*') in boolean mode)
				)
				UNION
				(
				SELECT DISTINCT r.idRecurso, r.docente, r.revisado,i
				FROM nivel n, grado g, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE n.idNivel = g.idNivel and g.idGrado = ag.idGrado and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  MATCH(n.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				 UNION
				 (
				SELECT DISTINCT r.*,i
				FROM nivel n, grado g, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE n.idNivel = g.idNivel and g.idGrado = ag.idGrado and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  g.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM asignatura a, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE a.idAsignatura = ag.idAsignatura and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  a.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM nivel n, grado g, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE n.idNivel = g.idNivel and g.idGrado = ag.idGrado and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  MATCH(u.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  MATCH(c.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM asignatura a,
					 asignatura_grado ag,
					 asignatura_grado_indicador_logro agil,
					 indicador_logro il,
					 recurso_indicador_logro ril, recurso r
				WHERE a.idAsignatura = ag.idAsignatura and
					  ag.idAsignaturaGrado = agil.idAsignaturaGrado  and agil.idIndicadorLogro = il.idIndicadorLogro and
					  il.idIndicadorLogro = ril.idIndicadorLogro  and ril.idRecurso = r.idRecurso and
					  MATCH(il.descripcion) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM categoria cat, recurso r
				WHERE cat.idCategoria = r.idCategoria and
					  cat.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM tipo_recurso tr, recurso r
				WHERE tr.idTipoRecurso = r.idTipoRecurso and
					  tr.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM etiqueta et, recurso_etiqueta re, recurso r
				WHERE et.idEtiqueta = re.idEtiqueta and
					  re.idRecurso = r.idRecurso and
					  MATCH(et.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,i
				FROM autor au, autor_recurso aur, recurso r
				WHERE au.idAutor = aur.idAutor and
					  aur.idRecurso = r.idRecurso and
					  MATCH(au.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )

                 ON DUPLICATE KEY UPDATE peso = peso + i
					  ;
              end if;
	SET i = i+1;
END WHILE;





SET keyword = '';


WHILE j<=wordCount DO

    IF keyword like '' then
		SET keyword = CONCAT(keyword, SPLIT_STR(consulta, ' ',j));
	ELSE
		SET keyword = CONCAT(keyword, ' ', SPLIT_STR(consulta, ' ',j));
	END IF;



			INSERT INTO Recurso_Encontrado
				(
				SELECT r.*,j+10
                FROM Recurso r
				where MATCH(r.nombre) against(CONCAT(keyword,'*') in boolean mode)
				 )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM nivel n, grado g, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE n.idNivel = g.idNivel and g.idGrado = ag.idGrado and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  MATCH(n.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				 UNION
				 (
				SELECT DISTINCT r.*,j
				FROM nivel n, grado g, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE n.idNivel = g.idNivel and g.idGrado = ag.idGrado and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  g.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM asignatura a, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE a.idAsignatura = ag.idAsignatura and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  a.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM nivel n, grado g, asignatura_grado ag, unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE n.idNivel = g.idNivel and g.idGrado = ag.idGrado and
					  ag.idAsignaturaGrado = u.idAsignaturaGrado  and
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  MATCH(u.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM unidad u, contenido c, recurso_contenido rc, recurso r
				WHERE
					  u.idUnidad = c.idUnidad and
					  c.idContenido = rc.idContenido and
					  rc.idRecurso = r.idRecurso and
					  MATCH(c.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM asignatura a,
					 asignatura_grado ag,
					 asignatura_grado_indicador_logro agil,
					 indicador_logro il,
					 recurso_indicador_logro ril, recurso r
				WHERE a.idAsignatura = ag.idAsignatura and
					  ag.idAsignaturaGrado = agil.idAsignaturaGrado  and agil.idIndicadorLogro = il.idIndicadorLogro and
					  il.idIndicadorLogro = ril.idIndicadorLogro  and ril.idRecurso = r.idRecurso and
					  MATCH(il.descripcion) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM categoria cat, recurso r
				WHERE cat.idCategoria = r.idCategoria and
					  cat.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM tipo_recurso tr, recurso r
				WHERE tr.idTipoRecurso = r.idTipoRecurso and
					  tr.nombre like CONCAT('%',keyword,'%')
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM etiqueta et, recurso_etiqueta re, recurso r
				WHERE et.idEtiqueta = re.idEtiqueta and
					  re.idRecurso = r.idRecurso and
					  MATCH(et.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
				UNION
				(
				SELECT DISTINCT r.*,j
				FROM autor au, autor_recurso aur, recurso r
				WHERE au.idAutor = aur.idAutor and
					  aur.idRecurso = r.idRecurso and
					  MATCH(au.nombre) AGAINST(CONCAT(keyword,'*') IN BOOLEAN MODE)
					  )
					  ON DUPLICATE KEY UPDATE peso = peso+j
					  ;


	SET j = j+1;
END WHILE;



IF rol like 'Estudiante' THEN
	SELECT idRecurso, nombre, icono, descripcion, docente, puntuacion, idCategoria, idTipoRecurso, guiaDeAplicacion, guiaDeUsuario, guiaTecnica, idModoUso, revisado, descargas
	FROM Recurso_Encontrado reen WHERE reen.revisado = 1 AND reen.docente = 0
    ORDER BY reen.peso desc
    limit 60;
ELSEIF rol like 'Docente'THEN
	SELECT idRecurso, nombre, icono, descripcion, docente, puntuacion, idCategoria, idTipoRecurso, guiaDeAplicacion, guiaDeUsuario, guiaTecnica, idModoUso, revisado, descargas
	FROM Recurso_Encontrado reen WHERE reen.revisado = 1
    ORDER BY reen.peso desc
    limit 60;
ELSE
	SELECT idRecurso, nombre, icono, descripcion, docente, puntuacion, idCategoria, idTipoRecurso, guiaDeAplicacion, guiaDeUsuario, guiaTecnica, idModoUso, revisado, descargas, peso
	FROM Recurso_Encontrado reen
    ORDER BY reen.peso desc
    limit 60;
END IF;





END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `SPLIT_STR`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `SPLIT_STR` (`x` VARCHAR(255), `delim` VARCHAR(12), `pos` INT) RETURNS VARCHAR(255) CHARSET utf8 RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '')$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivo_fuente`
--

-- DROP TABLE IF EXISTS `archivo_fuente`;
CREATE TABLE `archivo_fuente` (
  `idArchivoFuente` int(11) NOT NULL,
  `idVersion` int(11) NOT NULL,
  `esWeb` tinyint(1) DEFAULT '0',
  `direccionRecurso` varchar(250) DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `direccionEjecutable` varchar(250) DEFAULT NULL,
  `requiereInstalador` tinyint(1) DEFAULT '0',
  `tamano` decimal(20,0) DEFAULT NULL,
  `titulo` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `archivo_fuente`
--

INSERT INTO `archivo_fuente` (`idArchivoFuente`, `idVersion`, `esWeb`, `direccionRecurso`, `url`, `direccionEjecutable`, `requiereInstalador`, `tamano`, `titulo`) VALUES
(1420, 1409, 0, '/recursos/imagen/eae15c0596daab65fc709eafbfa2791c/Lighthouse.jpg', NULL, NULL, 1, '561276', NULL),
(1421, 1409, 0, '/recursos/imagen/2224d6c094614055110efd184dc24311/Desert.jpg', NULL, NULL, 1, '845941', NULL),
(1422, 1409, 0, '/recursos/imagen/2bdb126aa772cc3bbe6197460ee6ddc8/Penguins.jpg', NULL, NULL, 1, '777835', NULL),
(1423, 1409, 0, '/recursos/imagen/d83320e1a89e809d8e2f9884b1d34f0b/Koala.jpg', NULL, NULL, 1, '780831', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivo_fuente_equipo`
--

DROP TABLE IF EXISTS `archivo_fuente_equipo`;
CREATE TABLE `archivo_fuente_equipo` (
  `idEquipo` int(11) NOT NULL,
  `idArchivoFuente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivo_fuente_idioma`
--

DROP TABLE IF EXISTS `archivo_fuente_idioma`;
CREATE TABLE `archivo_fuente_idioma` (
  `idIdioma` int(11) NOT NULL,
  `idArchivoFuente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `archivo_fuente_idioma`
--

INSERT INTO `archivo_fuente_idioma` (`idIdioma`, `idArchivoFuente`) VALUES
(1, 1420);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arquitectura`
--

DROP TABLE IF EXISTS `arquitectura`;
CREATE TABLE `arquitectura` (
  `idArquitectura` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `arquitectura`
--

INSERT INTO `arquitectura` (`idArquitectura`, `nombre`) VALUES
(1, 'X86'),
(2, 'amd64');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignatura`
--

DROP TABLE IF EXISTS `asignatura`;
CREATE TABLE `asignatura` (
  `idAsignatura` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `color` varchar(50) NOT NULL DEFAULT '#00BCD4',
  `icono` varchar(250) DEFAULT NULL,
  `esAreaDesarrollo` tinyint(1) DEFAULT '0',
  `orden` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `asignatura`
--

INSERT INTO `asignatura` (`idAsignatura`, `nombre`, `color`, `icono`, `esAreaDesarrollo`, `orden`) VALUES
(1, 'Programacion 3', '#00BCD4', NULL, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignatura_grado`
--

DROP TABLE IF EXISTS `asignatura_grado`;
CREATE TABLE `asignatura_grado` (
  `idGrado` int(11) NOT NULL,
  `idAsignatura` int(11) NOT NULL,
  `idAsignaturaGrado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignatura_grado_contenido`
--

DROP TABLE IF EXISTS `asignatura_grado_contenido`;
CREATE TABLE `asignatura_grado_contenido` (
  `idAsignaturaGrado` int(11) NOT NULL,
  `idContenido` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignatura_grado_indicador_logro`
--

DROP TABLE IF EXISTS `asignatura_grado_indicador_logro`;
CREATE TABLE `asignatura_grado_indicador_logro` (
  `idAsignaturaGrado` int(11) NOT NULL,
  `idIndicadorLogro` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

DROP TABLE IF EXISTS `autor`;
CREATE TABLE `autor` (
  `idAutor` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor_recurso`
--

DROP TABLE IF EXISTS `autor_recurso`;
CREATE TABLE `autor_recurso` (
  `idRecurso` int(11) NOT NULL,
  `idAutor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

DROP TABLE IF EXISTS `categoria`;
CREATE TABLE `categoria` (
  `idCategoria` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`idCategoria`, `nombre`, `descripcion`) VALUES
(4, 'Videojuegos', 'Conjunto de recursos relacionados a la temática de videojuegos'),
(5, '(PDM115) Programación para dispositivos móviles', 'Recursos para el aprendizaje y resultados de trabajos de la materia de PDM115'),
(6, '(HDP115) Herramientas de productividad', 'Recursos para el aprendizaje y resultados de trabajos de la materia de HDP115'),
(7, 'Programacion 2', 'Programacion Orientada a Objetos a nivel de Diseño'),
(8, 'Programacion 3', 'Programacion Orientada a Objetos a nivel de Programacion');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_cuestionario`
--

DROP TABLE IF EXISTS `categoria_cuestionario`;
CREATE TABLE `categoria_cuestionario` (
  `idCategoriaCuestionario` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `categoria_cuestionario`
--

INSERT INTO `categoria_cuestionario` (`idCategoriaCuestionario`, `codigo`, `nombre`, `descripcion`) VALUES
(1, '0001', 'Poo Basica', 'Conceptos de POO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `chunk`
--

DROP TABLE IF EXISTS `chunk`;
CREATE TABLE `chunk` (
  `idChunk` int(11) NOT NULL,
  `direccion` varchar(250) DEFAULT NULL,
  `codigo` char(32) DEFAULT NULL,
  `fechaCreacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentario`
--

DROP TABLE IF EXISTS `comentario`;
CREATE TABLE `comentario` (
  `idComentario` int(11) NOT NULL,
  `comentario` varchar(45) NOT NULL,
  `puntuacion` int(11) NOT NULL,
  `idRecurso` int(11) NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compatibilidad_plataforma`
--

DROP TABLE IF EXISTS `compatibilidad_plataforma`;
CREATE TABLE `compatibilidad_plataforma` (
  `idPlataformaArquitectura` int(11) NOT NULL,
  `idArchivoFuente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contenido`
--

DROP TABLE IF EXISTS `contenido`;
CREATE TABLE `contenido` (
  `idContenido` int(11) NOT NULL,
  `nombre` varchar(500) NOT NULL,
  `abreviatura` varchar(250) NOT NULL,
  `idUnidad` int(11) DEFAULT NULL,
  `orden` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contenido_actitudinal`
--

DROP TABLE IF EXISTS `contenido_actitudinal`;
CREATE TABLE `contenido_actitudinal` (
  `idContenidoActitudinal` int(11) NOT NULL,
  `nombre` varchar(500) NOT NULL,
  `abreviatura` varchar(250) DEFAULT NULL,
  `idContenido` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contenido_procedimental`
--

DROP TABLE IF EXISTS `contenido_procedimental`;
CREATE TABLE `contenido_procedimental` (
  `idContenidoProcedimental` int(11) NOT NULL,
  `nombre` varchar(500) NOT NULL,
  `abreviatura` varchar(250) DEFAULT NULL,
  `idContenido` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuestionario`
--

DROP TABLE IF EXISTS `cuestionario`;
CREATE TABLE `cuestionario` (
  `idCuestionario` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `idCategoriaCuestionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `cuestionario`
--

INSERT INTO `cuestionario` (`idCuestionario`, `nombre`, `descripcion`, `idCategoriaCuestionario`) VALUES
(1, 'autoevaluacion 1', 'Conceptos primera parte', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuestionario_asignatura`
--

DROP TABLE IF EXISTS `cuestionario_asignatura`;
CREATE TABLE `cuestionario_asignatura` (
  `idCuestionarioAsignatura` int(11) NOT NULL,
  `idCuestionario` int(11) NOT NULL,
  `idAsignatura` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `cuestionario_asignatura`
--

INSERT INTO `cuestionario_asignatura` (`idCuestionarioAsignatura`, `idCuestionario`, `idAsignatura`) VALUES
(1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipo`
--

DROP TABLE IF EXISTS `equipo`;
CREATE TABLE `equipo` (
  `idEquipo` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etiqueta`
--

DROP TABLE IF EXISTS `etiqueta`;
CREATE TABLE `etiqueta` (
  `idEtiqueta` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `extension`
--

DROP TABLE IF EXISTS `extension`;
CREATE TABLE `extension` (
  `idExtension` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `tipo` varchar(50) DEFAULT NULL,
  `extension` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grado`
--

DROP TABLE IF EXISTS `grado`;
CREATE TABLE `grado` (
  `idGrado` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `idNivel` int(11) NOT NULL,
  `orden` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `idioma`
--

DROP TABLE IF EXISTS `idioma`;
CREATE TABLE `idioma` (
  `idIdioma` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `idioma`
--

INSERT INTO `idioma` (`idIdioma`, `nombre`) VALUES
(1, 'Español'),
(2, 'Inglés'),
(3, 'Frances');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `indicador_logro`
--

DROP TABLE IF EXISTS `indicador_logro`;
CREATE TABLE `indicador_logro` (
  `idIndicadorLogro` int(11) NOT NULL,
  `descripcion` varchar(500) NOT NULL,
  `abreviatura` varchar(50) NOT NULL,
  `idContenido` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `licencia`
--

DROP TABLE IF EXISTS `licencia`;
CREATE TABLE `licencia` (
  `idLicencia` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `licencia`
--

INSERT INTO `licencia` (`idLicencia`, `nombre`, `descripcion`) VALUES
(1, 'Licencia Apache', 'Licencia Apache'),
(2, 'GNU Licence', 'GNU Licence'),
(3, 'Dominio Público', 'Dominio Público'),
(4, 'Copyright', 'Copyright'),
(5, 'EULA', 'EULA'),
(6, 'GNU/GPL', 'GNU/GPL'),
(7, 'MIT', 'MIT'),
(8, 'FreeBSD', 'FreeBSD'),
(9, 'CC-BY', 'CC-BY'),
(10, 'CC-SA', 'CC-SA'),
(11, 'CC-NC', 'CC-NC'),
(12, 'CC-BY-SA', 'CC-BY-SA'),
(13, 'CC-SA-NC', 'CC-SA-NC'),
(14, 'CC-BY-SA-NC', 'CC-BY-SA-NC');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `listas`
--

DROP TABLE IF EXISTS `listas`;
CREATE TABLE `listas` (
  `idListas` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `descripcion` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_recurso`
--

DROP TABLE IF EXISTS `lista_recurso`;
CREATE TABLE `lista_recurso` (
  `idListas` int(11) NOT NULL,
  `idRecurso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modo_uso`
--

DROP TABLE IF EXISTS `modo_uso`;
CREATE TABLE `modo_uso` (
  `idModoUso` int(11) NOT NULL,
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `modo_uso`
--

INSERT INTO `modo_uso` (`idModoUso`, `codigo`, `nombre`) VALUES
(1, 'APLICATIVO', 'Aplicativo'),
(2, 'WEB', 'Web'),
(3, 'IMAGEN', 'Imagen'),
(4, 'VIDEO', 'Video'),
(5, 'AUDIO', 'Audio'),
(6, 'LIBRO', 'Libros y documentos'),
(7, 'GOOGLEMAPS', 'Mapas'),
(8, 'YOUTUBE', 'Video de Youtube'),
(9, 'OTROS', 'Otros');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modo_uso_extension`
--

DROP TABLE IF EXISTS `modo_uso_extension`;
CREATE TABLE `modo_uso_extension` (
  `idModoUso` int(11) NOT NULL,
  `idExtension` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nivel`
--

DROP TABLE IF EXISTS `nivel`;
CREATE TABLE `nivel` (
  `idNivel` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `orden` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `opcion`
--

DROP TABLE IF EXISTS `opcion`;
CREATE TABLE `opcion` (
  `idOpcion` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `opcion`
--

INSERT INTO `opcion` (`idOpcion`, `codigo`, `nombre`, `descripcion`) VALUES
(2, 'recursos.subir', 'Subir nuevo recurso', 'Opción para subir nuevos recursos educativos'),
(3, 'recursos.administrar', 'Administrar recursos', 'Opción para administrar los recursos que se han subido'),
(5, 'descarga.listaDescarga', 'Listas de descargas', 'Opción para la descarga de una lista de recursos'),
(6, 'descarga.descargaPaquetes', 'Descargar paquetes', 'Opción para la descarga de paquetes'),
(8, 'programa.niveles', 'Ciclos', 'Opción para administrar los ciclos de estudio'),
(9, 'programa.unidades', 'Unidades', 'Opción para administrar las unidades de estudio'),
(10, 'programa.asignaturas', 'Asignaturas', 'Opción para administrar las asignaturas '),
(11, 'programa.grados', 'Grados', 'Opción para administrar los grados por ciclo de estudio'),
(12, 'programa.contenidos', 'Contenidos conceptuales', 'Opción para administrar los contenidos de estudio'),
(13, 'programa.contenidoProcedimental', 'Contenidos procedimentales', 'Opción la administracion de contenidos procedimentales '),
(14, 'programa.contenidoActitudinal', 'Contenidos actitudinales', 'Opción la administracion de contenidos actitudinales'),
(15, 'programa.indicadores', 'Indicador de logro', 'Opción la administracion de indicadores de logro'),
(17, 'mantenimientos.plataformas', 'Plataformas', 'Opción para los matenimientos de las plataformas'),
(18, 'mantenimientos.arquitecturas', 'Arquitecturas', 'Opción para los mantenimientos de Arquitecturas de computadoras'),
(19, 'mantenimientos.equipos', 'Equipos', 'Opción para los matenimientos de equipos'),
(20, 'mantenimientos.idiomas', 'Idiomas', 'Opción para los mantenimientos de idiomas '),
(21, 'mantenimientos.tiposRecursos', 'Tipos de recurso', 'Opción para los mantenimientos de los tipos de recursos'),
(22, 'mantenimientos.etiquetas', 'Etiquetas', 'Opción para los mantenimientos de las etiquetas disponobles'),
(23, 'mantenimientos.categorias', 'Categorias adicionales', 'Opción para los mantenimientos de las categorias especiales'),
(24, 'mantenimientos.autores', 'Autores', 'Opción para los mantenimientos de los autores de recursos educativos'),
(25, 'mantenimientos.licencias', 'Licencias ', 'Opción para los matenimientos de las licencias'),
(27, 'configuracion.usuarios', 'Gestión de usuario', 'Opción para la administracion de los usuarios'),
(28, 'configuracion.roles', 'Roles y permisos', 'Opción para la administracion de los roles que se le asignaran a los usuarios'),
(30, 'cuestionarios.categoriaCuestionario', 'Categorias Cuestionarios', 'Opción para la administración de las categorias para cuestionario'),
(31, 'cuestionarios.cuestionarios', 'Definir cuestionarios', 'Opción para definir a que ira dirigido el cuestionario creado'),
(32, 'cuestionarios.plantillas', 'Plantilla', 'Opción para asignar una plantilla a una pregunta del cuestionario'),
(33, 'cuestionarios.preguntas', 'Getionar Preguntas', 'Opción para la administracion de las preguntas del cuestionario');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `opcion_rol`
--

DROP TABLE IF EXISTS `opcion_rol`;
CREATE TABLE `opcion_rol` (
  `idOpcion` int(11) NOT NULL,
  `idRol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `opcion_rol`
--

INSERT INTO `opcion_rol` (`idOpcion`, `idRol`) VALUES
(2, 1),
(3, 1),
(5, 1),
(6, 1),
(9, 2),
(10, 1),
(12, 2),
(13, 2),
(14, 2),
(15, 2),
(17, 1),
(18, 1),
(19, 1),
(20, 1),
(21, 1),
(22, 1),
(23, 1),
(24, 1),
(25, 1),
(27, 1),
(28, 1),
(30, 1),
(31, 1),
(32, 1),
(33, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `plantilla`
--

DROP TABLE IF EXISTS `plantilla`;
CREATE TABLE `plantilla` (
  `idPlantilla` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `nombreArchivo` varchar(50) NOT NULL,
  `imagen` varchar(250) NOT NULL,
  `idCategoriaCuestionario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `plantilla`
--

INSERT INTO `plantilla` (`idPlantilla`, `nombre`, `descripcion`, `nombreArchivo`, `imagen`, `idCategoriaCuestionario`) VALUES
(1, 'poo01', 'plantilla de preguntas 4 resp', 'template1.html', '/iconos/74981720a4902089c6b9142c922a23f0/logo-java-BIG.jpg', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `plataforma`
--

DROP TABLE IF EXISTS `plataforma`;
CREATE TABLE `plataforma` (
  `idPlataforma` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `icono` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `plataforma`
--

INSERT INTO `plataforma` (`idPlataforma`, `nombre`, `icono`) VALUES
(1, 'Windows', NULL),
(2, 'Linux', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `plataforma_arquitectura`
--

DROP TABLE IF EXISTS `plataforma_arquitectura`;
CREATE TABLE `plataforma_arquitectura` (
  `idPlataforma` int(11) NOT NULL,
  `idArquitectura` int(11) NOT NULL,
  `idPlataformaArquitectura` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `plataforma_arquitectura`
--

INSERT INTO `plataforma_arquitectura` (`idPlataforma`, `idArquitectura`, `idPlataformaArquitectura`) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 1, 3),
(2, 2, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pregunta`
--

DROP TABLE IF EXISTS `pregunta`;
CREATE TABLE `pregunta` (
  `idPregunta` int(11) NOT NULL,
  `titulo` varchar(50) NOT NULL,
  `pregunta` text NOT NULL,
  `ayuda` text,
  `justificacion` text,
  `idCuestionarioAsignatura` int(11) NOT NULL,
  `idPlantilla` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `pregunta`
--

INSERT INTO `pregunta` (`idPregunta`, `titulo`, `pregunta`, `ayuda`, `justificacion`, `idCuestionarioAsignatura`, `idPlantilla`) VALUES
(2, 'poo001', 'Que es objeto', NULL, NULL, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pregunta_item`
--

DROP TABLE IF EXISTS `pregunta_item`;
CREATE TABLE `pregunta_item` (
  `idPreguntaItem` int(11) NOT NULL,
  `respuesta` text NOT NULL,
  `esBuena` tinyint(1) DEFAULT '0',
  `orden` int(11) DEFAULT '0',
  `idPregunta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `pregunta_item`
--

INSERT INTO `pregunta_item` (`idPreguntaItem`, `respuesta`, `esBuena`, `orden`, `idPregunta`) VALUES
(5, 'instancia de clase', 1, 0, 2),
(6, 'instancia de programa', 0, 0, 2),
(7, 'programa orientado a clases', 0, 0, 2),
(8, 'programa con atribuciones', 0, 0, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pregunta_item_previsualizacion`
--

DROP TABLE IF EXISTS `pregunta_item_previsualizacion`;
CREATE TABLE `pregunta_item_previsualizacion` (
  `idPreguntaItem` int(11) NOT NULL,
  `idPrevisualizacion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pregunta_previsualizacion`
--

DROP TABLE IF EXISTS `pregunta_previsualizacion`;
CREATE TABLE `pregunta_previsualizacion` (
  `idPregunta` int(11) NOT NULL,
  `idPrevisualizacion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `previsualizacion`
--

DROP TABLE IF EXISTS `previsualizacion`;
CREATE TABLE `previsualizacion` (
  `idPrevisualizacion` int(11) NOT NULL,
  `imagen` varchar(250) NOT NULL,
  `idRecurso` int(11) DEFAULT NULL,
  `esVideo` tinyint(4) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `previsualizacion`
--

INSERT INTO `previsualizacion` (`idPrevisualizacion`, `imagen`, `idRecurso`, `esVideo`) VALUES
(10009, '/previsualizaciones/4772ec8e100024723d1bfc29dafd50ec/Koala.jpg', 1409, 0),
(10010, '/previsualizaciones/cf65ae299729d62451ba395fd3396bfa/Tulips.jpg', 1409, 0),
(10011, '/previsualizaciones/29948fcf62d2a19fb710487d96c76b32/Penguins.jpg', 1409, 0),
(10012, '/previsualizaciones/be8b5639ed52543af14054cb1f0b50c3/BigBuckBunny.mp4', 1409, 1),
(10013, '/previsualizaciones/c6b8de210bf17f93bbbed15538399c5a/logo-java-BIG.jpg', NULL, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recurso`
--

DROP TABLE IF EXISTS `recurso`;
CREATE TABLE `recurso` (
  `idRecurso` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `icono` varchar(250) NOT NULL,
  `descripcion` text NOT NULL,
  `docente` tinyint(1) DEFAULT '0',
  `puntuacion` decimal(2,1) DEFAULT '0.0',
  `idCategoria` int(11) DEFAULT NULL,
  `idTipoRecurso` int(11) NOT NULL,
  `guiaDeAplicacion` varchar(250) DEFAULT NULL,
  `guiaDeUsuario` varchar(250) DEFAULT NULL,
  `guiaTecnica` varchar(250) DEFAULT NULL,
  `idModoUso` int(11) NOT NULL,
  `revisado` tinyint(1) DEFAULT '0',
  `descargas` bigint(20) DEFAULT '0',
  `tamano` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `recurso`
--

INSERT INTO `recurso` (`idRecurso`, `nombre`, `icono`, `descripcion`, `docente`, `puntuacion`, `idCategoria`, `idTipoRecurso`, `guiaDeAplicacion`, `guiaDeUsuario`, `guiaTecnica`, `idModoUso`, `revisado`, `descargas`, `tamano`) VALUES
(1409, 'Recurso de muestra', '/iconos/8b974589082d34216fba4665f861b7ba/Jellyfish.jpg', 'Rceurso de muestra', 0, '0.0', 5, 4, NULL, NULL, NULL, 3, 1, 3, 163929513);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recurso_contenido`
--

DROP TABLE IF EXISTS `recurso_contenido`;
CREATE TABLE `recurso_contenido` (
  `idContenido` int(11) NOT NULL,
  `idRecurso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recurso_etiqueta`
--

DROP TABLE IF EXISTS `recurso_etiqueta`;
CREATE TABLE `recurso_etiqueta` (
  `idRecurso` int(11) NOT NULL,
  `idEtiqueta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recurso_indicador_logro`
--

DROP TABLE IF EXISTS `recurso_indicador_logro`;
CREATE TABLE `recurso_indicador_logro` (
  `idIndicadorLogro` int(11) NOT NULL,
  `idRecurso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

DROP TABLE IF EXISTS `rol`;
CREATE TABLE `rol` (
  `idRol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idRol`, `nombre`, `descripcion`) VALUES
(1, 'Administrador', 'Administrador'),
(2, 'Estudiante', 'Estudiante');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_recurso`
--

DROP TABLE IF EXISTS `tipo_recurso`;
CREATE TABLE `tipo_recurso` (
  `idTipoRecurso` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_recurso`
--

INSERT INTO `tipo_recurso` (`idTipoRecurso`, `nombre`, `descripcion`) VALUES
(1, 'Aplicación', 'Programas de computadora'),
(2, 'Libro', 'Libros de texto'),
(3, 'Videojuego', 'Todo tipo de videojuegos'),
(4, 'Imagen', 'Todo tipo de imagenes'),
(5, 'Video', 'Todo tipo de video'),
(6, 'Audio', 'Todo tipo de audio'),
(7, 'Sítio educativo', 'Sítios web de carácter educativo'),
(8, 'Ofimática', 'Archivos y software para el área de ofimática');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad`
--

DROP TABLE IF EXISTS `unidad`;
CREATE TABLE `unidad` (
  `idUnidad` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `abreviatura` varchar(50) NOT NULL,
  `idAsignaturaGrado` int(11) NOT NULL,
  `orden` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `alias` varchar(50) NOT NULL,
  `password` char(128) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `alias`, `password`, `nombre`, `apellido`) VALUES
(3, 'admin', '$2y$08$QGt8lirlRBaa1gAO0tuOUe2Zwy/BxeSJsJ3i/6/ckSU6AQ8WEXBQ2', 'admin', 'admin'),
(7, 'Will', '$2y$08$bv3EjL2Z1597MQNukCnd4u0CR4tb15KRKcUmFz5AcL7rIpqXomTNu', 'William', 'Mejía');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_rol`
--

DROP TABLE IF EXISTS `usuario_rol`;
CREATE TABLE `usuario_rol` (
  `idUsuario` int(11) NOT NULL,
  `idRol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario_rol`
--

INSERT INTO `usuario_rol` (`idUsuario`, `idRol`) VALUES
(3, 1),
(7, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `version`
--

DROP TABLE IF EXISTS `version`;
CREATE TABLE `version` (
  `idVersion` int(11) NOT NULL,
  `numero` int(11) NOT NULL,
  `etiquetaVersion` varchar(50) NOT NULL,
  `fechaCreacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `descripcionCambio` varchar(250) DEFAULT NULL,
  `idRecurso` int(11) NOT NULL,
  `requerimientosHardware` varchar(500) DEFAULT NULL,
  `requerimientosSoftware` varchar(500) DEFAULT NULL,
  `numeroDescargas` int(11) DEFAULT '0',
  `idLicencia` int(11) NOT NULL,
  `activo` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `version`
--

INSERT INTO `version` (`idVersion`, `numero`, `etiquetaVersion`, `fechaCreacion`, `descripcionCambio`, `idRecurso`, `requerimientosHardware`, `requerimientosSoftware`, `numeroDescargas`, `idLicencia`, `activo`) VALUES
(1409, 1, '1', '2017-06-08 18:38:58', 'Primera Versión', 1409, NULL, NULL, 0, 1, 0);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `archivo_fuente`
--
ALTER TABLE `archivo_fuente`
  ADD PRIMARY KEY (`idArchivoFuente`),
  ADD KEY `fk_PlataformaRecurso_Version1_idx` (`idVersion`);

--
-- Indices de la tabla `archivo_fuente_equipo`
--
ALTER TABLE `archivo_fuente_equipo`
  ADD PRIMARY KEY (`idEquipo`,`idArchivoFuente`),
  ADD KEY `fk_Version_has_Equipo_Equipo1_idx` (`idEquipo`),
  ADD KEY `fk_VersionEquipo_PlataformaArquitecturaVersion1_idx` (`idArchivoFuente`);

--
-- Indices de la tabla `archivo_fuente_idioma`
--
ALTER TABLE `archivo_fuente_idioma`
  ADD PRIMARY KEY (`idIdioma`,`idArchivoFuente`),
  ADD KEY `fk_Version_has_Idioma_Idioma1_idx` (`idIdioma`),
  ADD KEY `fk_VersionIdioma_PlataformaArquitecturaVersion1_idx` (`idArchivoFuente`);

--
-- Indices de la tabla `arquitectura`
--
ALTER TABLE `arquitectura`
  ADD PRIMARY KEY (`idArquitectura`);

--
-- Indices de la tabla `asignatura`
--
ALTER TABLE `asignatura`
  ADD PRIMARY KEY (`idAsignatura`);
ALTER TABLE `asignatura` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `asignatura_grado`
--
ALTER TABLE `asignatura_grado`
  ADD PRIMARY KEY (`idAsignaturaGrado`),
  ADD KEY `fk_Grado_has_Asignatura_Asignatura1_idx` (`idAsignatura`),
  ADD KEY `fk_Grado_has_Asignatura_Grado1_idx` (`idGrado`);

--
-- Indices de la tabla `asignatura_grado_contenido`
--
ALTER TABLE `asignatura_grado_contenido`
  ADD PRIMARY KEY (`idAsignaturaGrado`,`idContenido`),
  ADD KEY `fk_asignatura_grado_has_contenido_contenido1_idx` (`idContenido`),
  ADD KEY `fk_asignatura_grado_has_contenido_asignatura_grado1_idx` (`idAsignaturaGrado`);

--
-- Indices de la tabla `asignatura_grado_indicador_logro`
--
ALTER TABLE `asignatura_grado_indicador_logro`
  ADD PRIMARY KEY (`idAsignaturaGrado`,`idIndicadorLogro`),
  ADD KEY `fk_asignatura_grado_has_indicador_logro_indicador_logro1_idx` (`idIndicadorLogro`),
  ADD KEY `fk_asignatura_grado_has_indicador_logro_asignatura_grado1_idx` (`idAsignaturaGrado`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`idAutor`),
  ADD KEY `autor_nombre_index` (`nombre`);
ALTER TABLE `autor` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `autor_recurso`
--
ALTER TABLE `autor_recurso`
  ADD PRIMARY KEY (`idRecurso`,`idAutor`),
  ADD KEY `fk_Recurso_has_Autor_Autor1_idx` (`idAutor`),
  ADD KEY `fk_Recurso_has_Autor_Recurso1_idx` (`idRecurso`);

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`idCategoria`);
ALTER TABLE `categoria` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `categoria_cuestionario`
--
ALTER TABLE `categoria_cuestionario`
  ADD PRIMARY KEY (`idCategoriaCuestionario`);

--
-- Indices de la tabla `chunk`
--
ALTER TABLE `chunk`
  ADD PRIMARY KEY (`idChunk`);

--
-- Indices de la tabla `comentario`
--
ALTER TABLE `comentario`
  ADD PRIMARY KEY (`idComentario`),
  ADD KEY `fk_Comentario_Recurso1_idx` (`idRecurso`);

--
-- Indices de la tabla `compatibilidad_plataforma`
--
ALTER TABLE `compatibilidad_plataforma`
  ADD PRIMARY KEY (`idPlataformaArquitectura`,`idArchivoFuente`),
  ADD KEY `fk_PlataformaArquitectura_has_ArchivoFuente_ArchivoFuente1_idx` (`idArchivoFuente`),
  ADD KEY `fk_PlataformaArquitectura_has_ArchivoFuente_PlataformaArqui_idx` (`idPlataformaArquitectura`);

--
-- Indices de la tabla `contenido`
--
ALTER TABLE `contenido`
  ADD PRIMARY KEY (`idContenido`),
  ADD KEY `fk_Contenido_Unidad1_idx` (`idUnidad`);
ALTER TABLE `contenido` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `contenido_actitudinal`
--
ALTER TABLE `contenido_actitudinal`
  ADD PRIMARY KEY (`idContenidoActitudinal`),
  ADD KEY `fk_contenido_actitudinal_contenido1_idx` (`idContenido`);
ALTER TABLE `contenido_actitudinal` ADD FULLTEXT KEY `nombre` (`nombre`);
ALTER TABLE `contenido_actitudinal` ADD FULLTEXT KEY `abreviatura` (`abreviatura`);

--
-- Indices de la tabla `contenido_procedimental`
--
ALTER TABLE `contenido_procedimental`
  ADD PRIMARY KEY (`idContenidoProcedimental`),
  ADD KEY `fk_contenido_procedimental_contenido1_idx` (`idContenido`);
ALTER TABLE `contenido_procedimental` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `cuestionario`
--
ALTER TABLE `cuestionario`
  ADD PRIMARY KEY (`idCuestionario`),
  ADD KEY `fk_cuestionario_categoria_cuestionario1_idx` (`idCategoriaCuestionario`);

--
-- Indices de la tabla `cuestionario_asignatura`
--
ALTER TABLE `cuestionario_asignatura`
  ADD PRIMARY KEY (`idCuestionarioAsignatura`),
  ADD UNIQUE KEY `index4` (`idAsignatura`,`idCuestionario`),
  ADD KEY `fk_cuestionario_has_asignatura_asignatura1_idx` (`idAsignatura`),
  ADD KEY `fk_cuestionario_has_asignatura_cuestionario1_idx` (`idCuestionario`);

--
-- Indices de la tabla `equipo`
--
ALTER TABLE `equipo`
  ADD PRIMARY KEY (`idEquipo`);

--
-- Indices de la tabla `etiqueta`
--
ALTER TABLE `etiqueta`
  ADD PRIMARY KEY (`idEtiqueta`),
  ADD KEY `etiqueta_nombre_index` (`nombre`);
ALTER TABLE `etiqueta` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `extension`
--
ALTER TABLE `extension`
  ADD PRIMARY KEY (`idExtension`);

--
-- Indices de la tabla `grado`
--
ALTER TABLE `grado`
  ADD PRIMARY KEY (`idGrado`),
  ADD KEY `fk_Grado_Nivel1_idx` (`idNivel`);
ALTER TABLE `grado` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `idioma`
--
ALTER TABLE `idioma`
  ADD PRIMARY KEY (`idIdioma`);
ALTER TABLE `idioma` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `indicador_logro`
--
ALTER TABLE `indicador_logro`
  ADD PRIMARY KEY (`idIndicadorLogro`),
  ADD KEY `fk_indicador_logro_grado_idx` (`idContenido`);
ALTER TABLE `indicador_logro` ADD FULLTEXT KEY `descripcion` (`descripcion`);
ALTER TABLE `indicador_logro` ADD FULLTEXT KEY `abreviatura` (`abreviatura`);

--
-- Indices de la tabla `licencia`
--
ALTER TABLE `licencia`
  ADD PRIMARY KEY (`idLicencia`);

--
-- Indices de la tabla `listas`
--
ALTER TABLE `listas`
  ADD PRIMARY KEY (`idListas`);

--
-- Indices de la tabla `lista_recurso`
--
ALTER TABLE `lista_recurso`
  ADD PRIMARY KEY (`idListas`,`idRecurso`),
  ADD KEY `fk_Listas_has_Recurso_Recurso1_idx` (`idRecurso`),
  ADD KEY `fk_Listas_has_Recurso_Listas1_idx` (`idListas`);

--
-- Indices de la tabla `modo_uso`
--
ALTER TABLE `modo_uso`
  ADD PRIMARY KEY (`idModoUso`),
  ADD UNIQUE KEY `codigo_UNIQUE` (`codigo`);

--
-- Indices de la tabla `modo_uso_extension`
--
ALTER TABLE `modo_uso_extension`
  ADD PRIMARY KEY (`idModoUso`,`idExtension`),
  ADD KEY `fk_ModoUso_has_Extension_Extension1_idx` (`idExtension`),
  ADD KEY `fk_ModoUso_has_Extension_ModoUso1_idx` (`idModoUso`);

--
-- Indices de la tabla `nivel`
--
ALTER TABLE `nivel`
  ADD PRIMARY KEY (`idNivel`);
ALTER TABLE `nivel` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `opcion`
--
ALTER TABLE `opcion`
  ADD PRIMARY KEY (`idOpcion`),
  ADD UNIQUE KEY `codigo_UNIQUE` (`codigo`);

--
-- Indices de la tabla `opcion_rol`
--
ALTER TABLE `opcion_rol`
  ADD PRIMARY KEY (`idOpcion`,`idRol`),
  ADD KEY `fk_opcion_has_rol_rol1_idx` (`idRol`),
  ADD KEY `fk_opcion_has_rol_opcion1_idx` (`idOpcion`);

--
-- Indices de la tabla `plantilla`
--
ALTER TABLE `plantilla`
  ADD PRIMARY KEY (`idPlantilla`),
  ADD KEY `fk_plantilla_categoria_cuestionario1_idx` (`idCategoriaCuestionario`);

--
-- Indices de la tabla `plataforma`
--
ALTER TABLE `plataforma`
  ADD PRIMARY KEY (`idPlataforma`);

--
-- Indices de la tabla `plataforma_arquitectura`
--
ALTER TABLE `plataforma_arquitectura`
  ADD PRIMARY KEY (`idPlataformaArquitectura`),
  ADD KEY `fk_Plataforma_has_Arquitectura_Arquitectura1_idx` (`idArquitectura`),
  ADD KEY `fk_Plataforma_has_Arquitectura_Plataforma1_idx` (`idPlataforma`);

--
-- Indices de la tabla `pregunta`
--
ALTER TABLE `pregunta`
  ADD PRIMARY KEY (`idPregunta`),
  ADD KEY `fk_pregunta_cuestionario_asignatura1_idx` (`idCuestionarioAsignatura`),
  ADD KEY `fk_pregunta_plantilla1_idx` (`idPlantilla`);

--
-- Indices de la tabla `pregunta_item`
--
ALTER TABLE `pregunta_item`
  ADD PRIMARY KEY (`idPreguntaItem`),
  ADD KEY `fk_pregunta_item_pregunta1_idx` (`idPregunta`);

--
-- Indices de la tabla `pregunta_item_previsualizacion`
--
ALTER TABLE `pregunta_item_previsualizacion`
  ADD PRIMARY KEY (`idPreguntaItem`,`idPrevisualizacion`),
  ADD KEY `fk_pregunta_item_has_previsualizacion_previsualizacion1_idx` (`idPrevisualizacion`),
  ADD KEY `fk_pregunta_item_has_previsualizacion_pregunta_item1_idx` (`idPreguntaItem`);

--
-- Indices de la tabla `pregunta_previsualizacion`
--
ALTER TABLE `pregunta_previsualizacion`
  ADD PRIMARY KEY (`idPregunta`,`idPrevisualizacion`),
  ADD KEY `fk_pregunta_has_previsualizacion_previsualizacion1_idx` (`idPrevisualizacion`),
  ADD KEY `fk_pregunta_has_previsualizacion_pregunta1_idx` (`idPregunta`);

--
-- Indices de la tabla `previsualizacion`
--
ALTER TABLE `previsualizacion`
  ADD PRIMARY KEY (`idPrevisualizacion`),
  ADD KEY `fk_Previsualizacion_Recurso_idx` (`idRecurso`);

--
-- Indices de la tabla `recurso`
--
ALTER TABLE `recurso`
  ADD PRIMARY KEY (`idRecurso`),
  ADD KEY `fk_Recurso_Categoria1_idx` (`idCategoria`),
  ADD KEY `fk_Recurso_TipoRecurso1_idx` (`idTipoRecurso`),
  ADD KEY `fk_Recurso_FormatoArchivo1_idx` (`idModoUso`),
  ADD KEY `recurso_nombre_index` (`nombre`);
ALTER TABLE `recurso` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `recurso_contenido`
--
ALTER TABLE `recurso_contenido`
  ADD PRIMARY KEY (`idContenido`,`idRecurso`),
  ADD KEY `fk_Contenido_has_Recurso_Recurso1_idx` (`idRecurso`),
  ADD KEY `fk_Contenido_has_Recurso_Contenido1_idx` (`idContenido`);

--
-- Indices de la tabla `recurso_etiqueta`
--
ALTER TABLE `recurso_etiqueta`
  ADD PRIMARY KEY (`idRecurso`,`idEtiqueta`),
  ADD KEY `fk_Recurso_has_Etiquetas_Etiquetas1_idx` (`idEtiqueta`),
  ADD KEY `fk_Recurso_has_Etiquetas_Recurso1_idx` (`idRecurso`);

--
-- Indices de la tabla `recurso_indicador_logro`
--
ALTER TABLE `recurso_indicador_logro`
  ADD PRIMARY KEY (`idIndicadorLogro`,`idRecurso`),
  ADD KEY `fk_indicador_logro_has_recurso_recurso1_idx` (`idRecurso`),
  ADD KEY `fk_indicador_logro_has_recurso_indicador_logro1_idx` (`idIndicadorLogro`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idRol`);

--
-- Indices de la tabla `tipo_recurso`
--
ALTER TABLE `tipo_recurso`
  ADD PRIMARY KEY (`idTipoRecurso`);

--
-- Indices de la tabla `unidad`
--
ALTER TABLE `unidad`
  ADD PRIMARY KEY (`idUnidad`),
  ADD KEY `fk_Unidad_AsignaturaGrado1_idx` (`idAsignaturaGrado`);
ALTER TABLE `unidad` ADD FULLTEXT KEY `nombre` (`nombre`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD UNIQUE KEY `alias_UNIQUE` (`alias`);

--
-- Indices de la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD PRIMARY KEY (`idUsuario`,`idRol`),
  ADD KEY `fk_usuario_has_rol_rol1_idx` (`idRol`),
  ADD KEY `fk_usuario_has_rol_usuario1_idx` (`idUsuario`);

--
-- Indices de la tabla `version`
--
ALTER TABLE `version`
  ADD PRIMARY KEY (`idVersion`),
  ADD KEY `fk_Version_Recurso1_idx` (`idRecurso`),
  ADD KEY `fk_Version_Licencia1_idx` (`idLicencia`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `archivo_fuente`
--
ALTER TABLE `archivo_fuente`
  MODIFY `idArchivoFuente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1424;
--
-- AUTO_INCREMENT de la tabla `arquitectura`
--
ALTER TABLE `arquitectura`
  MODIFY `idArquitectura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `asignatura`
--
ALTER TABLE `asignatura`
  MODIFY `idAsignatura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `asignatura_grado`
--
ALTER TABLE `asignatura_grado`
  MODIFY `idAsignaturaGrado` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `autor`
--
ALTER TABLE `autor`
  MODIFY `idAutor` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `idCategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT de la tabla `categoria_cuestionario`
--
ALTER TABLE `categoria_cuestionario`
  MODIFY `idCategoriaCuestionario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `chunk`
--
ALTER TABLE `chunk`
  MODIFY `idChunk` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `comentario`
--
ALTER TABLE `comentario`
  MODIFY `idComentario` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `contenido`
--
ALTER TABLE `contenido`
  MODIFY `idContenido` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `contenido_actitudinal`
--
ALTER TABLE `contenido_actitudinal`
  MODIFY `idContenidoActitudinal` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `contenido_procedimental`
--
ALTER TABLE `contenido_procedimental`
  MODIFY `idContenidoProcedimental` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `cuestionario`
--
ALTER TABLE `cuestionario`
  MODIFY `idCuestionario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `cuestionario_asignatura`
--
ALTER TABLE `cuestionario_asignatura`
  MODIFY `idCuestionarioAsignatura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `equipo`
--
ALTER TABLE `equipo`
  MODIFY `idEquipo` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `etiqueta`
--
ALTER TABLE `etiqueta`
  MODIFY `idEtiqueta` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `extension`
--
ALTER TABLE `extension`
  MODIFY `idExtension` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `grado`
--
ALTER TABLE `grado`
  MODIFY `idGrado` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `idioma`
--
ALTER TABLE `idioma`
  MODIFY `idIdioma` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `indicador_logro`
--
ALTER TABLE `indicador_logro`
  MODIFY `idIndicadorLogro` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `licencia`
--
ALTER TABLE `licencia`
  MODIFY `idLicencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT de la tabla `listas`
--
ALTER TABLE `listas`
  MODIFY `idListas` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `modo_uso`
--
ALTER TABLE `modo_uso`
  MODIFY `idModoUso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT de la tabla `nivel`
--
ALTER TABLE `nivel`
  MODIFY `idNivel` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `opcion`
--
ALTER TABLE `opcion`
  MODIFY `idOpcion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;
--
-- AUTO_INCREMENT de la tabla `plantilla`
--
ALTER TABLE `plantilla`
  MODIFY `idPlantilla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `plataforma`
--
ALTER TABLE `plataforma`
  MODIFY `idPlataforma` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `pregunta`
--
ALTER TABLE `pregunta`
  MODIFY `idPregunta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `pregunta_item`
--
ALTER TABLE `pregunta_item`
  MODIFY `idPreguntaItem` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT de la tabla `previsualizacion`
--
ALTER TABLE `previsualizacion`
  MODIFY `idPrevisualizacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10014;
--
-- AUTO_INCREMENT de la tabla `recurso`
--
ALTER TABLE `recurso`
  MODIFY `idRecurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1410;
--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `idRol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `tipo_recurso`
--
ALTER TABLE `tipo_recurso`
  MODIFY `idTipoRecurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT de la tabla `unidad`
--
ALTER TABLE `unidad`
  MODIFY `idUnidad` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT de la tabla `version`
--
ALTER TABLE `version`
  MODIFY `idVersion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1410;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `archivo_fuente`
--
ALTER TABLE `archivo_fuente`
  ADD CONSTRAINT `fk_PlataformaRecurso_Version1` FOREIGN KEY (`idVersion`) REFERENCES `version` (`idVersion`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Filtros para la tabla `archivo_fuente_equipo`
--
ALTER TABLE `archivo_fuente_equipo`
  ADD CONSTRAINT `fk_archivoFuente_Fuente` FOREIGN KEY (`idArchivoFuente`) REFERENCES `archivo_fuente` (`idArchivoFuente`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_archivofuente_Equipo` FOREIGN KEY (`idEquipo`) REFERENCES `equipo` (`idEquipo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `archivo_fuente_idioma`
--
ALTER TABLE `archivo_fuente_idioma`
  ADD CONSTRAINT `fk_Version_has_Idioma_ArchivoFuente` FOREIGN KEY (`idArchivoFuente`) REFERENCES `archivo_fuente` (`idArchivoFuente`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Version_has_Idioma_Idioma1` FOREIGN KEY (`idIdioma`) REFERENCES `idioma` (`idIdioma`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `asignatura_grado`
--
ALTER TABLE `asignatura_grado`
  ADD CONSTRAINT `fk_Grado_has_Asignatura_Asignatura1` FOREIGN KEY (`idAsignatura`) REFERENCES `asignatura` (`idAsignatura`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Grado_has_Asignatura_Grado1` FOREIGN KEY (`idGrado`) REFERENCES `grado` (`idGrado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `asignatura_grado_contenido`
--
ALTER TABLE `asignatura_grado_contenido`
  ADD CONSTRAINT `fk_asignatura_grado_has_contenido_asignatura_grado1` FOREIGN KEY (`idAsignaturaGrado`) REFERENCES `asignatura_grado` (`idAsignaturaGrado`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_asignatura_grado_has_contenido_contenido1` FOREIGN KEY (`idContenido`) REFERENCES `contenido` (`idContenido`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `asignatura_grado_indicador_logro`
--
ALTER TABLE `asignatura_grado_indicador_logro`
  ADD CONSTRAINT `fk_asignatura_grado_has_indicador_logro_asignatura_grado1` FOREIGN KEY (`idAsignaturaGrado`) REFERENCES `asignatura_grado` (`idAsignaturaGrado`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_asignatura_grado_has_indicador_logro_indicador_logro1` FOREIGN KEY (`idIndicadorLogro`) REFERENCES `indicador_logro` (`idIndicadorLogro`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `autor_recurso`
--
ALTER TABLE `autor_recurso`
  ADD CONSTRAINT `fk_Recurso_has_Autor_Autor1` FOREIGN KEY (`idAutor`) REFERENCES `autor` (`idAutor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Recurso_has_Autor_Recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comentario`
--
ALTER TABLE `comentario`
  ADD CONSTRAINT `fk_Comentario_Recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Filtros para la tabla `compatibilidad_plataforma`
--
ALTER TABLE `compatibilidad_plataforma`
  ADD CONSTRAINT `fk_PlataformaArquitectura_has_ArchivoFuente_ArchivoFuente1` FOREIGN KEY (`idArchivoFuente`) REFERENCES `archivo_fuente` (`idArchivoFuente`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_PlataformaArquitectura_has_ArchivoFuente_PlataformaArquite1` FOREIGN KEY (`idPlataformaArquitectura`) REFERENCES `plataforma_arquitectura` (`idPlataformaArquitectura`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `contenido`
--
ALTER TABLE `contenido`
  ADD CONSTRAINT `fk_Contenido_Unidad1` FOREIGN KEY (`idUnidad`) REFERENCES `unidad` (`idUnidad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `contenido_actitudinal`
--
ALTER TABLE `contenido_actitudinal`
  ADD CONSTRAINT `fk_contenido_actitudinal_contenido1` FOREIGN KEY (`idContenido`) REFERENCES `contenido` (`idContenido`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `contenido_procedimental`
--
ALTER TABLE `contenido_procedimental`
  ADD CONSTRAINT `fk_contenido_procedimental_contenido1` FOREIGN KEY (`idContenido`) REFERENCES `contenido` (`idContenido`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `cuestionario`
--
ALTER TABLE `cuestionario`
  ADD CONSTRAINT `fk_cuestionario_categoria_cuestionario1` FOREIGN KEY (`idCategoriaCuestionario`) REFERENCES `categoria_cuestionario` (`idCategoriaCuestionario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `cuestionario_asignatura`
--
ALTER TABLE `cuestionario_asignatura`
  ADD CONSTRAINT `fk_cuestionario_has_asignatura_asignatura1` FOREIGN KEY (`idAsignatura`) REFERENCES `asignatura` (`idAsignatura`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_cuestionario_has_asignatura_cuestionario1` FOREIGN KEY (`idCuestionario`) REFERENCES `cuestionario` (`idCuestionario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `grado`
--
ALTER TABLE `grado`
  ADD CONSTRAINT `fk_Grado_Nivel1` FOREIGN KEY (`idNivel`) REFERENCES `nivel` (`idNivel`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `indicador_logro`
--
ALTER TABLE `indicador_logro`
  ADD CONSTRAINT `fk_indicador_logro_grado` FOREIGN KEY (`idContenido`) REFERENCES `contenido` (`idContenido`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `lista_recurso`
--
ALTER TABLE `lista_recurso`
  ADD CONSTRAINT `fk_Listas_has_Recurso_Recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_lista_recurso_lista` FOREIGN KEY (`idListas`) REFERENCES `listas` (`idListas`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Filtros para la tabla `modo_uso_extension`
--
ALTER TABLE `modo_uso_extension`
  ADD CONSTRAINT `fk_ModoUso_has_Extension` FOREIGN KEY (`idExtension`) REFERENCES `extension` (`idExtension`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_ModoUso_has_Extension_ModoUso1` FOREIGN KEY (`idModoUso`) REFERENCES `modo_uso` (`idModoUso`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `opcion_rol`
--
ALTER TABLE `opcion_rol`
  ADD CONSTRAINT `fk_opcion_has_rol_opcion1` FOREIGN KEY (`idOpcion`) REFERENCES `opcion` (`idOpcion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_opcion_has_rol_rol1` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `plantilla`
--
ALTER TABLE `plantilla`
  ADD CONSTRAINT `fk_plantilla_categoria_cuestionario1` FOREIGN KEY (`idCategoriaCuestionario`) REFERENCES `categoria_cuestionario` (`idCategoriaCuestionario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `plataforma_arquitectura`
--
ALTER TABLE `plataforma_arquitectura`
  ADD CONSTRAINT `fk_Plataforma_has_Arquitectura_Arquitectura1` FOREIGN KEY (`idArquitectura`) REFERENCES `arquitectura` (`idArquitectura`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Plataforma_has_Arquitectura_Plataforma1` FOREIGN KEY (`idPlataforma`) REFERENCES `plataforma` (`idPlataforma`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pregunta`
--
ALTER TABLE `pregunta`
  ADD CONSTRAINT `fk_pregunta_cuestionario_asignatura1` FOREIGN KEY (`idCuestionarioAsignatura`) REFERENCES `cuestionario_asignatura` (`idCuestionarioAsignatura`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pregunta_plantilla1` FOREIGN KEY (`idPlantilla`) REFERENCES `plantilla` (`idPlantilla`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pregunta_item`
--
ALTER TABLE `pregunta_item`
  ADD CONSTRAINT `fk_pregunta_item_pregunta1` FOREIGN KEY (`idPregunta`) REFERENCES `pregunta` (`idPregunta`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `pregunta_item_previsualizacion`
--
ALTER TABLE `pregunta_item_previsualizacion`
  ADD CONSTRAINT `fk_pregunta_item_has_previsualizacion_pregunta_item1` FOREIGN KEY (`idPreguntaItem`) REFERENCES `pregunta_item` (`idPreguntaItem`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pregunta_item_has_previsualizacion_previsualizacion1` FOREIGN KEY (`idPrevisualizacion`) REFERENCES `previsualizacion` (`idPrevisualizacion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `pregunta_previsualizacion`
--
ALTER TABLE `pregunta_previsualizacion`
  ADD CONSTRAINT `fk_pregunta_has_previsualizacion_pregunta1` FOREIGN KEY (`idPregunta`) REFERENCES `pregunta` (`idPregunta`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pregunta_has_previsualizacion_previsualizacion1` FOREIGN KEY (`idPrevisualizacion`) REFERENCES `previsualizacion` (`idPrevisualizacion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `previsualizacion`
--
ALTER TABLE `previsualizacion`
  ADD CONSTRAINT `fk_Previsualizacion_Recurso` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Filtros para la tabla `recurso`
--
ALTER TABLE `recurso`
  ADD CONSTRAINT `fk_Recurso_Categoria1` FOREIGN KEY (`idCategoria`) REFERENCES `categoria` (`idCategoria`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Recurso_ModoUso` FOREIGN KEY (`idModoUso`) REFERENCES `modo_uso` (`idModoUso`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Recurso_TipoRecurso1` FOREIGN KEY (`idTipoRecurso`) REFERENCES `tipo_recurso` (`idTipoRecurso`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `recurso_contenido`
--
ALTER TABLE `recurso_contenido`
  ADD CONSTRAINT `fk_Contenido_has_Recurso_Contenido1` FOREIGN KEY (`idContenido`) REFERENCES `contenido` (`idContenido`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_Contenido_has_Recurso_Recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `recurso_etiqueta`
--
ALTER TABLE `recurso_etiqueta`
  ADD CONSTRAINT `fk_Recurso_has_Etiquetas_Recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Recurso_has_Etiquetas_Recurso2` FOREIGN KEY (`idEtiqueta`) REFERENCES `etiqueta` (`idEtiqueta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `recurso_indicador_logro`
--
ALTER TABLE `recurso_indicador_logro`
  ADD CONSTRAINT `fk_indicador_logro_has_recurso_indicador_logro1` FOREIGN KEY (`idIndicadorLogro`) REFERENCES `indicador_logro` (`idIndicadorLogro`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_indicador_logro_has_recurso_recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `unidad`
--
ALTER TABLE `unidad`
  ADD CONSTRAINT `fk_unidad_asinaturagrado` FOREIGN KEY (`idAsignaturaGrado`) REFERENCES `asignatura_grado` (`idAsignaturaGrado`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD CONSTRAINT `fk_usuario_has_rol_rol1` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_usuario_has_rol_usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `version`
--
ALTER TABLE `version`
  ADD CONSTRAINT `fk_Version_Licencia1` FOREIGN KEY (`idLicencia`) REFERENCES `licencia` (`idLicencia`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Version_Recurso1` FOREIGN KEY (`idRecurso`) REFERENCES `recurso` (`idRecurso`) ON DELETE CASCADE ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
