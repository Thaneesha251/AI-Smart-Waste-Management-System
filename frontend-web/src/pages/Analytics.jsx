import { useEffect, useState } from 'react';
import { Bar, BarChart, CartesianGrid, Cell, Legend, Line, LineChart, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { getMonthlyStats, getZoneStats } from '../services/statsService';

const Analytics = () => {
  const [monthly, setMonthly] = useState([]);
  const [zoneData, setZoneData] = useState([]);

  useEffect(() => {
    const load = async () => {
      const monthlyData = await getMonthlyStats();
      const zoneResult = await getZoneStats();
      setMonthly(monthlyData);
      setZoneData(zoneResult);
    };
    load();
  }, []);

  const trend = monthly.map((item) => ({
    month: item.month,
    rate: Math.round((item.resolved / item.complaints) * 100)
  }));

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Analytics</h2>
          <p className="header-subtitle">System performance and trends.</p>
        </div>
      </div>
      <div className="analytics-grid">
        <div className="panel-card wide-card">
          <h3>Monthly Complaints vs Resolved</h3>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={monthly}>
              <CartesianGrid stroke="#e2e8f0" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="complaints" fill="#3b82f6" />
              <Bar dataKey="resolved" fill="#22c55e" />
            </BarChart>
          </ResponsiveContainer>
        </div>
        <div className="panel-card">
          <h3>Complaints by Zone</h3>
          <ResponsiveContainer width="100%" height={260}>
            <PieChart>
              <Pie data={zoneData} dataKey="value" nameKey="zone" outerRadius={80} label>
                {zoneData.map((entry, index) => (
                  <Cell key={`${entry.zone}-${index}`} fill={['#2563eb', '#22c55e', '#f59e0b', '#8b5cf6', '#ef4444'][index % 5]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
        <div className="panel-card">
          <h3>Resolution Rate Trend</h3>
          <ResponsiveContainer width="100%" height={260}>
            <LineChart data={trend}>
              <CartesianGrid stroke="#e2e8f0" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="rate" stroke="#22c55e" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

export default Analytics;
