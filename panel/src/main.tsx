import React, { useEffect, useMemo, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import {
  AlertCircle,
  Bell,
  BarChart3,
  BriefcaseBusiness,
  CalendarDays,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  Clock3,
  FileText,
  Image as ImageIcon,
  Inbox,
  LayoutDashboard,
  LogOut,
  Megaphone,
  MessageSquare,
  Newspaper,
  Pencil,
  Plus,
  School,
  Search,
  Send,
  Settings,
  Trash2,
  UploadCloud,
  Users,
  X
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import "./styles.css";

const API_URL =
  import.meta.env.VITE_API_URL ?? "https://backend-tawny-delta-99.vercel.app";
const sessionExpiredEvent = "tescon_admin_session_expired";
let adminRefreshInFlight: Promise<void> | null = null;

function clearAdminSession() {
  localStorage.removeItem("tescon_admin_token");
  localStorage.removeItem("tescon_admin_refresh_token");
  window.dispatchEvent(new Event(sessionExpiredEvent));
}

async function apiFetch(path: string, init: RequestInit = {}, retrying = false) {
  const token = localStorage.getItem("tescon_admin_token");
  const isFormData = init.body instanceof FormData;
  const response = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: {
      ...(isFormData ? {} : { "Content-Type": "application/json" }),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(init.headers ?? {})
    }
  });

  if (response.status === 401 && !retrying) {
    try {
      await refreshAdminSession();
      return apiFetch(path, init, true);
    } catch {
      clearAdminSession();
      throw new Error("Session expired. Please log in again.");
    }
  }

  return response;
}

async function refreshAdminSession() {
  if (adminRefreshInFlight) return adminRefreshInFlight;

  adminRefreshInFlight = refreshAdminSessionOnce().finally(() => {
    adminRefreshInFlight = null;
  });

  return adminRefreshInFlight;
}

