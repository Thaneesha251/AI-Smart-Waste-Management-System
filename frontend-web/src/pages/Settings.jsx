import { Bell, Palette, Shield, User } from 'lucide-react';
import { useState } from 'react';
import '../styles/Pages.css';

const tabs = [
  { id: 'account', label: 'Account Profile', icon: User },
  { id: 'system', label: 'System Preferences', icon: Palette },
  { id: 'notifications', label: 'Notification Rules', icon: Bell },
  { id: 'security', label: 'Security', icon: Shield }
];

const Settings = () => {
  const [activeTab, setActiveTab] = useState('system');
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState({ name: 'Admin Officer', department: 'Municipality', email: 'admin@smartwaste.gov' });

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Settings</h2>
          <p className="header-subtitle">Configure the admin dashboard experience.</p>
        </div>
        <button className="primary-btn" onClick={handleSave}>{saved ? 'Saved!' : 'Save Changes'}</button>
      </div>
      <div className="settings-layout">
        <div className="settings-nav">
          {tabs.map(({ id, label, icon: Icon }) => (
            <button key={id} className={`settings-nav-item ${activeTab === id ? 'active' : ''}`} onClick={() => setActiveTab(id)}>
              <Icon size={16} />
              <span>{label}</span>
            </button>
          ))}
        </div>
        <div className="settings-content panel-card">
          {activeTab === 'system' && (
            <>
              <div className="toggle-wrapper">
                <div>
                  <h3>Auto-Assign Complaints</h3>
                  <p>Automatically route new issues to available workers.</p>
                </div>
                <label className="toggle-switch">
                  <input type="checkbox" defaultChecked />
                  <span className="slider" />
                </label>
              </div>
              <div className="toggle-wrapper">
                <div>
                  <h3>Dark Mode Dashboard</h3>
                  <p>Enable dark styling across analytics dashboards.</p>
                </div>
                <label className="toggle-switch">
                  <input type="checkbox" defaultChecked />
                  <span className="slider" />
                </label>
              </div>
              <div className="field-group">
                <label>Map Latitude Default</label>
                <input className="settings-input" defaultValue="11.0168" />
              </div>
              <div className="field-group">
                <label>Map Longitude Default</label>
                <input className="settings-input" defaultValue="76.9558" />
              </div>
            </>
          )}
          {activeTab === 'account' && (
            <>
              <div className="field-group">
                <label>Full Name</label>
                <input className="settings-input" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
              </div>
              <div className="field-group">
                <label>Department</label>
                <input className="settings-input" value={form.department} disabled />
              </div>
              <div className="field-group">
                <label>Email</label>
                <input className="settings-input" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
              </div>
            </>
          )}
          {(activeTab === 'notifications' || activeTab === 'security') && (
            <div className="empty-state">Advanced configurations coming soon.</div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Settings;
