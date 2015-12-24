/*
 * Copyright (c) 2015 Tada AB and other contributors, as listed below.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the The BSD 3-Clause License
 * which accompanies this distribution, and is available at
 * http://opensource.org/licenses/BSD-3-Clause
 *
 * Contributors:
 *   Chapman Flack
 */

/*
 * InstallHelper is a place to put functions that are useful for improving the
 * user experience in first setting up PL/Java, but may also involve diving
 * deeper into PostgreSQL internals than is common for PL/Java (just to dig out
 * values that aren't more directly exposed), so those internal .h files can be
 * included only in InstallHelper.c and will not clutter most other code.
 */

/*
 * The path from which this library is being loaded, which is surprisingly
 * tricky to find (and wouldn't be, if PostgreSQL called _PG_init functions
 * with the path of the library being loaded!). Set by pljavaCheckExtension().
 */
extern char const *pljavaLoadPath;

/*
 * If an extension is being created, try to determine pljavaLoadPath from a
 * temporary table in the sqlj schema; if it's there, created by PL/Java's
 * extension script, then the extension being created is PL/Java itself, so
 * set pljavaLoadingAsExtension and pljavaLoadPath accordingly. Otherwise
 * PL/Java is just being mentioned while creating some other extension, so set
 * pljavaInExtension. If an extension is not being created, just check for a
 * LOAD command and set pljavaLoadPath accordingly.
 *
 * Only called from _PG_init, which only calls once.
 */
extern void pljavaCheckExtension();

extern bool pljavaLoadingAsExtension;
extern bool pljavaInExtension;

/*
 * Another way of getting the library path: if invoked by the fmgr before
 * initialization is complete, save the last function Oid seen (trusted or
 * untrusted) ... can be used later to get the library path if needed.
 */
extern char *pljavaFnOidToLibPath(Oid fn);

extern Oid pljavaTrustedOid, pljavaUntrustedOid;

/*
 * Return the name of the current database, from MyProcPort ... don't free it.
 */
extern char *pljavaDbName();

/*
 * Construct a default for pljava.classpath ($sharedir/pljava/pljava-$VER.jar)
 * in pathbuf (which must have length at least MAXPGPATH), and return pathbuf,
 * or NULL if the constructed path would not fit.
 */
extern char const *InstallHelper_defaultClassPath(char *);

extern char *InstallHelper_hello();

extern void InstallHelper_groundwork();

extern void InstallHelper_initialize();