async function refreshAdminSessionOnce() {
  const refreshToken = localStorage.getItem("tescon_admin_refresh_token");
  if (!refreshToken) throw new Error("Session expired");

  const response = await fetch(`${API_URL}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken })
  });
  const data = await response.json();
  if (!response.ok) {
    clearAdminSession();
    throw new Error("Session expired. Please log in again.");
  }

  localStorage.setItem("tescon_admin_token", data.tokens.accessToken);
  localStorage.setItem("tescon_admin_refresh_token", data.tokens.refreshToken);
}

type ResourceKey =
  | "users"
  | "executives"
  | "chapters"
  | "news"
  | "events"
  | "announcements"
  | "jobs"
  | "jobApplications"
  | "polls"
  | "conversations"
  | "notifications"
  | "contacts";

type ActiveKey = "dashboard" | ResourceKey;

type FieldType = "text" | "textarea" | "lines" | "datetime-local" | "select" | "password" | "checkbox" | "image" | "image-list";
type SelectOption = string | { value: string; label: string };

type Resource = {
  key: ResourceKey;
  label: string;
  endpoint: string;
  icon: React.ReactNode;
  fields: Field[];
};

type Field = {
  key: string;
  label: string;
  type?: FieldType;
  options?: SelectOption[];
};

type AdminRecord = Record<string, unknown> & {
  id: string;
  title?: string;
  fullName?: string;
  name?: string;
  question?: string;
  email?: string;
  topic?: string;
  summary?: string;
  description?: string;
  company?: string;
  job?: AdminRecord;
  interviewAt?: string;
  institution?: string;
  coverNote?: string;
  body?: string;
  status?: string;
  resolved?: boolean;
  imageUrl?: string;
  imageUrls?: string[];
  logoUrl?: string;
  avatarUrl?: string;
  organizationRole?: string;
  createdAt?: string;
  updatedAt?: string;
};

type DashboardSummary = Partial<Record<ResourceKey, AdminRecord[]>>;

type ApiRowsResponse = {
  rows: AdminRecord[];
};

type ChapterOption = {
  id: string;
  name?: string;
  campus?: string;
};

type Notice = {
  type: "info" | "success" | "error";
  message: string;
};

const publishOptions = ["DRAFT", "PUBLISHED", "ARCHIVED"];
const organizationRoleOptions = [
  "President",
  "Vice President",
  "General Secretary",
  "Deputy Secretary",
  "Organizer",
  "Deputy Organizer",
  "Treasurer",
  "Financial Secretary",
  "Communications Director",
  "Communications Lead",
  "Public Relations Officer",
  "Women Organizer",
  "Youth Organizer",
  "Welfare Officer",
  "Research Officer",
  "Programs Coordinator",
  "Events Coordinator",
  "Electoral Coordinator",
  "Chapter Executive",
  "TESCON Member"
];

const resources: Resource[] = [
  {
    key: "users",
    label: "Members",
    endpoint: "users",
    icon: <Users size={18} />,
    fields: [
      { key: "fullName", label: "Full name" },
      { key: "email", label: "Email" },
      { key: "phone", label: "Phone" },
      { key: "institution", label: "Institution" },
      { key: "avatarUrl", label: "Profile photo", type: "image" },
      { key: "organizationRole", label: "Organization role", type: "select", options: organizationRoleOptions },
      { key: "chapterId", label: "Campus chapter", type: "select", options: [] },
      { key: "status", label: "Status", type: "select", options: ["PENDING", "ACTIVE", "SUSPENDED"] }
    ]
  },
  {
    key: "executives",
    label: "Executives",
    endpoint: "executives",
    icon: <Users size={18} />,
    fields: [
      { key: "fullName", label: "Full name" },
      { key: "email", label: "Email" },
      { key: "phone", label: "Phone" },
      { key: "institution", label: "Institution" },
      { key: "avatarUrl", label: "Profile photo", type: "image" },
      { key: "organizationRole", label: "Executive role", type: "select", options: organizationRoleOptions },
      { key: "chapterId", label: "Campus chapter", type: "select", options: [] },
      { key: "status", label: "Status", type: "select", options: ["PENDING", "ACTIVE", "SUSPENDED"] }
    ]
  },
  {
    key: "chapters",
    label: "Chapters",
    endpoint: "chapters",
    icon: <School size={18} />,
    fields: [
      { key: "name", label: "Name" },
      { key: "campus", label: "Campus" },
      { key: "region", label: "Region" },
      { key: "memberEstimate", label: "Member estimate" },
      { key: "description", label: "Description", type: "textarea" },
      { key: "logoUrl", label: "Chapter logo", type: "image" }
    ]
  },
  {
    key: "news",
    label: "News",
    endpoint: "news",
    icon: <Newspaper size={18} />,
    fields: contentFields(["category", "imageUrls", "publishedAt"])
  },
  {
    key: "events",
    label: "Events",
    endpoint: "events",
    icon: <CalendarDays size={18} />,
    fields: [
      { key: "title", label: "Title" },
      { key: "description", label: "Description", type: "textarea" },
      { key: "organizer", label: "Organizer" },
      { key: "venue", label: "Venue" },
      { key: "venueNote", label: "Venue note" },
      { key: "startsAt", label: "Starts at", type: "datetime-local" },
      { key: "endsAt", label: "Ends at", type: "datetime-local" },
      { key: "feeLabel", label: "Fee label" },
      { key: "chatUrl", label: "Event chat link" },
      { key: "imageUrls", label: "Event images", type: "image-list" },
      { key: "status", label: "Status", type: "select", options: publishOptions }
    ]
  },
  {
    key: "announcements",
    label: "Announcements",
    endpoint: "announcements",
    icon: <Megaphone size={18} />,
    fields: [
      { key: "title", label: "Title" },
      { key: "body", label: "Body", type: "textarea" },
      { key: "priority", label: "Priority", type: "select", options: ["normal", "high", "urgent"] },
      { key: "status", label: "Status", type: "select", options: publishOptions },
      { key: "publishedAt", label: "Published at", type: "datetime-local" }
    ]
  },
  {
    key: "jobs",
    label: "Jobs",
    endpoint: "jobs",
    icon: <BriefcaseBusiness size={18} />,
    fields: [
      { key: "title", label: "Title" },
      { key: "company", label: "Company" },
      { key: "logoUrl", label: "Company logo", type: "image" },
      { key: "location", label: "Location" },
      { key: "type", label: "Type" },
      { key: "description", label: "Description", type: "textarea" },
      { key: "applyUrl", label: "Apply URL" },
      { key: "deadline", label: "Deadline", type: "datetime-local" },
      { key: "status", label: "Status", type: "select", options: publishOptions }
    ]
  },
  {
    key: "jobApplications",
    label: "Job Applicants",
    endpoint: "jobApplications",
    icon: <Inbox size={18} />,
    fields: [
      { key: "jobId", label: "Job ID" },
      { key: "fullName", label: "Applicant name" },
      { key: "email", label: "Email" },
      { key: "phone", label: "Phone" },
      { key: "institution", label: "Institution" },
      { key: "coverNote", label: "Cover note", type: "textarea" },
      { key: "status", label: "Stage", type: "select", options: ["APPLIED", "SHORTLISTED", "INTERVIEW_SCHEDULED", "INTERVIEWED", "OFFERED", "REJECTED"] },
      { key: "interviewAt", label: "Interview at", type: "datetime-local" },
      { key: "interviewNote", label: "Interview note", type: "textarea" }
    ]
  },
  {
    key: "polls",
    label: "Polls",
    endpoint: "polls",
    icon: <FileText size={18} />,
    fields: [
      { key: "question", label: "Question" },
      { key: "description", label: "Description", type: "textarea" },
      { key: "options", label: "Options, one per line", type: "lines" },
      { key: "visibility", label: "Visibility", type: "select", options: ["members", "public", "executives"] },
      { key: "allowMultipleVotes", label: "Allow multiple votes", type: "checkbox" },
      { key: "status", label: "Status", type: "select", options: publishOptions },
      { key: "closesAt", label: "Closes at", type: "datetime-local" }
    ]
  },
  {
    key: "conversations",
    label: "Chat Rooms",
    endpoint: "conversations",
    icon: <MessageSquare size={18} />,
    fields: [
      { key: "title", label: "Title" },
      { key: "isGroup", label: "Group chat", type: "checkbox" }
    ]
  },
  {
    key: "notifications",
    label: "Notifications",
    endpoint: "notifications",
    icon: <Bell size={18} />,
    fields: [
      { key: "title", label: "Title" },
      { key: "body", label: "Body", type: "textarea" },
      { key: "userId", label: "User ID optional" }
    ]
  },
  {
    key: "contacts",
    label: "Contact Inbox",
    endpoint: "contacts",
    icon: <Send size={18} />,
    fields: [
      { key: "name", label: "Name" },
      { key: "email", label: "Email" },
      { key: "topic", label: "Topic" },
      { key: "message", label: "Message", type: "textarea" },
      { key: "resolved", label: "Resolved", type: "checkbox" }
    ]
  }
];

function contentFields(extra: string[]): Field[] {
  const base: Field[] = [
    { key: "title", label: "Title" },
    { key: "summary", label: "Summary", type: "textarea" },
    { key: "body", label: "Body", type: "textarea" },
    { key: "status", label: "Status", type: "select", options: publishOptions }
  ];

  const extras: Record<string, Field> = {
    category: { key: "category", label: "Category" },
    imageUrl: { key: "imageUrl", label: "Cover image", type: "image" },
    imageUrls: { key: "imageUrls", label: "Gallery images", type: "image-list" },
    publishedAt: { key: "publishedAt", label: "Published at", type: "datetime-local" }
  };

  return [...base, ...extra.map((key) => extras[key])];
}

function ActionButton({
  children,
  icon: Icon,
  variant = "secondary",
  className = "",
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  children: React.ReactNode;
  icon?: LucideIcon;
  variant?: "primary" | "secondary" | "ghost" | "danger";
}) {
  return (
    <button type="button" className={`btn btn-${variant} ${className}`.trim()} {...props}>
      {Icon && <Icon size={16} />}
      {children}
    </button>
  );
}

function IconButton({
  icon: Icon,
  label,
  tone = "neutral",
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  icon: LucideIcon;
  label: string;
  tone?: "neutral" | "danger" | "success";
}) {
  return (
    <button type="button" className={`icon-button icon-${tone}`} title={label} aria-label={label} {...props}>
      <Icon size={17} />
    </button>
  );
}

function NoticeMessage({ notice }: { notice?: Notice | null }) {
  if (!notice?.message) return null;
  const Icon = notice.type === "error" ? AlertCircle : notice.type === "success" ? CheckCircle2 : AlertCircle;
  return (
    <p className={`notice notice-${notice.type}`}>
      <Icon size={16} />
      {notice.message}
    </p>
  );
}

function SkeletonBlock({ className = "" }: { className?: string }) {
  return <span className={`skeleton ${className}`.trim()} />;
}

function DashboardSkeleton() {
  return (
    <div className="dashboard-grid">
      <section className="metric-grid">
        {Array.from({ length: 3 }, (_, index) => (
          <div className="metric-card skeleton-card" key={index}>
            <SkeletonBlock className="skeleton-icon" />
            <div>
              <SkeletonBlock className="skeleton-title" />
              <SkeletonBlock className="skeleton-line" />
              <SkeletonBlock className="skeleton-pill" />
            </div>
          </div>
        ))}
      </section>
      <section className="analytics-row">
        <div className="chart-card wide skeleton-panel">
          <SkeletonBlock className="skeleton-title" />
          <SkeletonBlock className="skeleton-chart" />
        </div>
        <div className="chart-card skeleton-panel">
          <SkeletonBlock className="skeleton-title" />
          <SkeletonBlock className="skeleton-chart short" />
        </div>
      </section>
      <section className="analytics-row bottom">
        <div className="chart-card skeleton-panel">
          <SkeletonBlock className="skeleton-title" />
          <SkeletonBlock className="skeleton-chart short" />
        </div>
        <div className="chart-card wide skeleton-panel">
          {Array.from({ length: 4 }, (_, index) => (
            <SkeletonBlock className="skeleton-row" key={index} />
          ))}
        </div>
      </section>
    </div>
  );
}

function TableSkeleton() {
  return (
    <div className="table-skeleton">
      {Array.from({ length: 6 }, (_, index) => (
        <div className="table-skeleton-row" key={index}>
          <SkeletonBlock className="skeleton-thumb" />
          <div>
            <SkeletonBlock className="skeleton-title" />
            <SkeletonBlock className="skeleton-line" />
          </div>
          <SkeletonBlock className="skeleton-pill" />
        </div>
      ))}
    </div>
  );
}

function PullToRefresh({
  onRefresh,
  children
}: {
  onRefresh: () => Promise<void>;
  children: React.ReactNode;
}) {
  const startY = useRef<number | null>(null);
  const [pullDistance, setPullDistance] = useState(0);
  const [refreshing, setRefreshing] = useState(false);
  const threshold = 78;

  async function triggerRefresh() {
    if (refreshing) return;
    setRefreshing(true);
    setPullDistance(threshold);
    try {
      await onRefresh();
    } finally {
      setRefreshing(false);
      setPullDistance(0);
      startY.current = null;
    }
  }

  return (
    <div
      className={`pull-refresh ${pullDistance > 0 || refreshing ? "pulling" : ""}`}
      onPointerDown={(event) => {
        if (window.scrollY <= 0) startY.current = event.clientY;
      }}
      onPointerMove={(event) => {
        if (startY.current === null || refreshing || window.scrollY > 0) return;
        const distance = Math.max(0, event.clientY - startY.current);
        if (distance > 0) setPullDistance(Math.min(distance, 96));
      }}
      onPointerUp={() => {
        if (pullDistance >= threshold) {
          void triggerRefresh();
        } else {
          setPullDistance(0);
          startY.current = null;
        }
      }}
      onPointerCancel={() => {
        setPullDistance(0);
        startY.current = null;
      }}
    >
      <div className="pull-indicator" style={{ height: pullDistance }}>
        {(pullDistance > 0 || refreshing) && (
          <div className="pull-shimmer">
            <SkeletonBlock className="pull-dot" />
            <span>{refreshing ? "Refreshing" : pullDistance >= threshold ? "Release to refresh" : "Pull down to refresh"}</span>
          </div>
        )}
      </div>
      {children}
    </div>
  );
}

function EmptyState({
  icon: Icon = Inbox,
  title,
  message,
  action
}: {
  icon?: LucideIcon;
  title: string;
  message: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="empty-state">
      <div className="empty-icon"><Icon size={22} /></div>
      <strong>{title}</strong>
      <span>{message}</span>
      {action}
    </div>
  );
}

function exportDashboardSummary(summary: DashboardSummary) {
  const payload = JSON.stringify(summary, null, 2);
  const blob = new Blob([payload], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = `tescon-dashboard-${new Date().toISOString().slice(0, 10)}.json`;
  anchor.click();
  URL.revokeObjectURL(url);
}

function App() {
  const [token, setToken] = useState(() => localStorage.getItem("tescon_admin_token") ?? "");
  const [activeKey, setActiveKey] = useState<ActiveKey>("dashboard");
  const [globalQuery, setGlobalQuery] = useState("");
  const active = useMemo(() => resources.find((item) => item.key === activeKey), [activeKey]);
  const pageTitle = active?.label ?? "Dashboard";

  useEffect(() => {
    function handleSessionExpired() {
      setToken("");
    }

    window.addEventListener(sessionExpiredEvent, handleSessionExpired);
    return () => window.removeEventListener(sessionExpiredEvent, handleSessionExpired);
  }, []);

  function runGlobalSearch() {
    const query = globalQuery.trim().toLowerCase();
    if (!query) return;
    const match = resources.find((resource) => resource.label.toLowerCase().includes(query));
    if (match) setActiveKey(match.key);
  }

  if (!token) {
    return <Login onLogin={setToken} />;
  }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <img className="brand-logo" src="/logo.png" alt="TESCON" />
          <div>
            <strong>TESCON</strong>
            <span>Admin Panel</span>
          </div>
        </div>

        <nav>
          <p>General</p>
          <button
            className={activeKey === "dashboard" ? "active" : ""}
            onClick={() => setActiveKey("dashboard")}
          >
            <LayoutDashboard size={18} />
            Dashboard
          </button>
          <p>Content</p>
          {resources.map((resource) => (
            <button
              key={resource.key}
              className={resource.key === activeKey ? "active" : ""}
              onClick={() => setActiveKey(resource.key)}
            >
              {resource.icon}
              {resource.label}
            </button>
          ))}
        </nav>

        <button
          className="logout nav-action"
          onClick={() => {
            clearAdminSession();
            setToken("");
          }}
        >
          <LogOut size={18} />
          Logout
        </button>
      </aside>

      <main>
        <header className="topbar">
          <label className="global-search">
            <Search size={17} />
            <input
              value={globalQuery}
              placeholder="Search modules"
              onChange={(event) => setGlobalQuery(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") runGlobalSearch();
              }}
            />
            {globalQuery && (
              <button type="button" className="search-clear" aria-label="Clear module search" onClick={() => setGlobalQuery("")}>
                <X size={14} />
              </button>
            )}
            <kbd>Enter</kbd>
          </label>
          <div className="topbar-actions">
            <IconButton icon={Bell} label="Open notifications" onClick={() => setActiveKey("notifications")} />
            <IconButton icon={Settings} label="Open members" onClick={() => setActiveKey("users")} />
            <div className="admin-profile">
              <div className="avatar">TA</div>
              <div>
                <strong>TESCON Admin</strong>
                <span>Super admin</span>
              </div>
            </div>
          </div>
        </header>

        <section className="page-heading">
          <div>
            <p>Operations Console</p>
            <h1>{pageTitle}</h1>
          </div>
          <div className="date-pill">
            <CalendarDays size={16} />
            {new Date().toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" })}
          </div>
        </section>

        {active ? (
          <ResourceManager key={active.key} resource={active} />
        ) : (
          <DashboardOverview onOpenResource={setActiveKey} />
        )}
      </main>
    </div>
  );
}

function DashboardOverview({ onOpenResource }: { onOpenResource: (key: ResourceKey) => void }) {
  const [summary, setSummary] = useState<DashboardSummary>({});
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState<Notice | null>(null);

  async function loadSummary(showNotice = true) {
    if (showNotice) setLoading(true);
    if (showNotice) setNotice(null);
    try {
      const entries = await Promise.all(
        resources.map(async (resource) => {
          const response = await apiFetch(`/api/admin/${resource.endpoint}`);
          const data = await response.json() as ApiRowsResponse & { message?: string };
          if (!response.ok) throw new Error(data.message ?? "Failed to load dashboard");
          return [resource.key, data.rows ?? []] as const;
        })
      );
      setSummary(Object.fromEntries(entries));
      if (showNotice) {
        setNotice({ type: "success", message: "Dashboard synced with live admin data." });
      }
    } catch (error) {
      setNotice({ type: "error", message: error instanceof Error ? error.message : "Failed to load dashboard" });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadSummary();
  }, []);

  useEffect(() => {
    const refreshIfVisible = () => {
      if (document.visibilityState === "visible") void loadSummary(false);
    };
    const interval = window.setInterval(refreshIfVisible, 60000);
    window.addEventListener("focus", refreshIfVisible);
    window.addEventListener("online", refreshIfVisible);
    document.addEventListener("visibilitychange", refreshIfVisible);
    return () => {
      window.clearInterval(interval);
      window.removeEventListener("focus", refreshIfVisible);
      window.removeEventListener("online", refreshIfVisible);
      document.removeEventListener("visibilitychange", refreshIfVisible);
    };
  }, []);

  const allRows = Object.values(summary).flat() as AdminRecord[];
  const totalRecords = allRows.length;
  const recentRows = (Object.entries(summary) as [ResourceKey, AdminRecord[]][])
    .flatMap(([key, rows]) => rows.slice(0, 3).map((row) => ({ ...row, resourceKey: key })))
    .sort((a, b) => new Date(b.updatedAt ?? b.createdAt ?? 0).getTime() - new Date(a.updatedAt ?? a.createdAt ?? 0).getTime())
    .slice(0, 6);
  const weeklyActivity = Array.from({ length: 7 }, (_, index) => {
    const date = new Date();
    date.setDate(date.getDate() - (6 - index));
    const dateKey = date.toDateString();
    return {
      label: date.toLocaleDateString(undefined, { weekday: "short" }),
      count: allRows.filter((row) => new Date(row.updatedAt ?? row.createdAt ?? 0).toDateString() === dateKey).length
    };
  });
  const maxWeeklyActivity = Math.max(...weeklyActivity.map((item) => item.count), 1);
  const contentKeys: ResourceKey[] = ["news", "events", "announcements", "jobs", "jobApplications", "polls"];
  const communityKeys: ResourceKey[] = ["users", "executives", "chapters", "conversations"];
  const inboxKeys: ResourceKey[] = ["notifications", "contacts"];
  const distribution = {
    content: contentKeys.reduce((total, key) => total + (summary[key]?.length ?? 0), 0),
    community: communityKeys.reduce((total, key) => total + (summary[key]?.length ?? 0), 0),
    inbox: inboxKeys.reduce((total, key) => total + (summary[key]?.length ?? 0), 0)
  };
  const distributionTotal = Math.max(distribution.content + distribution.community + distribution.inbox, 1);
  const contentEnd = (distribution.content / distributionTotal) * 100;
  const communityEnd = contentEnd + (distribution.community / distributionTotal) * 100;

  if (loading) {
    return (
      <PullToRefresh onRefresh={loadSummary}>
        <DashboardSkeleton />
      </PullToRefresh>
    );
  }

  return (
    <PullToRefresh onRefresh={loadSummary}>
      <div className="dashboard-grid">
      <NoticeMessage notice={notice} />

      <section className="analytics-row">
        <div className="chart-card wide">
          <div className="card-heading">
            <div>
              <span>Content overview</span>
              <h2>{totalRecords}</h2>
              <p>Records managed across TESCON modules</p>
            </div>
            <ActionButton icon={BarChart3} onClick={() => exportDashboardSummary(summary)}>
              Export JSON
            </ActionButton>
          </div>
          <div className="module-count-grid">
            {resources.slice(0, 6).map((resource) => {
              const count = summary[resource.key]?.length ?? 0;
              return (
                <button
                  type="button"
                  className="module-count-card"
                  key={resource.key}
                  onClick={() => onOpenResource(resource.key)}
                >
                  <span className="module-count-icon">{resource.icon}</span>
                  <strong>{count}</strong>
                  <span>{resource.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        <div className="chart-card">
          <div className="card-heading">
            <div>
              <span>Weekly activity</span>
              <h2>{weeklyActivity.reduce((total, item) => total + item.count, 0)}</h2>
              <p>Recent changes</p>
            </div>
            <span className="period-pill">Weekly</span>
          </div>
          <div className="bar-chart">
            {weeklyActivity.map((item) => (
              <div
                key={item.label}
                title={`${item.label}: ${item.count} changes`}
                className="bar-item"
              >
                <strong>{item.count}</strong>
                <span
                  className={item.count === maxWeeklyActivity && item.count > 0 ? "hot" : ""}
                  style={{ height: `${Math.max(8, (item.count / maxWeeklyActivity) * 100)}%` }}
                />
                <em>{item.label}</em>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="analytics-row bottom">
        <div className="chart-card">
          <div className="card-heading">
            <div>
              <span>Module distribution</span>
              <h2>{resources.length}</h2>
            </div>
          </div>
          <div className="donut-wrap">
            <div
              className="donut"
              style={{
                "--content-end": `${contentEnd}%`,
                "--community-end": `${communityEnd}%`
              } as React.CSSProperties}
            />
            <div className="legend">
              <span><i className="blue" /> Content <strong>{distribution.content}</strong></span>
              <span><i className="teal" /> Community <strong>{distribution.community}</strong></span>
              <span><i className="yellow" /> Inbox <strong>{distribution.inbox}</strong></span>
            </div>
          </div>
        </div>

        <div className="chart-card wide">
          <div className="card-heading">
            <div>
              <span>Recent records</span>
              <h2>Activity list</h2>
            </div>
          </div>
          <div className="activity-list">
            {recentRows.map((row) => (
              <button type="button" key={`${row.resourceKey}-${row.id}`} onClick={() => onOpenResource(row.resourceKey)}>
                <Thumbnail row={row} />
                <strong>{row.title ?? row.fullName ?? row.name ?? row.question ?? row.email ?? row.topic}</strong>
                <span>{resources.find((resource) => resource.key === row.resourceKey)?.label}</span>
              </button>
            ))}
            {!recentRows.length && (
              <EmptyState
                title="No recent activity"
                message="Create or update a record and it will appear here automatically."
              />
            )}
          </div>
        </div>
        </section>
      </div>
    </PullToRefresh>
  );
}

function Login({ onLogin }: { onLogin: (token: string) => void }) {
  const [email, setEmail] = useState("admin@tescon.app");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setError("");
    const response = await fetch(`${API_URL}/api/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    const data = await response.json();
    if (!response.ok) {
      setError(data.message ?? "Login failed");
      return;
    }
    localStorage.setItem("tescon_admin_token", data.tokens.accessToken);
    localStorage.setItem("tescon_admin_refresh_token", data.tokens.refreshToken);
    onLogin(data.tokens.accessToken);
  }

  return (
    <div className="login-page">
      <form onSubmit={submit} className="login-card">
        <img className="login-logo" src="/logo.png" alt="TESCON" />
        <h1>TESCON Admin</h1>
        <label>
          Email
          <input value={email} onChange={(event) => setEmail(event.target.value)} />
        </label>
        <label>
          Password
          <input type="password" value={password} onChange={(event) => setPassword(event.target.value)} />
        </label>
        {error && <p className="error">{error}</p>}
        <button className="primary">Login</button>
      </form>
    </div>
  );
}

