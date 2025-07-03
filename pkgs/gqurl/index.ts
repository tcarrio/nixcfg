import { parseArgs } from 'node:util';

interface GqUrlOptions {
  url: string;
  query: string;
  variables: Record<string, any>;
  headers: Record<string, string>;
  verbose: boolean;
}

const stdout = (...contents: unknown[]) => console.log(...contents);
const stderr = (...contents: unknown[]) => console.error(...contents);

function showUsage(status: number = 0) {
  const log = status > 0 ? stderr : stdout;
  log('Usage: gqurl <url> [query] [options]');
  log('If query is not provided, it will be read from stdin.');
  log('Options:');
  log('  -v, --variable <key=value>  Add a variable to the query');
  log('  -H, --header <key:value>    Add a header to the request');
  log('  -d, --verbose              Enable verbose output');
  log('  -h, --help                 Show this help message and exit');
}

async function readStdin(): Promise<string> {
  return new Promise((resolve, reject) => {
    let data = '';
    process.stdin.setEncoding('utf8');

    process.stdin.on('data', (chunk) => {
      data += chunk;
    });

    process.stdin.on('end', () => {
      resolve(data.trim());
    });

    process.stdin.on('error', (error) => {
      reject(error);
    });
  });
}

async function parseCli(): Promise<GqUrlOptions> {
  let parsedArgs;
  try {
    parsedArgs = parseArgs({
      args: process.argv.slice(2),
      options: {
        variable: {
          type: 'string',
          short: 'v',
          multiple: true,
          default: [],
        },
        header: {
          type: 'string',
          short: 'H',
          multiple: true,
          default: [],
        },
        verbose: {
          type: 'boolean',
          short: 'd',
          default: false,
        },
        help: {
          type: 'boolean',
          short: 'h',
          default: false,
        },
      },
      allowPositionals: true,
    });
  } catch (error) {
    showUsage(1);
    process.exit(1);
  }

  const { values, positionals } = parsedArgs;

  if (values.help) {
    showUsage(0);
    process.exit(0);
  }

  if (positionals.length < 1) {
    showUsage(1);
    process.exit(1);
  }

  const url = positionals[0];
  let query: string;

  if (positionals.length === 1) {
    // Read query from stdin if URL is not passed
    query = await readStdin();
    if (!query) {
      console.error('Error: No query provided via stdin');
      process.exit(1);
    }
  } else {
    // Use provided query argument for URL
    query = positionals[1];
  }

  const variables: Record<string, any> = {};
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  // Parse variables (key=value format)
  const variableArray = Array.isArray(values.variable) ? values.variable : [values.variable];
  for (const variable of variableArray) {
    const [key, value] = variable.split('=', 2);
    if (key && value !== undefined) {
      try {
        // Try to parse as JSON first
        variables[key] = JSON.parse(value);
      } catch {
        // Fall back to string if not valid JSON
        variables[key] = value;
      }
    }
  }

  // Parse headers
  const headerArray = Array.isArray(values.header) ? values.header : [values.header];
  for (const header of headerArray) {
    const [key, value] = header.split(/: ?/, 2).map((s) => s.trim());
    if (key && value) {
      headers[key] = value;
    }
  }

  return {
    url,
    query,
    variables,
    headers,
    verbose: values.verbose,
  };
}

async function executeGraphQLQuery(options: GqUrlOptions): Promise<void> {
  const { url, query, variables, headers, verbose } = options;

  const payload = {
    query,
    variables,
  };

  if (verbose) {
    stderr('Request:');
    stderr(`URL: ${url}`);
    stderr('Headers:', headers);
    stderr('Payload:', JSON.stringify(payload, null, 2));
  }

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (verbose) {
      process.stderr.write('Response:\n');
      stderr(`Status: ${response.status}`);
      stderr('Headers:', response.headers.toJSON());
    }

    stdout(JSON.stringify(data, null, 2));
  } catch (error) {
    stderr('Error executing GraphQL query:', error);
    process.exit(1);
  }
}

async function main() {
  const options = await parseCli();
  await executeGraphQLQuery(options);
}

if (require.main === module) {
  main().catch((err) => {
    stderr(err);
    process.exit(1);
  });
}
