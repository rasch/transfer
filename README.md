# transfer

Upload files to [transfer.sh](https://transfer.sh), then display the url. The
file is deleted after 14 days.

## Usage

Upload a file or directory. Directories are compressed using tar and gzip. Pass
the `-e` option to encrypt the file using GnuPG before uploading.

```txt
transfer <file|directory>
transfer -e <file|directory>
```

The `transfer` script also accepts stdin.

```txt
... | transfer <file_name>
... | transfer -e <file_name>
```

## Install

```sh
pnpm add --global @rasch/transfer
```

<details><summary>npm</summary><p>

```sh
npm install --global @rasch/transfer
```

</p></details>
<details><summary>yarn</summary><p>

```sh
yarn global add @rasch/transfer
```

</p></details>