function ResourceManager({ resource }: { resource: Resource }) {
  const [rows, setRows] = useState<AdminRecord[]>([]);
  const [chapterOptions, setChapterOptions] = useState<SelectOption[]>([]);
  const [editing, setEditing] = useState<AdminRecord | null>(null);
  const [editorOpen, setEditorOpen] = useState(false);
  const [form, setForm] = useState<Record<string, unknown>>(() => defaultFormFor(resource));
  const [notice, setNotice] = useState<Notice | null>(null);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [filters, setFilters] = useState<Record<string, string>>({});

  const filteredRows = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return rows.filter((row) => {
      const matchesSearch = !needle || [row.title, row.fullName, row.name, row.question, row.email, row.topic, row.summary, row.description, row.company, row.institution, row.organizationRole]
        .filter(Boolean)
        .some((value) => String(value).toLowerCase().includes(needle));
      if (!matchesSearch) return false;

      return Object.entries(filters).every(([key, value]) => {
        if (!value) return true;
        return filterValueFor(row, key).toLowerCase() === value.toLowerCase();
      });
    });
  }, [filters, query, rows]);

  const activeFilters = useMemo(() => buildFilters(resource, rows), [resource, rows]);

  useEffect(() => {
    setEditing(null);
    setEditorOpen(false);
    setFilters({});
    setForm(defaultFormFor(resource));
    load();
  }, [resource.key]);

  useEffect(() => {
    if (!resource.fields.some((field) => field.key === "chapterId")) return;
    void loadChapterOptions();
  }, [resource.key]);

  const fields = useMemo(() => {
    if (!chapterOptions.length) return resource.fields;
    return resource.fields.map((field) =>
      field.key === "chapterId" ? { ...field, options: chapterOptions } : field
    );
  }, [chapterOptions, resource.fields]);

  async function request(path = "", init?: RequestInit) {
    const response = await apiFetch(`/api/admin/${resource.endpoint}${path}`, {
      ...init,
    });
    if (response.status === 204) return null;
    const data = await response.json() as ApiRowsResponse & { message?: string };
    if (!response.ok) throw new Error(data.message ?? "Request failed");
    return data;
  }

  async function load(showNotice = true) {
    if (showNotice) {
      setLoading(true);
      setNotice(null);
    }
    try {
      const data = await request();
      setRows(data?.rows ?? []);
      if (showNotice) setNotice(null);
    } catch (error) {
      setNotice({ type: "error", message: error instanceof Error ? error.message : "Failed to load" });
    } finally {
      if (showNotice) setLoading(false);
    }
  }

  useEffect(() => {
    const refreshIfVisible = () => {
      if (document.visibilityState === "visible") void load(false);
    };
    const interval = window.setInterval(refreshIfVisible, 60000);
    window.addEventListener("focus", refreshIfVisible);
    window.addEventListener("online", refreshIfVisible);
    document.addEventListener("visibilitychange", refreshIfVisible);
    return () => {
      window.clearInterval(interval);
      window.removeEventListener("focus", refreshIfVisible);
      window.removeEventListener("online", refreshIfVisible);
      document.removeEventListener("visibilitychange", refreshIfVisible);
    };
  }, [resource.key]);

  async function loadChapterOptions() {
    try {
      const response = await apiFetch("/api/admin/chapters?pageSize=100");
      const data = await response.json() as { rows?: ChapterOption[]; message?: string };
      if (!response.ok) throw new Error(data.message ?? "Failed to load chapters");
      setChapterOptions(
        (data.rows ?? []).map((chapter) => ({
          value: chapter.id,
          label: chapter.name ?? chapter.campus ?? chapter.id
        }))
      );
    } catch (error) {
      setNotice({ type: "error", message: error instanceof Error ? error.message : "Failed to load chapters" });
    }
  }

  async function save(event: React.FormEvent) {
    event.preventDefault();
    const payload = normalizePayload(form, fields);
    try {
      if (editing) {
        await request(`/${editing.id}`, { method: "PATCH", body: JSON.stringify(payload) });
      } else {
        await request("", { method: "POST", body: JSON.stringify(payload) });
      }
      setEditing(null);
      setEditorOpen(false);
      setForm(defaultFormFor(resource));
      await load();
      setNotice({ type: "success", message: editing ? "Record updated successfully." : "Record created successfully." });
    } catch (error) {
      setNotice({ type: "error", message: error instanceof Error ? error.message : "Save failed" });
    }
  }

  async function remove(id: string) {
    if (!confirm("Delete this record?")) return;
    try {
      await request(`/${id}`, { method: "DELETE" });
      await load();
      setNotice({ type: "success", message: "Record deleted successfully." });
    } catch (error) {
      setNotice({ type: "error", message: error instanceof Error ? error.message : "Delete failed" });
    }
  }

  function startEdit(row: AdminRecord) {
    setEditing(row);
    setForm(toEditableForm(row, fields));
    setNotice(null);
    setEditorOpen(true);
  }

  function startCreate() {
    setEditing(null);
    setForm(defaultFormFor(resource));
    setNotice(null);
    setEditorOpen(true);
  }

  return (
    <PullToRefresh onRefresh={load}>
      <section className="workspace records-workspace">
      <div className="table-panel">
        <div className="table-header">
          <div>
            <span>{rows.length} records</span>
            <h2>{resource.label}</h2>
          </div>
          <div className="table-tools">
            <label className="search-box">
              <Search size={16} />
              <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search records" />
              {query && (
                <button type="button" className="search-clear" aria-label="Clear record search" onClick={() => setQuery("")}>
                  <X size={14} />
                </button>
              )}
            </label>
            <ActionButton icon={Plus} variant="primary" onClick={startCreate}>
              {resourceActionLabel(resource)}
            </ActionButton>
          </div>
        </div>
        {activeFilters.length > 0 && (
          <div className="filter-row">
            {activeFilters.map((filter) => (
              <label key={filter.key} className="filter-control">
                <span>{filter.label}</span>
                <select
                  value={filters[filter.key] ?? ""}
                  onChange={(event) => setFilters((current) => ({ ...current, [filter.key]: event.target.value }))}
                >
                  <option value="">All</option>
                  {filter.options.map((option) => (
                    <option key={option} value={option}>{option}</option>
                  ))}
                </select>
              </label>
            ))}
            {Object.values(filters).some(Boolean) && (
              <ActionButton variant="ghost" onClick={() => setFilters({})}>
                Clear filters
              </ActionButton>
            )}
          </div>
        )}
        <NoticeMessage notice={notice} />
        <div className="table-scroll">
          {loading ? (
            <TableSkeleton />
          ) : (
          <table>
            <thead>
              <tr>
                <th>{primaryColumnLabel(resource)}</th>
                {resource.key === "executives" && <th>Position</th>}
                <th>Status</th>
                <th>Updated</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filteredRows.map((row) => (
                <tr key={row.id}>
                  <td>
                    <div className="record-title">
                      <Thumbnail row={row} />
                      <div>
                        <strong>{recordTitle(row)}</strong>
                        <span>{recordSubtitle(row)}</span>
                      </div>
                    </div>
                  </td>
                  {resource.key === "executives" && (
                    <td>{row.organizationRole ? <StatusPill value={row.organizationRole} /> : "No position"}</td>
                  )}
                  <td><StatusPill value={row.status ?? (row.resolved ? "Resolved" : "Open")} /></td>
                  <td>{formatDate(row.updatedAt ?? row.createdAt)}</td>
                  <td className="row-actions">
                    <IconButton icon={Pencil} label="Edit record" onClick={() => startEdit(row)} />
                    <IconButton icon={Trash2} label="Delete record" tone="danger" onClick={() => remove(row.id)} />
                  </td>
                </tr>
              ))}
              {!filteredRows.length && (
                <tr>
                  <td colSpan={resource.key === "executives" ? 5 : 4} className="empty">
                    <EmptyState
                      title={query ? "No matching records" : "No records yet"}
                      message={query ? "Try a different search term or clear the search box." : `Use ${resourceActionLabel(resource).toLowerCase()} when you are ready to create live data.`}
                      action={!query ? <ActionButton icon={Plus} variant="primary" onClick={startCreate}>{resourceActionLabel(resource)}</ActionButton> : null}
                    />
                  </td>
                </tr>
              )}
            </tbody>
          </table>
          )}
        </div>
      </div>
      {editorOpen && (
        <div className="modal-backdrop" role="dialog" aria-modal="true">
          <form className="editor modal-editor" onSubmit={save}>
            <div className="form-body">
              <div className="panel-title">
                <div>
                  <span>{editing ? "Editing" : "New entry"}</span>
                  <h2>{editing ? "Edit record" : resourceActionLabel(resource)}</h2>
                </div>
                <IconButton
                  icon={X}
                  label="Close form"
                  onClick={() => {
                    setEditorOpen(false);
                    setEditing(null);
                    setForm(defaultFormFor(resource));
                  }}
                />
              </div>
              <div className="field-grid">
                {fields.map((field) => (
                  <FieldInput
                    key={field.key}
                    field={field}
                    value={form[field.key]}
                    onChange={(value) => setForm((current) => ({ ...current, [field.key]: value }))}
                  />
                ))}
              </div>
              <div className="actions sticky-actions">
                <ActionButton onClick={() => setForm(editing ? toEditableForm(editing, fields) : defaultFormFor(resource))}>
                  Reset
                </ActionButton>
                <button className="primary">
                  {editing ? <SaveIcon /> : <Plus size={16} />}
                  {editing ? "Save changes" : "Create"}
                </button>
              </div>
            </div>
          </form>
        </div>
      )}
      </section>
    </PullToRefresh>
  );
}

