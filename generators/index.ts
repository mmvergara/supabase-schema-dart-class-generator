import { generateDartClasses } from "./Class";
import { generateClientExtension } from "./ClientExtension";
import { generateModels } from "./Models";
import { SupadartAbstractClass } from "./SupadartAbstractClass";
import { getImports } from "./imports";
import { ClientExtension, DartClass, Definitions } from "./types";
import { generateDartFileName } from "./utils";

export const generateBluePrint = (
  definitions: Definitions,
  isFlutter: boolean
) => {
  const dartClasses: DartClass[] = generateDartClasses(definitions);
  const imports = getImports(dartClasses, isFlutter);
  const clientExtension: ClientExtension = generateClientExtension(definitions);
  const models = generateModels(definitions);

  return {
    imports,
    dartClasses,
    clientExtension,
    SupadartAbstractClass,
    models,
  };
};

export const generateClassesSingleFile = (
  definitions: Definitions,
  isFlutter: boolean
) => {
  const { clientExtension, dartClasses, imports, SupadartAbstractClass } =
    generateBluePrint(definitions, isFlutter);

  let code = "";
  imports.forEach((i) => (code += i + "\n"));
  code += clientExtension + "\n\n";
  code += SupadartAbstractClass + "\n\n";
  code += dartClasses.map((c) => c.classCode).join("\n");

  return code;
};

export const generateDartModelFilesSeparated = (
  definitions: Definitions,
  isFlutter: boolean
): Record<string, string> => {
  const { clientExtension, dartClasses, SupadartAbstractClass, models } =
    generateBluePrint(definitions, isFlutter);

  // Per key is a class file and the value is the code
  const output: Record<string, string> = {};

  dartClasses.forEach(({ classCode, className }) => {
    // this is per class file generation
    let code = "";

    const imports = getImports([{ classCode, className }], isFlutter);
    // remove 2nd line of import (Supabase SDK Import)
    imports.splice(1, 1, "import 'supadart_abstract_class.dart';");

    code += imports.join("\n") + "\n\n";
    code += "\n";
    code += classCode;

    output[generateDartFileName(className)] = code;
  });

  // Generated client extension
  const supabaseSdkImport = isFlutter
    ? "import 'package:supabase_flutter/supabase_flutter.dart';"
    : "import 'package:supabase/supabase.dart';";

  output["client_extension"] =
    "// ignore_for_file: non_constant_identifier_names, camel_case_types, file_namesimport, file_names" +
    "\n" +
    supabaseSdkImport +
    "\n" +
    clientExtension;

  // Generated abstract class
  output["supadart_abstract_class"] = SupadartAbstractClass;

  // Generated models file
  output["models"] = models;
  return output;
};
