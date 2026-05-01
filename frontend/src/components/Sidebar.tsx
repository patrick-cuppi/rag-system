"use client";

import {
  CheckCircle2,
  FileText,
  Loader2,
  LogOut,
  MessageSquare,
  MessageSquarePlus,
  Sparkles,
  Upload,
} from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { getConversations, logout, uploadDocument, getTaskStatus } from "../services/api";

type SidebarProps = {
  activeConversationId: number | null;
  onSelectConversation: (id: number | null) => void;
};

type Conversation = {
  id: number;
  title: string;
  created_at: string;
};

export default function Sidebar({
  activeConversationId,
  onSelectConversation,
}: SidebarProps) {
  const [uploading, setUploading] = useState(false);
  const [uploadSuccess, setUploadSuccess] = useState<string | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const fetchConversations = async () => {
    try {
      const data = await getConversations();
      setConversations(data);
    } catch (error) {
      console.error("Failed to fetch conversations:", error);
    }
  };

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    fetchConversations();
    // In a real app we'd want to poll or use websockets,
    // but here we just fetch on mount and let ChatArea trigger updates if needed
  }, [activeConversationId]);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Frontend file size validation (5MB limit)
    const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    if (file.size > MAX_FILE_SIZE) {
      alert("File is too large. Maximum size allowed is 5MB.");
      if (fileInputRef.current) fileInputRef.current.value = "";
      return;
    }

    setUploading(true);
    setUploadSuccess(null);

    try {
      const { task_id } = await uploadDocument(file);
      
      // Poll for status
      const checkStatus = setInterval(async () => {
        try {
          const taskData = await getTaskStatus(task_id);
          if (taskData.status === 'COMPLETED') {
            clearInterval(checkStatus);
            setUploading(false);
            setUploadSuccess(`Successfully processed ${file.name}`);
            setTimeout(() => setUploadSuccess(null), 5000);
            if (fileInputRef.current) fileInputRef.current.value = "";
          } else if (taskData.status === 'FAILED') {
            clearInterval(checkStatus);
            setUploading(false);
            console.error("Upload failed in worker:", taskData.error_message);
            alert("Error processing file: " + (taskData.error_message || "Unknown error"));
            if (fileInputRef.current) fileInputRef.current.value = "";
          }
        } catch (err) {
          console.error("Error polling task status:", err);
          clearInterval(checkStatus);
          setUploading(false);
        }
      }, 2000); // Check every 2 seconds

    } catch (error) {
      console.error("Upload error:", error);
      const errorMessage = error instanceof Error ? error.message : "Please try again.";
      alert(`Error uploading file: ${errorMessage}`);
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  return (
    <aside className="w-80 border-r border-white/10 bg-[#09090b]/80 backdrop-blur-xl flex flex-col z-10 hidden md:flex">
      <div className="p-6 border-b border-white/10 flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg shadow-indigo-500/20 shrink-0">
          <Sparkles className="w-5 h-5 text-white" />
        </div>
        <div>
          <h1 className="font-bold text-lg tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-white to-white/70">
            Ask me
          </h1>
          <p className="text-xs text-white/50 font-medium">Knowledge System</p>
        </div>
      </div>

      <div className="flex-1 flex flex-col gap-6 overflow-hidden">
        {/* Upload Section */}
        <div className="px-6 pt-6 shrink-0">
          <h2 className="text-xs font-bold text-white/40 uppercase tracking-wider mb-4">
            Data Sources
          </h2>

          <div
            onClick={() => fileInputRef.current?.click()}
            className="group relative overflow-hidden rounded-2xl border border-white/10 bg-white/5 p-4 hover:bg-white/10 hover:border-indigo-500/50 transition-all cursor-pointer duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/10 to-purple-600/10 opacity-0 group-hover:opacity-100 transition-opacity" />
            <div className="flex flex-col items-center justify-center gap-2 text-center relative z-10">
              {uploading ? (
                <Loader2 className="w-6 h-6 text-indigo-400 animate-spin" />
              ) : (
                <Upload className="w-6 h-6 text-white/60 group-hover:text-indigo-400 transition-colors" />
              )}
              <div>
                <p className="font-medium text-sm text-white/90">
                  {uploading ? "Processing..." : "Upload Document"}
                </p>
              </div>
            </div>
          </div>

          <input
            type="file"
            ref={fileInputRef}
            className="hidden"
            accept=".pdf,.txt,.csv"
            onChange={handleFileUpload}
          />

          {uploadSuccess && (
            <div className="mt-3 p-2.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center gap-2 text-emerald-400 text-xs animate-in fade-in slide-in-from-top-2">
              <CheckCircle2 className="w-4 h-4 shrink-0" />
              <span className="truncate">{uploadSuccess}</span>
            </div>
          )}
        </div>

        {/* Conversations Section */}
        <div className="px-6 flex-1 flex flex-col min-h-0">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xs font-bold text-white/40 uppercase tracking-wider">
              Recent Chats
            </h2>
            <button
              onClick={() => onSelectConversation(null)}
              className="p-1.5 hover:bg-white/10 rounded-lg transition-colors text-white/60 hover:text-white"
              title="New Chat"
            >
              <MessageSquarePlus className="w-4 h-4" />
            </button>
          </div>

          <div className="flex-1 overflow-y-auto pr-2 -mr-2 space-y-1 scrollbar-thin scrollbar-thumb-white/10 scrollbar-track-transparent">
            {conversations.length === 0 ? (
              <p className="text-xs text-white/30 text-center py-4">
                No recent chats
              </p>
            ) : (
              conversations.map((conv) => (
                <button
                  key={conv.id}
                  onClick={() => onSelectConversation(conv.id)}
                  className={`w-full flex items-center gap-3 p-3 rounded-xl transition-all text-left group ${
                    activeConversationId === conv.id
                      ? "bg-indigo-500/10 border border-indigo-500/30 text-white"
                      : "border border-transparent text-white/60 hover:bg-white/5 hover:text-white/90"
                  }`}
                >
                  <MessageSquare
                    className={`w-4 h-4 shrink-0 ${activeConversationId === conv.id ? "text-indigo-400" : "group-hover:text-white/80"}`}
                  />
                  <span className="text-sm truncate">{conv.title}</span>
                </button>
              ))
            )}
          </div>
        </div>

        {/* Footer Section */}
        <div className="px-6 pb-6 shrink-0 flex flex-col gap-3">
          <div className="p-4 rounded-xl bg-white/5 border border-white/10 flex items-center gap-3">
            <FileText className="w-5 h-5 text-white/40" />
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-white/90 truncate">
                Pinecone DB
              </p>
              <p className="text-xs text-white/50">Connected</p>
            </div>
            <div className="w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]"></div>
          </div>

          <button
            onClick={logout}
            className="flex items-center gap-2 p-4 rounded-xl text-white/70 hover:text-red-400 hover:bg-red-500/10 transition-colors border border-transparent hover:border-red-500/20"
          >
            <LogOut className="w-5 h-5" />
            <span className="text-sm font-medium">Sign Out</span>
          </button>
        </div>
      </div>
    </aside>
  );
}