function SaveIcon() {
  return <UploadCloud size={16} />;
}

function primaryColumnLabel(resource: Resource) {
  const labels: Partial<Record<ResourceKey, string>> = {
    users: "Member",
    executives: "Executive",
    chapters: "Chapter",
    news: "News title",
    events: "Event title",
    announcements: "Announcement",
    jobs: "Job title",
    jobApplications: "Applicant",
    polls: "Poll question",
    conversations: "Chat room",
    notifications: "Notification",
    contacts: "Contact"
  };
  return labels[resource.key] ?? "Record";
}

function resourceActionLabel(resource: Resource) {
  const labels: Partial<Record<ResourceKey, string>> = {
    users: "Add Member",
    executives: "Create Executive",
    chapters: "Create Chapter",
    news: "Create News",
    events: "Create Event",
    announcements: "Create Announcement",
    jobs: "Post Job",
    jobApplications: "Add Applicant",
    polls: "Create Poll",
    conversations: "Create Chat",
    notifications: "Create Notification",
    contacts: "Add Contact"
  };
  return labels[resource.key] ?? `Create ${resource.label}`;
}

function recordTitle(row: AdminRecord) {
  return row.title ?? row.fullName ?? row.name ?? row.question ?? row.email ?? row.topic ?? "Untitled record";
}

