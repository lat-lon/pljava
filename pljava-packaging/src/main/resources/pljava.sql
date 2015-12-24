\echo Use "CREATE EXTENSION pljava" to load this file. \quit

/*
 Note: most of the work of setting up PL/Java is done within PL/Java itself,
 touched off by the LOAD command, making possible a decent installation
 experience even on pre-9.1, pre-extension PostgreSQL versions. This script
 simply wraps that.
 
 However, in this case, the native library has no easy way to find the
 pathname it has just been loaded from (it looks for the path given to its
 LOAD command, but finds the CREATE EXTENSION command instead). So, temporarily
 save the path in a table.

 The table's existence also helps PL/Java distinguish the case where it is
 being loaded as an extension itself (via this script), and the case where
 it is simply being awakened during the creation of some other extension
 (CREATE EXTENSION foo where foo is something implemented using PL/Java).
 */

DROP TABLE IF EXISTS @extschema@.loadpath;
CREATE TABLE @extschema@.loadpath(s) AS SELECT CAST('MODULE_PATHNAME' AS text);
LOAD 'MODULE_PATHNAME';
DROP TABLE @extschema@.loadpath;

/*
 Ok, the LOAD succeeded, so everything happened ... unless ... the same
 PL/Java library had already been loaded earlier in this same session.
 That would be an unusual case, but confusing if it happened, because
 PostgreSQL turns LOAD into a (successful) no-op in that case, meaning
 CREATE EXTENSION might appear to succeed without really completing.
 To fail fast in that case, execute some command that needs PL/Java to work.
 It may still give a bewildering error message on failure ("function
 sqlj.get_classpath(unknown) does not exist" hardly sheds any light on the
 real problem, but at least it detects that there is a problem). The result
 goes nowhere; CREATE EXTENSION sends any SELECT output from scripts to the
 bit bucket.

 The solution to a problem detected here is simply to close the session,
 and be sure to execute 'CREATE EXTENSION pljava' in a new session (new
 at least in the sense that Java hasn't been used in it yet).
 */

SELECT sqlj.get_classpath('public');

/*
 All of these tables in sqlj are created empty by PL/Java itself, and
 the contents are things later loaded by the user, so configure them to
 be dumped. XXX Future work: loaded jars could be extensions themselves,
 so these tables should be extended to record when that's the case, and the
 config_dump calls should have WHERE clauses to avoid dumping rows that
 would be supplied naturally by recreating those extensions.
 */

SELECT pg_catalog.pg_extension_config_dump('@extschema@.jar_repository', '');
SELECT pg_catalog.pg_extension_config_dump('@extschema@.jar_entry', '');
SELECT pg_catalog.pg_extension_config_dump('@extschema@.jar_descriptor', '');
SELECT pg_catalog.pg_extension_config_dump('@extschema@.classpath_entry', '');
SELECT pg_catalog.pg_extension_config_dump('@extschema@.typemap_entry', '');
