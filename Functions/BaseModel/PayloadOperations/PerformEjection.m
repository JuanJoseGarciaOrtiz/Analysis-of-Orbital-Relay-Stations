function v_f = PerformEjection(m_station,m_payload,v_i,v_payload)
%Calculates final velocity of station after succesfully ejecting the payload at
%velocity v_paylaod
v_f = ((m_station + m_payload)*v_i - m_payload*v_payload)/m_station;
end