function recordSubtitle(row: AdminRecord) {
  if (row.job?.title) return `${row.job.title}${row.institution ? ` - ${row.institution}` : ""}`;
  if (row.organizationRole && row.email) return `${row.organizationRole} - ${row.email}`;
  return row.summary ?? row.description ?? row.email ?? row.company ?? row.institution ?? row.organizationRole ?? row.body ?? "";
}

function filterValueFor(row: AdminRecord, key: string) {
  if (key === "campus") return String(row.institution ?? row.name ?? row.job?.institution ?? "");
  if (key === "position") return String(row.organizationRole ?? "");
  if (key === "status") return String(row.status ?? (row.resolved ? "Resolved" : "Open"));
  if (key === "type") return String(row.type ?? "");
  if (key === "company") return String(row.company ?? row.job?.company ?? "");
  return String(row[key] ?? "");
}

function buildFilters(resource: Resource, rows: AdminRecord[]) {
  const keysByResource: Partial<Record<ResourceKey, { key: string; label: string }[]>> = {
    users: [{ key: "campus", label: "Campus / school" }, { key: "position", label: "Role" }, { key: "status", label: "Status" }],
    executives: [{ key: "campus", label: "Campus / school" }, { key: "position", label: "Position" }, { key: "status", label: "Status" }],
    chapters: [{ key: "campus", label: "Campus / school" }],
    news: [{ key: "status", label: "Status" }, { key: "category", label: "Category" }],
    events: [{ key: "status", label: "Status" }, { key: "venue", label: "Venue" }],
    announcements: [{ key: "status", label: "Status" }, { key: "priority", label: "Priority" }],
    jobs: [{ key: "status", label: "Status" }, { key: "type", label: "Type" }, { key: "company", label: "Company" }],
    jobApplications: [{ key: "status", label: "Stage" }, { key: "campus", label: "Campus / school" }],
    polls: [{ key: "status", label: "Status" }, { key: "visibility", label: "Visibility" }],
    conversations: [{ key: "isGroup", label: "Type" }],
    contacts: [{ key: "status", label: "Status" }]
  };

  return (keysByResource[resource.key] ?? [])
    .map((filter) => ({
      ...filter,
      options: Array.from(new Set(rows.map((row) => filterValueFor(row, filter.key)).filter(Boolean))).sort()
    }))
    .filter((filter) => filter.options.length > 0);
}

