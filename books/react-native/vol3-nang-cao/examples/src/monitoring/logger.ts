// Monitoring tối giản: breadcrumbs (dấu vết thao tác) + báo lỗi qua các "transport".
// Transport thật có thể là Sentry; trong sách mặc định là console (không cần tài khoản/DSN).

export type Level = 'info' | 'warn' | 'error';

export interface Breadcrumb {
  at: number;
  level: Level;
  message: string;
  data?: Record<string, string | number | boolean>;
}

export interface ErrorReport {
  error: Error;
  breadcrumbs: Breadcrumb[];
  context?: Record<string, string>;
}

export type Transport = (report: ErrorReport) => void;

const MAX_BREADCRUMBS = 30;
const SENSITIVE_KEY = /pin|password|token|secret/i;

export function createLogger(now: () => number = Date.now) {
  let crumbs: Breadcrumb[] = [];
  const transports: Transport[] = [];

  return {
    addBreadcrumb(level: Level, message: string, data?: Breadcrumb['data']) {
      // Không bao giờ ghi dữ liệu nhạy cảm vào log.
      const safe = data
        ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, SENSITIVE_KEY.test(k) ? '[ẩn]' : v]))
        : undefined;
      crumbs = [...crumbs, { at: now(), level, message, data: safe }].slice(-MAX_BREADCRUMBS);
    },
    breadcrumbs: () => crumbs,
    addTransport(t: Transport) {
      transports.push(t);
      return () => {
        const i = transports.indexOf(t);
        if (i >= 0) transports.splice(i, 1);
      };
    },
    reportError(error: unknown, context?: Record<string, string>) {
      const err = error instanceof Error ? error : new Error(String(error));
      const report: ErrorReport = { error: err, breadcrumbs: crumbs, context };
      for (const t of transports) {
        try {
          t(report);
        } catch {
          // transport lỗi không được làm hỏng app
        }
      }
      return report;
    },
    clear() {
      crumbs = [];
    },
  };
}

export const logger = createLogger();

export const consoleTransport: Transport = ({ error, breadcrumbs, context }) => {
  console.warn(`[monitoring] ${error.name}: ${error.message}`, { context, breadcrumbs: breadcrumbs.length });
};
