import { Bell, Palette, Shield, User } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useSettings } from '../context/SettingsContext';
import { getMyProfile, updateMyProfile } from '../services/userService';
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
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ name: '', department: 'Municipality', email: '' });
  const { darkMode, setDarkMode, autoAssign, setAutoAssign } = useSettings();

  useEffect(() => {
    const loadProfile = async () => {
      try {
        const profile = await getMyProfile();
        setForm({
          name: profile.name || '',
          department: 'Municipality',
          email: profile.email || ''
        });

        if (profile.theme_preference === 'dark') {
          setDarkMode(true);
        } else {
          setDarkMode(false);
        }
      } catch (err) {
        setError('Unable to load your profile right now.');
      }
    };

    loadProfile();
  }, [setDarkMode]);

  const handleSave = async () => {
    if (activeTab !== 'account') {
      return;
    }

    setSaving(true);
    setError('');

    try {
      await updateMyProfile({ name: form.name, email: form.email });
      setSaved(true);
      setError('');
    } catch (err) {
      setSaved(false);
      setError(err?.response?.data?.message || 'Unable to save your profile.');
    } finally {
      setSaving(false);
    }
  };

  const handleDarkModeChange = async (checked) => {
    setDarkMode(checked);
    try {
      await updateMyProfile({ theme_preference: checked ? 'dark' : 'light' });
      setError('');
    } catch (err) {
      setError(err?.response?.data?.message || 'Unable to save your theme preference.');
    }
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Settings</h2>
          <p className="header-subtitle">Configure the admin dashboard experience.</p>
        </div>
        <button className="primary-btn" onClick={handleSave} disabled={saving || activeTab !== 'account'}>
          {saving ? 'Saving...' : saved ? 'Saved!' : 'Save Changes'}
        </button>
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
                  <input type="checkbox" checked={autoAssign} onChange={(e) => setAutoAssign(e.target.checked)} />
                  <span className="slider" />
                </label>
              </div>
              <div className="toggle-wrapper">
                <div>
                  <h3>Dark Mode Dashboard</h3>
                  <p>Enable dark styling across analytics dashboards.</p>
                </div>
                <label className="toggle-switch">
                  <input type="checkbox" checked={darkMode} onChange={(e) => handleDarkModeChange(e.target.checked)} />
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
              {error && <div className="empty-state" style={{ marginBottom: '12px', color: '#b91c1c' }}>{error}</div>}
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