function StatusPill({ value }: { value: unknown }) {
  const label = value ? String(value) : "Open";
  const tone = statusTone(label);
  return <span className={`status-pill status-${tone}`}>{label}</span>;
}

function statusTone(value: string) {
  const normalized = value.toLowerCase();
  if (["published", "active", "resolved", "approved", "success"].includes(normalized)) return "success";
  if (["draft", "pending", "open"].includes(normalized)) return "warning";
  if (["archived", "suspended", "urgent", "failed"].includes(normalized)) return "danger";
  return "neutral";
}

function FieldInput({
  field,
  value,
  onChange
}: {
  field: Field;
  value: unknown;
  onChange: (value: unknown) => void;
}) {
  const [uploading, setUploading] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [uploadError, setUploadError] = useState("");
  const inputRef = useRef<HTMLInputElement | null>(null);

  async function uploadFile(file?: File) {
    if (!file) return;
    if (!file.type.startsWith("image/")) {
      setUploadError("Please choose an image file.");
      return;
    }

    setUploading(true);
    setUploadError("");
    try {
      const body = new FormData();
      body.append("file", file);
      const response = await apiFetch("/api/admin/uploads", { method: "POST", body });
      const data = await response.json() as { url?: string; message?: string };
      if (!response.ok) throw new Error(data.message ?? "Upload failed");
      if (!data.url) throw new Error("Upload did not return an image URL");
      onChange(data.url);
      if (inputRef.current) inputRef.current.value = "";
    } catch (error) {
      setUploadError(error instanceof Error ? error.message : "Upload failed");
    } finally {
      setUploading(false);
    }
  }

  async function uploadFiles(files?: FileList | File[]) {
    const selectedFiles = Array.from(files ?? []);
    if (!selectedFiles.length) return;
    if (selectedFiles.some((file) => !file.type.startsWith("image/"))) {
      setUploadError("Please choose image files only.");
      return;
    }

    setUploading(true);
    setUploadError("");
    try {
      const uploaded: string[] = [];
      for (const file of selectedFiles) {
        const body = new FormData();
        body.append("file", file);
        const response = await apiFetch("/api/admin/uploads", { method: "POST", body });
        const data = await response.json() as { url?: string; message?: string };
        if (!response.ok) throw new Error(data.message ?? "Upload failed");
        if (!data.url) throw new Error("Upload did not return an image URL");
        uploaded.push(data.url);
      }
      const current = Array.isArray(value) ? value.filter((item): item is string => typeof item === "string") : [];
      onChange([...current, ...uploaded].slice(0, 10));
      if (inputRef.current) inputRef.current.value = "";
    } catch (error) {
      setUploadError(error instanceof Error ? error.message : "Upload failed");
    } finally {
      setUploading(false);
    }
  }

  if (field.type === "image-list") {
    const images = Array.isArray(value) ? value.filter((item): item is string => typeof item === "string") : [];
    return (
      <div className="span-2 image-field">
        <span className="field-label">{field.label}</span>
        <div className="upload-card">
          <div
            className={`upload-dropzone ${isDragging ? "dragging" : ""} ${images.length ? "has-image" : ""}`}
            onDragEnter={(event) => {
              event.preventDefault();
              setIsDragging(true);
            }}
            onDragOver={(event) => event.preventDefault()}
            onDragLeave={() => setIsDragging(false)}
            onDrop={(event) => {
              event.preventDefault();
              setIsDragging(false);
              uploadFiles(event.dataTransfer.files);
            }}
          >
            <input
              ref={inputRef}
              type="file"
              multiple
              accept="image/png,image/jpeg,image/webp,image/gif"
              onChange={(event) => uploadFiles(event.target.files ?? undefined)}
            />

            {images.length ? (
              <div className="upload-gallery-preview">
                {images.map((image, index) => (
                  <div className="upload-gallery-item" key={`${image}-${index}`}>
                    <img src={resolveAssetUrl(image)} alt="" />
                    <button
                      type="button"
                      aria-label="Remove image"
                      onClick={() => onChange(images.filter((_, imageIndex) => imageIndex !== index))}
                    >
                      <X size={13} />
                    </button>
                  </div>
                ))}
              </div>
            ) : (
              <div className="upload-empty">
                <div className="upload-icon">
                  <ImageIcon size={34} />
                </div>
                <strong>
                  Drop images here, or{" "}
                  <button type="button" onClick={() => inputRef.current?.click()}>
                    browse
                  </button>
                </strong>
                <span>Upload up to 10 images. Supports JPG, JPEG, WEBP, GIF, PNG</span>
              </div>
            )}
          </div>

          <div className="upload-footer">
            <p>{uploading ? "Uploading..." : images.length ? `${images.length} image${images.length === 1 ? "" : "s"} selected` : "No images selected"}</p>
            <div className="upload-actions">
              <button type="button" onClick={() => inputRef.current?.click()}>
                <UploadCloud size={15} />
                Browse
              </button>
              {Boolean(images.length) && (
                <button
                  type="button"
                  className="danger"
                  onClick={() => {
                    onChange([]);
                    setUploadError("");
                    if (inputRef.current) inputRef.current.value = "";
                  }}
                >
                  <X size={15} />
                  Remove all
                </button>
              )}
            </div>
          </div>
          {uploadError && <p className="upload-error">{uploadError}</p>}
        </div>
      </div>
    );
  }

  if (field.type === "image") {
    const preview = resolveAssetUrl(typeof value === "string" ? value : undefined);
    return (
      <div className="span-2 image-field">
        <span className="field-label">{field.label}</span>
        <div className="upload-card">
          <div
            className={`upload-dropzone ${isDragging ? "dragging" : ""} ${preview ? "has-image" : ""}`}
            onDragEnter={(event) => {
              event.preventDefault();
              setIsDragging(true);
            }}
            onDragOver={(event) => event.preventDefault()}
            onDragLeave={() => setIsDragging(false)}
            onDrop={(event) => {
              event.preventDefault();
              setIsDragging(false);
              uploadFile(event.dataTransfer.files[0]);
            }}
          >
            <input
              ref={inputRef}
              type="file"
              accept="image/png,image/jpeg,image/webp,image/gif"
              onChange={(event) => uploadFile(event.target.files?.[0])}
            />

            {preview ? (
              <div className="upload-preview">
                <img src={preview} alt="" />
              </div>
            ) : (
              <div className="upload-empty">
                <div className="upload-icon">
                  <ImageIcon size={34} />
                </div>
                <strong>
                  Drop your image here, or{" "}
                  <button type="button" onClick={() => inputRef.current?.click()}>
                    browse
                  </button>
                </strong>
                <span>Supports: JPG, JPEG, WEBP, GIF, PNG</span>
              </div>
            )}
          </div>

          <div className="upload-footer">
            <p>{uploading ? "Uploading..." : value ? "Image selected" : "No image selected"}</p>
            <div className="upload-actions">
              <button type="button" onClick={() => inputRef.current?.click()}>
                <UploadCloud size={15} />
                Browse
              </button>
              {Boolean(value) && (
                <button
                  type="button"
                  className="danger"
                  onClick={() => {
                    onChange(null);
                    setUploadError("");
                    if (inputRef.current) inputRef.current.value = "";
                  }}
                >
                  <X size={15} />
                  Remove
                </button>
              )}
            </div>
          </div>
          {uploadError && <p className="upload-error">{uploadError}</p>}
        </div>
      </div>
    );
  }

  if (field.type === "textarea" || field.type === "lines") {
    return (
      <label className="span-2">
        {field.label}
        <textarea value={typeof value === "string" ? value : ""} onChange={(event) => onChange(event.target.value)} />
      </label>
    );
  }

  if (field.type === "select") {
    return (
      <label>
        {field.label}
        <select value={typeof value === "string" ? value : ""} onChange={(event) => onChange(event.target.value)}>
          <option value="">Select</option>
          {field.options?.map((option) => (
            typeof option === "string" ? (
              <option key={option} value={option}>{option}</option>
            ) : (
              <option key={option.value} value={option.value}>{option.label}</option>
            )
          ))}
        </select>
      </label>
    );
  }

  if (field.type === "datetime-local") {
    return (
      <DateTimeInput
        label={field.label}
        value={typeof value === "string" ? value : ""}
        onChange={onChange}
      />
    );
  }

  if (field.type === "checkbox") {
    return (
      <label className="checkbox">
        <input type="checkbox" checked={Boolean(value)} onChange={(event) => onChange(event.target.checked)} />
        {field.label}
      </label>
    );
  }

  return (
    <label>
      {field.label}
      <input
        type={field.type ?? "text"}
        value={typeof value === "string" || typeof value === "number" ? value : ""}
        onChange={(event) => onChange(event.target.value)}
      />
    </label>
  );
}

