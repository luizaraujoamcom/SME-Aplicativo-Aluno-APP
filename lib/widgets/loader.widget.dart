import 'package:flutter/widgets.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/size/gf_size.dart';
import 'package:getflutter/types/gf_loader_type.dart';
import 'package:sme_app_aluno/themes/app.theme.dart';

class EALoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GFLoader(
      type: GFLoaderType.square,
      loaderColorOne: corAmarelo,
      loaderColorTwo: corLaranja,
      loaderColorThree: corLaranja,
      size: GFSize.LARGE,
    );
  }
}
