import type { Context } from "hono";

export type MaybePromise<T> = T | Promise<T>;

export type Factory<T> = SyncFactory<T> | AsyncFactory<T>;
export type SyncFactory<T> = () => T;
export type AsyncFactory<T> = () => Promise<T>;

export type MaybeFactory<T> = T | Factory<T>;

export class HonoContextInjector {
  private readonly eachMap: Map<string, MaybeFactory<unknown>> = new Map();
  private readonly onceMap: Map<string, MaybeFactory<unknown>> = new Map();

  private oncePromise: Promise<Record<string, unknown>> | null = null;

  each<K extends string, V>(key: K, valueOrFactory: MaybeFactory<V>): this {
    if (this.eachMap.has(key)) {
      throw new Error(`Duplicate entry for key: ${key}`);
    }

    this.eachMap.set(key, valueOrFactory);

    return this;
  }

  once<K extends string, V>(key: K, valueOrFactory: MaybeFactory<V>): this {
    if (this.onceMap.has(key)) {
      throw new Error(`Duplicate entry for key: ${key}`);
    }

    this.onceMap.set(key, valueOrFactory);

    return this;
  }

  async forContext(c: Context<any>): Promise<void> {
    const onceDependencies = await this.getOnce();

    // TODO: inject dependencies
  }

  private async getOnce(): Promise<Record<string, unknown>> {
    if (this.oncePromise !== null) {
      return this.oncePromise;
    }

    const factoryEntries = [...this.onceMap.entries()];

    const awaitedFactoryKeyPairs = async ([key, value]: [
      string,
      MaybeFactory<unknown>
    ]): Promise<[string, unknown]> => [key, await value];

    const keyPairsToRecord = (pairs: [string, unknown][]) =>
      pairs.reduce(
        (arr, [key, value]) => ({ ...arr, [key]: value }),
        {} as Record<string, unknown>
      );

    this.oncePromise = Promise.all(
      factoryEntries.map(awaitedFactoryKeyPairs)
    ).then((results) => keyPairsToRecord(results));

    return this.oncePromise;
  }
}
