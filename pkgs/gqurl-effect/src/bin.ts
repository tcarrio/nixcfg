#!/usr/bin/env node

import * as BunContext from "@effect/platform-bun/BunContext"
import * as BunRuntime from "@effect/platform-bun/BunRuntime"
import * as Effect from "effect/Effect"
import { run } from "./Cli.js"

run(process.argv).pipe(
  Effect.provide(BunContext.layer),
  BunRuntime.runMain({ disableErrorReporting: true })
)
