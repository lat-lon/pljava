\echo Use "CREATE EXTENSION pljava FROM UNPACKAGED" to load this file. \quit

/*
 This script can "update" from any unpackaged PL/Java version supported by
 the automigration code within PL/Java itself. The schema migration is first
 touched off by the LOAD command, and then the ALTER EXTENSION commands gather
 up the member objects according to the current schema version.
 */

DROP TABLE IF EXISTS @extschema@.loadpath;
CREATE TABLE @extschema@.loadpath(s) AS SELECT CAST('MODULE_PATHNAME' AS text);
LOAD 'MODULE_PATHNAME';
DROP TABLE @extschema@.loadpath;

/*
 Why the DROP / ADD?  When faced with a LOAD command, PostgreSQL only does it
 if the library has not been loaded already in the session (as could have
 happened if, for example, a PL/Java function has already been called). If the
 LOAD was skipped, there could still be an old-layout schema, because the
 migration only happens in an actual LOAD.  To avoid confusion later, it's
 helpful to fail fast in that case. DROPping the call handlers accomplishes
 that, because the LOAD action always CREATE-OR-REPLACEs them (to be sure they
 refer to the latest native library), which means they will already be gathered
 into the extension, provided the LOAD actions actually ran. If not, the DROPs
 will fail.
 
 The error messages will not shed much light on the real problem, but at least
 will indicate that there is a problem. The solution is simply to exit the
 session and repeat the CREATE EXTENSION in a new session where PL/Java has not
 been loaded yet.
 */

ALTER EXTENSION pljava DROP FUNCTION sqlj.java_call_handler();
ALTER EXTENSION pljava  ADD FUNCTION sqlj.java_call_handler();
ALTER EXTENSION pljava DROP FUNCTION sqlj.javau_call_handler();
ALTER EXTENSION pljava  ADD FUNCTION sqlj.javau_call_handler();

ALTER EXTENSION pljava ADD LANGUAGE java;
ALTER EXTENSION pljava ADD LANGUAGE javau;

ALTER EXTENSION pljava ADD
 FUNCTION sqlj.add_type_mapping(character varying,character varying);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.drop_type_mapping(character varying);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.get_classpath(character varying);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.install_jar(bytea,character varying,boolean);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.install_jar(character varying,character varying,boolean);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.remove_jar(character varying,boolean);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.replace_jar(bytea,character varying,boolean);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.replace_jar(character varying,character varying,boolean);
ALTER EXTENSION pljava ADD
 FUNCTION sqlj.set_classpath(character varying,character varying);

ALTER EXTENSION pljava ADD TABLE sqlj.classpath_entry;
ALTER EXTENSION pljava ADD TABLE sqlj.jar_descriptor;
ALTER EXTENSION pljava ADD TABLE sqlj.jar_entry;
ALTER EXTENSION pljava ADD TABLE sqlj.jar_repository;
ALTER EXTENSION pljava ADD TABLE sqlj.typemap_entry;

ALTER EXTENSION pljava ADD SEQUENCE sqlj.jar_entry_entryid_seq;
ALTER EXTENSION pljava ADD SEQUENCE sqlj.jar_repository_jarid_seq;
ALTER EXTENSION pljava ADD SEQUENCE sqlj.typemap_entry_mapid_seq;