function DateTimeInput({
  label,
  value,
  onChange
}: {
  label: string;
  value: string;
  onChange: (value: unknown) => void;
}) {
  const [date = "", time = ""] = value.split("T");
  const [calendarOpen, setCalendarOpen] = useState(false);
  const [timeOpen, setTimeOpen] = useState(false);
  const [visibleMonth, setVisibleMonth] = useState(() => monthFromDateValue(date));
  const calendarDays = getCalendarDays(visibleMonth);
  const monthLabel = visibleMonth.toLocaleDateString(undefined, { month: "long", year: "numeric" });
  const [hour24, minute] = (time || "09:00").split(":");
  const hourNumber = Number(hour24 || "9");
  const period = hourNumber >= 12 ? "PM" : "AM";
  const hour12 = String(hourNumber % 12 || 12).padStart(2, "0");

  function update(nextDate: string, nextTime: string) {
    if (!nextDate && !nextTime) {
      onChange("");
      return;
    }

    if (!nextDate) {
      onChange("");
      return;
    }

    onChange(`${nextDate}T${nextTime || "09:00"}`);
  }

  function updateTimeParts(nextHour12: string, nextMinute: string, nextPeriod: string) {
    const normalizedHour = Number(nextHour12);
    const nextHour24 = nextPeriod === "PM"
      ? (normalizedHour % 12) + 12
      : normalizedHour % 12;
    update(date, `${String(nextHour24).padStart(2, "0")}:${nextMinute}`);
  }

  return (
    <div className="date-time-field">
      <span className="field-label">{label}</span>
      <div className="date-time-control">
        <div className="date-time-segment calendar-segment">
          <CalendarDays size={16} />
          <span>Date</span>
          <button
            type="button"
            className="calendar-trigger"
            onClick={() => {
              setVisibleMonth(monthFromDateValue(date));
              setCalendarOpen((current) => !current);
            }}
          >
            {date ? formatDateLabel(date) : "Select date"}
          </button>
          {calendarOpen && (
            <div className="calendar-popover">
              <div className="calendar-header">
                <button
                  type="button"
                  className="calendar-nav"
                  aria-label="Previous month"
                  onClick={() => setVisibleMonth((current) => addMonths(current, -1))}
                >
                  <ChevronLeft size={16} />
                </button>
                <strong>{monthLabel}</strong>
                <button
                  type="button"
                  className="calendar-nav"
                  aria-label="Next month"
                  onClick={() => setVisibleMonth((current) => addMonths(current, 1))}
                >
                  <ChevronRight size={16} />
                </button>
              </div>
              <div className="calendar-weekdays">
                {["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"].map((day) => <span key={day}>{day}</span>)}
              </div>
              <div className="calendar-grid">
                {calendarDays.map((day) => {
                  const dateValue = toDateValue(day.date);
                  const selected = dateValue === date;
                  const today = dateValue === toDateValue(new Date());
                  return (
                    <button
                      type="button"
                      key={dateValue}
                      className={[
                        "calendar-day",
                        day.currentMonth ? "" : "muted",
                        selected ? "selected" : "",
                        today ? "today" : ""
                      ].join(" ")}
                      onClick={() => {
                        update(dateValue, time);
                        setCalendarOpen(false);
                      }}
                    >
                      {day.date.getDate()}
                    </button>
                  );
                })}
              </div>
              <div className="calendar-actions">
                <button
                  type="button"
                  onClick={() => {
                    const today = toDateValue(new Date());
                    update(today, time);
                    setVisibleMonth(startOfMonth(new Date()));
                    setCalendarOpen(false);
                  }}
                >
                  Today
                </button>
              </div>
            </div>
          )}
        </div>
        <label className="date-time-segment">
          <Clock3 size={16} />
          <span>Time</span>
          <button type="button" className="time-trigger" onClick={() => setTimeOpen((current) => !current)}>
            {time ? formatTimeLabel(time) : "Select time"}
          </button>
          {timeOpen && (
            <div className="time-popover">
              <div className="time-columns">
                <label>
                  Hour
                  <select value={hour12} onChange={(event) => updateTimeParts(event.target.value, minute, period)}>
                    {Array.from({ length: 12 }, (_, index) => String(index + 1).padStart(2, "0")).map((option) => (
                      <option key={option} value={option}>{option}</option>
                    ))}
                  </select>
                </label>
                <label>
                  Minute
                  <select value={minute} onChange={(event) => updateTimeParts(hour12, event.target.value, period)}>
                    {["00", "15", "30", "45"].map((option) => (
                      <option key={option} value={option}>{option}</option>
                    ))}
                  </select>
                </label>
              </div>
              <div className="period-toggle">
                {["AM", "PM"].map((option) => (
                  <button
                    type="button"
                    key={option}
                    className={period === option ? "selected" : ""}
                    onClick={() => updateTimeParts(hour12, minute, option)}
                  >
                    {option}
                  </button>
                ))}
              </div>
              <div className="time-slots">
                {["08:00", "09:00", "12:00", "15:00", "18:00", "21:00"].map((slot) => (
                  <button
                    type="button"
                    key={slot}
                    className={slot === time ? "selected" : ""}
                    onClick={() => {
                      update(date, slot);
                      setTimeOpen(false);
                    }}
                  >
                    {formatTimeLabel(slot)}
                  </button>
                ))}
              </div>
            </div>
          )}
        </label>
        {value && (
          <button type="button" className="date-clear" aria-label={`Clear ${label}`} onClick={() => onChange("")}>
            <X size={15} />
          </button>
        )}
      </div>
    </div>
  );
}

