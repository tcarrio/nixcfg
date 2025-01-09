import type { BootConfigurationRepository } from "../../domain/boot-configuration.repository.js";
import type { MAC } from "../../domain/mac.value-object.js";

// TODO: sqlite3 implementation
export class SQLite3BootConfigurationRepository implements BootConfigurationRepository {
  constructor(private readonly db: any) {}

  findByMAC(macAddress: MAC) {
    return null;
  }
}