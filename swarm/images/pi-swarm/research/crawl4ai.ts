/**
 * Search provider plugin: Crawl4AI REST (self-hosted extract tier).
 * Written for oh-mine-pi swarm; interface conformed to pi-deep-research
 * examples/providers/{searxng,firecrawl}.ts (czhiming-maker/pi-deep-research).
 *
 * Install: entrypoint copies this to ~/.pi/agent/pi-deep-research/providers/
 *   export CRAWL4AI_BASE_URL=http://10.0.0.10:11235
 *   export CRAWL4AI_API_TOKEN='<token>'   (required by Crawl4AI >= 0.9)
 *   SEARCH_PROVIDERS=searxng,crawl4ai,firecrawl
 *
 * Extract-only provider: Crawl4AI has no search index, so search() yields []
 * and the chain uses it for JS-rendered extraction via POST {base}/md.
 */

// Self-contained type shims: keep this file editor-clean when copied to
// ~/.pi/agent/pi-deep-research/providers/, where no @types/node exists.
declare const process: { env: Record<string, string | undefined> };

const MAX_WORDS = 8000;

export default {
	name: "crawl4ai",
	tier: "local" as const,
	isConfigured: () => Boolean(process.env.CRAWL4AI_BASE_URL && process.env.CRAWL4AI_API_TOKEN),
	async search(_req: { query: string; maxResults: number; signal?: AbortSignal }) {
		// No search index behind this endpoint — extract tier only.
		return [];
	},
	async extract(url: string, signal?: AbortSignal) {
		const baseUrl = process.env.CRAWL4AI_BASE_URL!.replace(/\/+$/, "");
		const resp = await fetch(`${baseUrl}/md`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Authorization: `Bearer ${process.env.CRAWL4AI_API_TOKEN}`,
			},
			body: JSON.stringify({ url }),
			signal: signal ?? AbortSignal.timeout(60000),
		});

		if (!resp.ok) {
			const text = await resp.text();
			throw new Error(`Crawl4AI md error ${resp.status}: ${text}`);
		}

		const data = (await resp.json()) as {
			markdown?: string;
			data?: { markdown?: string };
			result?: { markdown?: string };
		};

		const rawContent = data.markdown ?? data.data?.markdown ?? data.result?.markdown ?? "";
		if (!rawContent.trim()) throw new Error("Crawl4AI returned no content");

		const { content, wordCount } = truncateToWords(rawContent);
		return { title: "", url, content, wordCount, provider: "crawl4ai" };
	},
};

function truncateToWords(content: string): { content: string; wordCount: number } {
	const re = /\S+/g;
	let count = 0;
	let cutIdx = -1;
	let m: RegExpExecArray | null;
	while ((m = re.exec(content)) !== null) {
		count++;
		if (count === MAX_WORDS) cutIdx = m.index + m[0].length;
	}
	if (count <= MAX_WORDS) return { content, wordCount: count };
	return { content: content.slice(0, cutIdx) + `\n\n[... truncated, total ${count} words]`, wordCount: count };
}
