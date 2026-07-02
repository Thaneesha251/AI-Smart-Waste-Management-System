import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Navbar from '../components/Navbar';

const DashboardLayout = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true);

  return (
    <div className="app-layout">
      <Sidebar isOpen={sidebarOpen} />
      <div className={`main-content ${sidebarOpen ? 'sidebar-open' : 'sidebar-closed'}`}>
        <Navbar onMenuToggle={() => setSidebarOpen((prev) => !prev)} />
        <div className="page-content">
          <Outlet />
        </div>
      </div>
    </div>
  );
};

export default DashboardLayout;
