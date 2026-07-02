import { useEffect, useState } from 'react';
import { AlertTriangle, BarChart3, CheckCircle2, ClipboardList, Users } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import DashboardCard from '../components/DashboardCard';
import RecentComplaints from '../components/RecentComplaints';
import StatisticsChart from '../components/StatisticsChart';
import DistributionChart from '../components/DistributionChart';
import BottomStats from '../components/BottomStats';
import { getSummary } from '../services/statsService';

const Dashboard = () => {
  const { user } = useAuth();
  const [summary, setSummary] = useState({});

  useEffect(() => {
    const load = async () => {
      const data = await getSummary();
      setSummary(data);
    };
    load();
  }, []);

  const cards = [
    { icon: ClipboardList, label: 'Total Complaints', value: summary.total_complaints || 0, sublabel: 'All registered issues', accentColor: '#2563eb', bgColor: '#dbeafe' },
    { icon: AlertTriangle, label: 'Pending Complaints', value: summary.pending || 0, sublabel: 'Needs attention', accentColor: '#f59e0b', bgColor: '#fef3c7' },
    { icon: CheckCircle2, label: 'Resolved Complaints', value: summary.resolved || 0, sublabel: 'Completed successfully', accentColor: '#16a34a', bgColor: '#dcfce7' },
    { icon: Users, label: 'Active Workers', value: summary.active_workers || 0, sublabel: 'On field duty', accentColor: '#7c3aed', bgColor: '#ede9fe' },
    { icon: AlertTriangle, label: 'Emergency Alerts', value: summary.emergency_alerts || 0, sublabel: 'Critical incidents', accentColor: '#dc2626', bgColor: '#fee2e2' }
  ];

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Welcome back, {user?.name || 'Admin Officer'}</h2>
          <p className="header-subtitle">Here is the live summary of your waste management operations.</p>
        </div>
      </div>
      <div className="cards-grid">
        {cards.map((card) => (
          <DashboardCard key={card.label} {...card} />
        ))}
      </div>
      <div className="dashboard-main-grid">
        <RecentComplaints />
        <div className="right-stack">
          <StatisticsChart />
          <DistributionChart />
        </div>
      </div>
      <BottomStats />
    </div>
  );
};

export default Dashboard;