function monthFromDateValue(value: string) {
  if (!value) return startOfMonth(new Date());
  const [year, month] = value.split("-").map(Number);
  if (!year || !month) return startOfMonth(new Date());
  return new Date(year, month - 1, 1);
}

function startOfMonth(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

function addMonths(date: Date, amount: number) {
  return new Date(date.getFullYear(), date.getMonth() + amount, 1);
}

function getCalendarDays(month: Date) {
  const firstDay = startOfMonth(month);
  const mondayOffset = (firstDay.getDay() + 6) % 7;
  const start = new Date(firstDay);
  start.setDate(firstDay.getDate() - mondayOffset);

  return Array.from({ length: 42 }, (_, index) => {
    const date = new Date(start);
    date.setDate(start.getDate() + index);
    return {
      date,
      currentMonth: date.getMonth() === month.getMonth()
    };
  });
}

function toDateValue(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function formatDateLabel(value: string) {
  const [year, month, day] = value.split("-").map(Number);
  if (!year || !month || !day) return "Select date";
  return new Date(year, month - 1, day).toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric"
  });
}

function formatTimeLabel(value: string) {
  const [hour, minute] = value.split(":").map(Number);
  if (Number.isNaN(hour) || Number.isNaN(minute)) return "Select time";
  return new Date(2000, 0, 1, hour, minute).toLocaleTimeString(undefined, {
    hour: "numeric",
    minute: "2-digit"
  });
}

function Thumbnail({ row }: { row: AdminRecord }) {
  const galleryImage = Array.isArray(row.imageUrls) ? row.imageUrls[0] : undefined;
  const source = resolveAssetUrl(galleryImage ?? row.imageUrl ?? row.logoUrl ?? row.avatarUrl);
  if (!source) {
    return <div className="thumbnail"><ImageIcon size={15} /></div>;
  }

  return (
    <div className="thumbnail">
      <img src={source} alt="" />
    </div>
  );
}

function resolveAssetUrl(value?: string) {
  if (!value) return "";
  return value.startsWith("/") ? `${API_URL}${value}` : value;
}

function normalizePayload(form: Record<string, unknown>, fields: Field[]) {
  return fields.reduce<Record<string, unknown>>((payload, field) => {
    const value = form[field.key];
    if (field.type === "image-list") {
      payload[field.key] = Array.isArray(value) ? value.filter((item) => typeof item === "string") : [];
      return payload;
    }
    if (field.type === "lines") {
      const items = typeof value === "string"
        ? Array.from(new Set(value.split(/\r?\n/).map((item) => item.trim()).filter(Boolean)))
        : [];
      if (items.length) payload[field.key] = items;
      return payload;
    }
    if (field.type === "image" && value === null) {
      payload[field.key] = null;
      return payload;
    }
    if (value === "" || value === undefined || value === null) return payload;
    payload[field.key] = field.type === "datetime-local" && typeof value === "string" ? new Date(value).toISOString() : value;
    return payload;
  }, {});
}

function defaultFormFor(resource: Resource) {
  if (resource.key === "polls") return { status: "PUBLISHED", options: "Yes\nNo" };
  return resource.key === "events" ? { status: "PUBLISHED" } : {};
}

function toEditableForm(row: AdminRecord, fields: Field[]) {
  return fields.reduce<Record<string, unknown>>((form, field) => {
    const value = row[field.key];
    if (field.type === "lines" && Array.isArray(value)) {
      form[field.key] = value
        .map((item) => {
          if (item && typeof item === "object" && "text" in item) return String((item as { text?: unknown }).text ?? "");
          return String(item ?? "");
        })
        .filter(Boolean)
        .join("\n");
    } else if (field.type === "datetime-local" && typeof value === "string") {
      form[field.key] = new Date(value).toISOString().slice(0, 16);
    } else if (field.key !== "password") {
      form[field.key] = value ?? "";
    }
    return form;
  }, {});
}

function formatDate(value?: string) {
  return value ? new Date(value).toLocaleDateString() : "-";
}

createRoot(document.getElementById("root")!).render(<App />);
