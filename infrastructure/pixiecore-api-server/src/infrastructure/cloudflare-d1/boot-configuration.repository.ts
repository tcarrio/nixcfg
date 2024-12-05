import type { BootConfigurationRepository } from "../../domain/boot-configuration.repository.js";
import type { MAC } from "../../domain/mac.value-object.js";

// TODO: sqlite3 implementation
export class D1BootConfigurationRepository implements BootConfigurationRepository {
  constructor(private readonly d1: any) {}

  findByMAC(macAddress: MAC) {
    return null;
  }
}