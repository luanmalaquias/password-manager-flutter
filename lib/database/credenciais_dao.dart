import 'package:gerar_senha/database/conexao_dao.dart';
import 'package:gerar_senha/model/credenciais.dart';

class CredenciaisDAO {
  static String tabelaCredenciais = "credenciais";

  static Future<void> insert(Credenciais c) async {
    final db = await getDataBase();
    await db.insert(
        tabelaCredenciais,
        c.toMap(),
    );
  }

  static Future<String?> getSenhaPrincipal() async {
    final db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query(tabelaCredenciais);
    List<Credenciais> lista = List.generate(maps.length, (i) {
      return Credenciais(
        id: maps[i]['id'],
        site: maps[i]['site'],
        senha: maps[i]['senha'],
      );
    });
    if (lista.isNotEmpty) {
      return lista[0].senha;
    } else {
      return "None";
    }
  }

  static Future<List<Credenciais>> select() async {
    final db = await getDataBase();
    final List<Map<String, dynamic>> maps = await db.query(tabelaCredenciais);
    return List.generate(maps.length, (i) {
      return Credenciais(
        id: maps[i]['id'],
        site: maps[i]['site'],
        senha: maps[i]['senha'],
      );
    });
  }

  static Future<void> update(Credenciais c) async {
    final db = await getDataBase();
    await db.update(
      tabelaCredenciais,
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  static Future<void> delete(int? id) async {
    final db = await getDataBase();
    await db.delete(
      'credenciais',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAll() async {
    final db = await getDataBase();
    await db.delete(tabelaCredenciais);
  }
}
