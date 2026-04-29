"use client";

import { useState, useRef } from 'react';
import { Upload, Loader2, Sparkles, CheckCircle2, FileText, LogOut } from 'lucide-react';
import { uploadDocument, logout } from '../services/api';

export default function Sidebar() {
  const [uploading, setUploading] = useState(false);
  const [uploadSuccess, setUploadSuccess] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    setUploadSuccess(null);

    try {
      await uploadDocument(file);
      setUploadSuccess(`Successfully processed ${file.name}`);
      setTimeout(() => setUploadSuccess(null), 5000);
    } catch (error) {
      console.error('Upload error:', error);
      alert('Error uploading file. Please try again.');
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  return (
    <aside className="w-80 border-r border-white/10 bg-[#09090b]/80 backdrop-blur-xl flex flex-col z-10 hidden md:flex">
      <div className="p-6 border-b border-white/10 flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg shadow-indigo-500/20">
          <Sparkles className="w-5 h-5 text-white" />
        </div>
        <div>
          <h1 className="font-bold text-lg tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-white to-white/70">Ask me</h1>
          <p className="text-xs text-white/50 font-medium">Knowledge System</p>
        </div>
      </div>

      <div className="p-6 flex-1 flex flex-col gap-6">
        <div>
          <h2 className="text-xs font-bold text-white/40 uppercase tracking-wider mb-4">Data Sources</h2>
          
          <div 
            onClick={() => fileInputRef.current?.click()}
            className="group relative overflow-hidden rounded-2xl border border-white/10 bg-white/5 p-6 hover:bg-white/10 hover:border-indigo-500/50 transition-all cursor-pointer duration-300"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/10 to-purple-600/10 opacity-0 group-hover:opacity-100 transition-opacity" />
            <div className="flex flex-col items-center justify-center gap-3 text-center relative z-10">
              {uploading ? (
                <Loader2 className="w-8 h-8 text-indigo-400 animate-spin" />
              ) : (
                <Upload className="w-8 h-8 text-white/60 group-hover:text-indigo-400 transition-colors" />
              )}
              <div>
                <p className="font-medium text-sm text-white/90">
                  {uploading ? 'Processing...' : 'Upload Document'}
                </p>
                <p className="text-xs text-white/50 mt-1">PDF, TXT, CSV up to 10MB</p>
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
            <div className="mt-4 p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center gap-2 text-emerald-400 text-sm animate-in fade-in slide-in-from-top-2">
              <CheckCircle2 className="w-4 h-4 shrink-0" />
              <span className="truncate">{uploadSuccess}</span>
            </div>
          )}
        </div>
        
        <div className="mt-auto flex flex-col gap-3">
          <div className="p-4 rounded-xl bg-white/5 border border-white/10 flex items-center gap-3">
            <FileText className="w-5 h-5 text-white/40" />
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-white/90 truncate">Pinecone Vector DB</p>
              <p className="text-xs text-white/50">Connected & Ready</p>
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
