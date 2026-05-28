import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import {
  Bell,
  BriefcaseBusiness,
  CalendarDays,
  FileText,
  LogOut,
  Megaphone,
  MessageSquare,
  Newspaper,
  School,
  Send,
  Settings,
  Users
} from "lucide-react";
import "./styles.css";

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:4000";

async function apiFetch(path: string, init: RequestInit = {}, retrying = false) {
  const token = localStorage.getItem("tescon_admin_token");
  const response = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(init.headers ?? {})
    }
  });

  if (response.status === 401 && !retrying) {
    await refreshAdminSession();
    return apiFetch(path, init, true);
  }

  return response;
}

async function refreshAdminSession() {
  const refreshToken = localStorage.getItem("tescon_admin_refresh_token");
  if (!refreshToken) throw new Error("Session expired");

  const response = await fetch(`${API_URL}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken })
  });
  const data = await response.json();
  if (!response.ok) throw new Error(data.message ?? "Session expired");

  localStorage.setItem("tescon_admin_token", data.tokens.accessToken);
  localStorage.setItem("tescon_admin_refresh_token", data.tokens.refreshToken);
}

type Resource = {
  key: string;
  label: string;
  endpoint: string;
  icon: React.ReactNode;
  fields: Field[];
};

type Field = {
  key: string;
  label: string;
  type?: "text" | "textarea" | "datetime-local" | "select" | "password" | "checkbox";
  options?: string[];
};

const publishOptions = ["DRAFT", "PUBLISHED", "ARCHIVED"];

const resources: Resource[] = [
  {
    key: "users",
    label: "Members",
    endpoint: "users",
    icon: <Users size={18} />,
    fields: [
      { key: "fullName", label: "Full name" },
      { key: "email", label: "Email" },
      { key: "password", label: "Password", type: "password" },
      { key: "phone", label: "Phone" },
      { key: "institution", label: "Institution" },
      { key: "role", label: "Role", type: "select", options: ["USER", "ADMIN", "SUPER_ADMIN"] },
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
      { key: "description", label: "Description", type: "textarea" },
      { key: "logoUrl", label: "Logo URL" }
    ]
  },
  {
    key: "news",
    label: "News",
    endpoint: "news",
    icon: <Newspaper size={18} />,
    fields: contentFields(["category", "imageUrl", "publishedAt"])
  },
  {
    key: "events",
    label: "Events",
    endpoint: "events",
    icon: <CalendarDays size={18} />,
    fields: [
      { key: "title", label: "Title" },
      { key: "description", label: "Description", type: "textarea" },
      { key: "venue", label: "Venue" },
      { key: "startsAt", label: "Starts at", type: "datetime-local" },
      { key: "endsAt", label: "Ends at", type: "datetime-local" },
      { key: "imageUrl", label: "Image URL" },
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
      { key: "location", label: "Location" },
      { key: "type", label: "Type" },
      { key: "description", label: "Description", type: "textarea" },
      { key: "applyUrl", label: "Apply URL" },
      { key: "deadline", label: "Deadline", type: "datetime-local" },
      { key: "status", label: "Status", type: "select", options: publishOptions }
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
    imageUrl: { key: "imageUrl", label: "Image URL" },
    publishedAt: { key: "publishedAt", label: "Published at", type: "datetime-local" }
  };

  return [...base, ...extra.map((key) => extras[key])];
}

function App() {
  const [token, setToken] = useState(() => localStorage.getItem("tescon_admin_token") ?? "");
  const [activeKey, setActiveKey] = useState(resources[0].key);
  const active = useMemo(() => resources.find((item) => item.key === activeKey)!, [activeKey]);

  if (!token) {
    return <Login onLogin={setToken} />;
  }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-mark">T</div>
          <div>
            <strong>TESCON</strong>
            <span>Admin Panel</span>
          </div>
        </div>

        <nav>
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
          className="logout"
          onClick={() => {
            localStorage.removeItem("tescon_admin_token");
            localStorage.removeItem("tescon_admin_refresh_token");
            setToken("");
          }}
        >
          <LogOut size={18} />
          Logout
        </button>
      </aside>

      <main>
        <header className="topbar">
          <div>
            <p>Manage</p>
            <h1>{active.label}</h1>
          </div>
          <div className="api-pill">
            <Settings size={16} />
            {API_URL}
          </div>
        </header>
        <ResourceManager key={active.key} resource={active} token={token} />
      </main>
    </div>
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
        <div className="brand-mark">T</div>
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

function ResourceManager({ resource, token }: { resource: Resource; token: string }) {
  const [rows, setRows] = useState<any[]>([]);
  const [editing, setEditing] = useState<any | null>(null);
  const [form, setForm] = useState<Record<string, any>>({});
  const [status, setStatus] = useState("");

  useEffect(() => {
    load();
  }, [resource.key]);

  async function request(path = "", init?: RequestInit) {
    const response = await apiFetch(`/api/admin/${resource.endpoint}${path}`, {
      ...init,
    });
    if (response.status === 204) return null;
    const data = await response.json();
    if (!response.ok) throw new Error(data.message ?? "Request failed");
    return data;
  }

  async function load() {
    setStatus("Loading...");
    try {
      const data = await request();
      setRows(data.rows);
      setStatus("");
    } catch (error) {
      setStatus(error instanceof Error ? error.message : "Failed to load");
    }
  }

  async function save(event: React.FormEvent) {
    event.preventDefault();
    const payload = normalizePayload(form, resource.fields);
    try {
      if (editing) {
        await request(`/${editing.id}`, { method: "PATCH", body: JSON.stringify(payload) });
      } else {
        await request("", { method: "POST", body: JSON.stringify(payload) });
      }
      setEditing(null);
      setForm({});
      await load();
    } catch (error) {
      setStatus(error instanceof Error ? error.message : "Save failed");
    }
  }

  async function remove(id: string) {
    if (!confirm("Delete this record?")) return;
    await request(`/${id}`, { method: "DELETE" });
    await load();
  }

  function startEdit(row: any) {
    setEditing(row);
    setForm(toEditableForm(row, resource.fields));
  }

  return (
    <section className="workspace">
      <form className="editor" onSubmit={save}>
        <h2>{editing ? "Edit record" : "Create record"}</h2>
        <div className="field-grid">
          {resource.fields.map((field) => (
            <FieldInput
              key={field.key}
              field={field}
              value={form[field.key]}
              onChange={(value) => setForm((current) => ({ ...current, [field.key]: value }))}
            />
          ))}
        </div>
        {status && <p className="status">{status}</p>}
        <div className="actions">
          <button className="primary">{editing ? "Save changes" : "Create"}</button>
          {editing && (
            <button
              type="button"
              onClick={() => {
                setEditing(null);
                setForm({});
              }}
            >
              Cancel
            </button>
          )}
        </div>
      </form>

      <div className="table-panel">
        <div className="table-header">
          <h2>{resource.label}</h2>
          <button onClick={load}>Refresh</button>
        </div>
        <div className="table-scroll">
          <table>
            <thead>
              <tr>
                <th>Title / Name</th>
                <th>Status</th>
                <th>Updated</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.id}>
                  <td>
                    <strong>{row.title ?? row.fullName ?? row.name ?? row.question ?? row.email ?? row.topic}</strong>
                    <span>{row.summary ?? row.description ?? row.email ?? row.company ?? row.body}</span>
                  </td>
                  <td>{row.status ?? (row.resolved ? "Resolved" : "Open")}</td>
                  <td>{formatDate(row.updatedAt ?? row.createdAt)}</td>
                  <td className="row-actions">
                    <button onClick={() => startEdit(row)}>Edit</button>
                    <button onClick={() => remove(row.id)}>Delete</button>
                  </td>
                </tr>
              ))}
              {!rows.length && (
                <tr>
                  <td colSpan={4} className="empty">No records yet.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}

function FieldInput({ field, value, onChange }: { field: Field; value: any; onChange: (value: any) => void }) {
  if (field.type === "textarea") {
    return (
      <label className="span-2">
        {field.label}
        <textarea value={value ?? ""} onChange={(event) => onChange(event.target.value)} />
      </label>
    );
  }

  if (field.type === "select") {
    return (
      <label>
        {field.label}
        <select value={value ?? ""} onChange={(event) => onChange(event.target.value)}>
          <option value="">Select</option>
          {field.options?.map((option) => (
            <option key={option} value={option}>{option}</option>
          ))}
        </select>
      </label>
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
        value={value ?? ""}
        onChange={(event) => onChange(event.target.value)}
      />
    </label>
  );
}

function normalizePayload(form: Record<string, any>, fields: Field[]) {
  return fields.reduce<Record<string, any>>((payload, field) => {
    const value = form[field.key];
    if (value === "" || value === undefined || value === null) return payload;
    payload[field.key] = field.type === "datetime-local" ? new Date(value).toISOString() : value;
    return payload;
  }, {});
}

function toEditableForm(row: any, fields: Field[]) {
  return fields.reduce<Record<string, any>>((form, field) => {
    const value = row[field.key];
    if (field.type === "datetime-local" && value) {
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
