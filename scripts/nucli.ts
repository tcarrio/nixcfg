#!/usr/bin/env bun

import { $ } from "bun";
import path from "node:path";

interface NetworkMetadata {
    ip: string;
    mac: string;
}

const NUC_METADATA: Map<`nuc${number}`, NetworkMetadata> = new Map([
    { ip: '192.168.40.200', mac: 'f4:4d:30:61:9b:19' },
    { ip: '192.168.40.201', mac: 'f4:4d:30:62:4c:26' },
    { ip: '192.168.40.202', mac: 'f4:4d:30:61:99:ab' },
    { ip: '192.168.40.203', mac: 'f4:4d:30:61:8c:cf' },
    { ip: '192.168.40.204', mac: 'f4:4d:30:61:99:ad' },
    { ip: '192.168.40.205', mac: 'f4:4d:30:61:8a:9d' },
    { ip: '192.168.40.206', mac: 'f4:4d:30:62:4a:76' },
    { ip: '192.168.40.207', mac: 'f4:4d:30:62:4a:43' },
    { ip: '192.168.40.208', mac: 'f4:4d:30:61:9a:e0' },
    { ip: '192.168.40.209', mac: 'f4:4d:30:61:99:ed' },
].map((metadata, index) => [`nuc${index}`, metadata]));

// TODO: Configurable options
const targetUser = "archon";
const rebuildArg = "switch";
const inputFlake = path.join(process.env.HOME, '0xc', 'nixcfg');

console.table(process.argv);

const inputNuc = process.argv[2]?.trim();

if (!inputNuc) {
    console.error("No target NUC provided");
    process.exit(1);
}

const targetNuc = inputNuc.toLowerCase();

if (!/^nuc[0-9]$/i.test(targetNuc)) {
    console.error(`Invalid target NUC provided`);
    process.exit(1);
}

console.debug("Will target NUC: " + targetNuc);

const networkMetadata = NUC_METADATA.get(targetNuc);

if (!networkMetadata) {
    console.error(`No network metadata found for ${targetNuc}`);
    process.exit(1);
}

const { ip, mac } = networkMetadata;


await $`wakeonlan ${mac}`;

// TODO: provision host secrets

await $`nixos-rebuild ${rebuildArg} --flake ${inputFlake}#${targetNuc} --target-host ${targetUser}@${ip} --use-remote-sudo`;
