# Test Cases

# options.TYPe.type = {_type }

# options.ATTrsOf.attrsOf =   { type } | { listOf } | { attrsOf } | { options }
# options.LiSTOf.listOf   =   { type } | { listOf } | { attrsOf } | { options }
# options.OPTions.options = { OPTions =
#                             { type } | { listOf } | { attrsOf } | { options } }

# options.ATTrsOf -> ATTrsOf -> TYPe
# options.ATTrsOf -> LIStOf  -> TYPe
# options.ATTrsOf -> OPTions -> TYPe

# options.LIStOf  -> ATTrsOf -> TYPe
# options.LIStOf  -> LIStOf  -> TYPe
# options.LIStOf  -> OPTions -> TYPe

# options.OPTions -> ATTrsOf -> TYPe
# options.OPTions -> LIStOf  -> TYPe
# options.OPTions -> OPTions -> TYPe

# nix eval --show-trace --impure --expr '(import ./fluent.nix { lib = (import <nixpkgs> {}).lib; })'|sed 's/.repeated./<repeated>/g'|nix run nixpkgs#alejandra
# alejandra isn't required but provide some nice output


{ lib, ... }:
lib.types.fluent {
  # Basic cases

  options.ATT.attrsOf     = lib.types.str;
  options.ATT.default     = { test = "ATT"; };
  options.ATT.description = "attrset of strings";
  options.ATT.example     = {};

  options.ENM.default     = "ENM";
  options.ENM.description = "enum option example";
  options.ENM.example     = "MNE";
  options.ENM.enum        = [ "NME" "ENM" ];

  options.LST.default     = [ "LST" ];
  options.LST.description = "list of string";
  options.LST.example     = [];
  options.LST.listOf      = lib.types.str;

  options.ONE.default     = "ONE";
  options.ONE.description = "oneOf option example";
  options.ONE.example     = "some string";
  options.ONE.oneOf       = [ lib.types.str lib.types.int ];

  options.TYP.default     = "TYP";
  options.TYP.description = "string option example";
  options.TYP.example     = "some string";
  options.TYP.type        = lib.types.str;

  # Nested attrs

  options.ATT-ATT.default      = {};
  options.ATT-ATT.description  = "attrset of attrset";
  options.ATT-ATT.example      = {};

  options.ATT-ENM.default      = {};
  options.ATT-ENM.description  = "attrset of enums";
  options.ATT-ENM.example      = {};

  options.ATT-LST.default      = {};
  options.ATT-LST.description  = "attrset of lists";
  options.ATT-LST.example      = {};

  options.ATT-ONE.default      = {};
  options.ATT-ONE.description  = "attrset of one of";
  options.ATT-ONE.example      = {};

  options.ATT-ATT.attrsOf.default      = {};
  options.ATT-ATT.attrsOf.description  = "attrset of strings";
  options.ATT-ATT.attrsOf.example      = {};
  options.ATT-ATT.attrsOf.attrsOf      = lib.types.str;

  options.ATT-ENM.attrsOf.default      = "ATT-ENM";
  options.ATT-ENM.attrsOf.description  = "attrset of strings";
  options.ATT-ENM.attrsOf.example      = "ATT-MNE";
  options.ATT-ENM.attrsOf.enum         = ["ATT-MNE" "ATT-ENM"];

  options.ATT-LST.attrsOf.default      = {};
  options.ATT-LST.attrsOf.description  = "list of strings";
  options.ATT-LST.attrsOf.example      = {};
  options.ATT-LST.attrsOf.listOf       = lib.types.str;

  options.ATT-ONE.attrsOf.default      = "ATT-ONE";
  options.ATT-ONE.attrsOf.description  = "attrset of oneof";
  options.ATT-ONE.attrsOf.example      = 1;
  options.ATT-ONE.attrsOf.oneOf        = [ lib.types.str lib.types.int ];

  options.ATT-OPT.attrsOf.default      = {};
  options.ATT-OPT.attrsOf.description  = "options with one attr";
  options.ATT-OPT.attrsOf.example      = {};

  options.ATT-OPT.attrsOf.options.ATT-OPT-TYP.default     = "";
  options.ATT-OPT.attrsOf.options.ATT-OPT-TYP.description = "option of options of attrset";
  options.ATT-OPT.attrsOf.options.ATT-OPT-TYP.type        = lib.types.str;
  options.ATT-OPT.attrsOf.options.ATT-OPT-TYP.example     = "";

  # Nested lists

  options.LST-ATT.default       = [];
  options.LST-ATT.description   = "list of attrset";
  options.LST-ATT.example       = [];

  options.LST-ENM.default       = [];
  options.LST-ENM.description   = "list of enum";
  options.LST-ENM.example       = [];

  options.LST-LST.default       = {};
  options.LST-LST.description   = "list of lists";
  options.LST-LST.example       = {};

  options.LST-ONE.default       = [];
  options.LST-ONE.description   = "list of one of";
  options.LST-ONE.example       = [];

  options.LST-OPT.default       = {};
  options.LST-OPT.description   = "list of options";
  options.LST-OPT.example       = {};

  options.LST-ATT.listOf.default     = [];
  options.LST-ATT.listOf.description = "attrset of strings";
  options.LST-ATT.listOf.example     = [];
  options.LST-ATT.listOf.attrsOf     = lib.types.str;

  options.LST-ENM.listOf.default     = [ "LST-ENM" "LST-MNE" ];
  options.LST-ENM.listOf.description = "list of enum";
  options.LST-ENM.listOf.example     = [ "LST-MNE" "LST-ENM" ];
  options.LST-ENM.listOf.enum        = [ "LST-MNE" "LST-ENM" ];

  options.LST-LST.listOf.default     = [];
  options.LST-LST.listOf.description = "list of strings";
  options.LST-LST.listOf.example     = [];
  options.LST-LST.listOf.listOf      = lib.types.str;

  options.LST-ONE.listOf.default     = [ "LST-ONE" 1 ];
  options.LST-ONE.listOf.description = "list of one of";
  options.LST-ONE.listOf.example     = [ 1 "LST-ONE" ];
  options.LST-ONE.listOf.oneOf       = [ lib.types.str lib.types.int ];

  options.LST-OPT.listOf.default     = [];
  options.LST-OPT.listOf.description = "options with one attr";
  options.LST-OPT.listOf.example     = [];

  options.LST-OPT.listOf.options.LST-OPT-TYP.default     = "";
  options.LST-OPT.listOf.options.LST-OPT-TYP.description = "option of options of lists";
  options.LST-OPT.listOf.options.LST-OPT-TYP.type        = lib.types.str;
  options.LST-OPT.listOf.options.LST-OPT-TYP.example     = "";

  # Nested options

  options.OPT.default     = {};
  options.OPT.example     = {};
  options.OPT.description = "options holder";

  options.OPT.options.OPT-ATT.default     = { test = "OPT-ATT"; };
  options.OPT.options.OPT-ATT.description = "second level attrset of strings";
  options.OPT.options.OPT-ATT.attrsOf     = lib.types.str;
  options.OPT.options.OPT-ATT.example     = {};

  options.OPT.options.OPT-ENM.default     = "OPT-ENM";
  options.OPT.options.OPT-ENM.description = "second level enum";
  options.OPT.options.OPT-ENM.enum        = [ "OTP-MNE" "OPT-ENM" ];
  options.OPT.options.OPT-ENM.example     = "OPT-MNE";

  options.OPT.options.OPT-LST.default     = [ "OPT-LST" ];
  options.OPT.options.OPT-LST.description = "second level list of strings";
  options.OPT.options.OPT-LST.listOf      = lib.types.str;
  options.OPT.options.OPT-LST.example     = [];

  options.OPT.options.OPT-ONE.default     = "OPT-ONE";
  options.OPT.options.OPT-ONE.description = "second level one of";
  options.OPT.options.OPT-ONE.oneOf       = [ lib.types.str lib.types.int ];
  options.OPT.options.OPT-ONE.example     = 1;

  options.OPT.options.OPT-OPT.default     = {};
  options.OPT.options.OPT-OPT.example     = {};
  options.OPT.options.OPT-OPT.description = "second level options holder";

  options.OPT.options.OPT-TYP.default     = "OPT-TYP";
  options.OPT.options.OPT-TYP.description = "second level str";
  options.OPT.options.OPT-TYP.type        = lib.types.str;
  options.OPT.options.OPT-TYP.example     = "some string";

  options.OPT.options.OPT-OPT.options.OPT-OPT-ATT.default     =  { test = "OPT-OPT-ATT"; };
  options.OPT.options.OPT-OPT.options.OPT-OPT-ATT.description = "Third level hasmap of strings str";
  options.OPT.options.OPT-OPT.options.OPT-OPT-ATT.attrsOf     = lib.types.str;
  options.OPT.options.OPT-OPT.options.OPT-OPT-ATT.example     = {};

  options.OPT.options.OPT-OPT.options.OPT-OPT-ENM.default     = "OPT-OPT-ENM";
  options.OPT.options.OPT-OPT.options.OPT-OPT-ENM.description = "third level str";
  options.OPT.options.OPT-OPT.options.OPT-OPT-ENM.enum        = [ "OPT-OPT-MNE" "OPT-OPT-ENM" ];
  options.OPT.options.OPT-OPT.options.OPT-OPT-ENM.example     = "OPT-OPT-MNE";

  options.OPT.options.OPT-OPT.options.OPT-OPT-LST.default     = [ "OPT-OPT-LST" ];
  options.OPT.options.OPT-OPT.options.OPT-OPT-LST.description = "Third level list of strings str";
  options.OPT.options.OPT-OPT.options.OPT-OPT-LST.listOf      = lib.types.str;
  options.OPT.options.OPT-OPT.options.OPT-OPT-LST.example     = [];

  options.OPT.options.OPT-OPT.options.OPT-OPT-ONE.default     = "OPT-OPT-ONE";
  options.OPT.options.OPT-OPT.options.OPT-OPT-ONE.description = "third level one of";
  options.OPT.options.OPT-OPT.options.OPT-OPT-ONE.oneOf       = [ lib.types.str lib.types.int ];
  options.OPT.options.OPT-OPT.options.OPT-OPT-ONE.example     = 1;

  options.OPT.options.OPT-OPT.options.OPT-OPT-TYP.default     = "OPT-OPT-TYP";
  options.OPT.options.OPT-OPT.options.OPT-OPT-TYP.description = "third level str";
  options.OPT.options.OPT-OPT.options.OPT-OPT-TYP.type        = lib.types.str;
  options.OPT.options.OPT-OPT.options.OPT-OPT-TYP.example     = "some string";

  # Inter Type
  options.TYP-ATT.default     =  {};
  options.TYP-ATT.description = "attr option";

  options.TYP-BOO.default     = true;
  options.TYP-BOO.description = "bool option";

  options.TYP-FLT.default     =  0.0;
  options.TYP-FLT.description = "float option";

  options.TYP-INT.default     =  0;
  options.TYP-INT.description = "int option";

  options.TYP-LST.default     =  [ "TYP-LST" ];
  options.TYP-LST.description = "list option";

  options.TYP-NUL.default     =  null;
  options.TYP-NUL.description = "null option";

  options.TYP-PKG.default     =  (import <nixpkgs> {}).emptyFile;
  options.TYP-PKG.description = "pkg option";

  options.TYP-PTH.default     =  ./.;
  options.TYP-PTH.description = "path option";

  options.TYP-STR.default     = "TYP-STR";
  options.TYP-STR.description = "string option";

  # mdDocs
  options.TYP-DOC.default     = "TYP-DOC";
  options.TYP-DOC.mdDoc       = "MD doc";
}
