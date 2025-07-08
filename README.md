# daml-cx-kb-local-pqs

This is a sample program intended to illustrate operation of a local
PQS instance running against a sandbox ledger. It is composed of a
simple Daml model, code to manage a local PQS instance and sandbox
running that model, and a Python program that can execute various
commands against that sandbox instance.

## Disclaimer

This code is presented as an example only, with no guarantees made
about fitness or suitablity for any purpose. See the license text
below for more details.

## Note on Daml 2

This version of the demo is written to use Daml 3.x. If you would like
to run a local PQS in a Daml 2.10.x scenario, please check out the
[`daml-2`](https://github.com/mschaef-da/daml-cx-kb-local-pqs/tree/daml-2)
branch, which will operate similarly.

## Setting up Your Development Environment and Building the Project

1. Install the following dependencies:

   | Tool                                                                                | Minimum Version |
   |-------------------------------------------------------------------------------------|-----------------|
   | [yq](https://github.com/mikefarah/yq)                                               | 4.25.3          |
   | [GNU Make](https://www.gnu.org/software/make/)                                      | 3.81            |
   | [Open JDK 17](https://www.azul.com/downloads/?version=java-17-lts&package=jdk#zulu) | 17              |
   | [Postgres 17](https://www.postgresql.org/docs/17/release-17-5.html)                 | 17              |

2. Ensure Python 3.13 or newer is installed with `venv`
   - Although `venv` should be installed by default, on some systems
     (e.g. Ubuntu) it may be required to install it explicitly.
3. Then `make build` will build the Daml code and install all required
   dependencies for the Python project
4. Ensure that Postgres is running as a local service and the `psql`
   utility is in your command shell's PATH. (Instructions on how to do
   this will vary depending on the type and operating system of your
   local hardware.)
5. Ensure you have valid Daml Enterprise Artifactory credentials
   populated in the following enviornment variables:
   `ARTIFACTORY_READONLY_USER` and
   `ARTIFACTORY_READONLY_PASSWORD`. (These are used to download the
   Scribe component of PQS.)

## Querying the PQS Database

The PQS database can be queried like any other locally hosted Postgres
database:

```
 $ psql pqs
psql (17.5 (Homebrew))
Type "help" for help.

pqs=# select count(*) from active();
 count 
-------
     1
(1 row)

```

### PQS Database State

This example is configured to store all PQS data in a Postgres
database named `pqs` owned by a role also named `pqs`. This state can
be dropped entirely by issuing the command `make drop-pqs-db`.

The run script (described below) will ensure that the role and
database are recreated on the next application startup.

Be aware that the current configuration (PQS running against an
in-memory sandbox) implies that restarting the application forces the
need to drop and recreate the PQS state.  This happens because on a
restart, the Sandbox (storing state in-memory) loses state that's
already been persisted to the PQS database. On the second startup, PQS
(scribe) will notice that it's aware of history that doesn't exist on the
ledger and fail with the following sort of error:

```
07:23:14 scribe.1 | 07:23:14.910 I [zio-fiber-889572176] com.digitalasset.zio.daml.ledgerapi.StateService:63 Retrieved ledger start offset: GENESIS  trace_id=00000000000000000000000000000000 application=scribe
07:23:14 scribe.1 | 07:23:14.916 I [zio-fiber-889572176] com.digitalasset.zio.daml.ledgerapi.StateService:69 Retrieved ledger end offset: 10  trace_id=00000000000000000000000000000000 application=scribe
07:23:14 scribe.1 | 07:23:14.994 E [zio-fiber-889572176] com.digitalasset.scribe.app.ComposableApp:66  Exception in thread "zio-fiber-889572176" java.lang.Throwable: Requested start '23' is outside of ledger history 'GENESIS...10'.
```

## Running Commands

Build and start a running instance of the configuration with the
commannd `make run`. After a few minutes to download the necessary
components, build the software, and run the configuration, you should
see output similar to this:

```
07:13:54 ledger.1 | DAR upload succeeded.
07:13:54 ledger.1 | Canton sandbox is ready.
...
07:14:14 ledger.1 | 2025-07-08 07:14:14,378 [input-mapping-pool-11] INFO  c.d.c.p.i.p.ParallelIndexerSubscription:participant=sandbox tid:4adca5401c39e15462e9b5739edd0d43 - Storing at offset=12 EmptyAcsPublicationRequired(synchronizerId = mysynchronizer::12201297fefb..., sequencerTimestamp = 2025-07-08T11:14:14.246743Z)
07:14:14 scribe.1 | 07:14:14.390 I [zio-fiber-1980225161] com.digitalasset.zio.daml.ledgerapi.UpdateService:124 Received transactions responses at offsets:   application=scribe
```

Once the ledger is running, both Canton ledger and Scribe PQS logs
will be visible (with a prefix indicating which) in the terminal
window in which you ran `make run`. Commands against the ledger can be
executed with the Python program in another window via the `run`
script. In the spirit of `git`, it offers a range of subcommands for
various functions it offers:


```
~/daml-cx-kb-python-grpc $ ./run
Available subcommands:
   allocate-party
   archive-asset
   give-asset
   issue-asset
   ledger-end
   list-contracts
   list-local-parties
   list-packages
   list-parties
   list-updates
   repeatedly
   stream-updates
   version
```

An example of a simple interaction:

### Allocate two parties: `alice` and `bob`:

```
$ ./run allocate-party alice
party_details {
  party: "alice::122005d3eb878afd11dd6b6356f0b0cd3743412022dfe495b69f2a9bae307698ae26"
  display_name: "alice"
  is_local: true
  local_metadata {
    resource_version: "0"
  }
}

n= 1

$ ./run allocate-party bob
party_details {
  party: "bob::122005d3eb878afd11dd6b6356f0b0cd3743412022dfe495b69f2a9bae307698ae26"
  display_name: "bob"
  is_local: true
  local_metadata {
    resource_version: "0"
  }
}

n= 1
```

### Alice issues an asset and inspects the result

```
$ ./run issue-asset alice widget

$ ./run list-updates alice
===== Transaction ofs: 16, command_id: bfebd6f5c2c845c1b06356e4fd12e9c8, wfid:
  === EVENT:  created Main:Asset 00cc9fc2e39a3c1b714fe0f098d3316b5f05fa9df36989b6d3f87d21c3b4fd37e8ca10122075714ad478b8f1b16939df7eab16c64cf483852e50ffa03de9051af93657edbe
       {'issuer': Party(party='alice::122005d3eb878afd11dd6b6356f0b0cd3743412022dfe495b69f2a9bae307698ae26'),
        'name': 'widget',
        'owner': Party(party='alice::122005d3eb878afd11dd6b6356f0b0cd3743412022dfe495b69f2a9bae307698ae26')}
```

## License

**You may use the contents of this repository in parts or in whole according to the `0BSD` license.**

Copyright &copy; 2025 Digital Asset (Switzerland) GmbH and/or its affiliates

> Permission to use, copy, modify, and/or distribute this software for
> any purpose with or without fee is hereby granted.
>
> THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL
> WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
> OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
> FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
> DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
> AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
> OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
