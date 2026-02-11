<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pomodoro Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
    <!-- Chart.js para o gráfico de histórico -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Google+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --md-sys-color-primary: #ba1a1a;
            --md-sys-color-on-primary: #ffffff;
            --md-sys-color-primary-container: #ffdad6;
            --md-sys-color-on-primary-container: #410002;
            --md-sys-color-surface: #fffbff;
            --md-sys-color-outline: #857371;
            --md-sys-color-surface-variant: #f5ddda;
        }

        body {
            font-family: 'Google Sans', sans-serif;
            background-color: transparent;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            color: #1f1b1b;
            overflow-x: hidden;
        }

        .card {
            background-color: var(--md-sys-color-surface);
            border-radius: 28px;
            padding: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            max-width: 400px;
            width: 90%;
            text-align: center;
            border: 1px solid var(--md-sys-color-surface-variant);
            position: relative;
            transition: transform 0.3s ease;
        }

        .tomato-container {
            width: 120px;
            height: 120px;
            margin: 0 auto 24px;
            position: relative;
        }

        .grid-pomodoros {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 12px;
            margin-bottom: 32px;
        }

        .checkbox-wrapper {
            position: relative;
            width: 100%;
            padding-top: 100%;
        }

        .checkbox-wrapper::before {
            content: attr(data-time);
            position: absolute;
            bottom: 110%;
            left: 50%;
            transform: translateX(-50%) translateY(5px);
            background: #410002;
            color: white;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 10px;
            white-space: nowrap;
            opacity: 0;
            visibility: hidden;
            transition: all 0.2s ease;
            z-index: 10;
            pointer-events: none;
        }

        .checkbox-wrapper:hover::before {
            opacity: 1;
            visibility: visible;
            transform: translateX(-50%) translateY(0);
        }

        .pomodoro-checkbox {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            appearance: none;
            border: 2px solid var(--md-sys-color-outline);
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .pomodoro-checkbox:hover {
            border-color: var(--md-sys-color-primary);
            background-color: var(--md-sys-color-primary-container);
            transform: translateY(-2px);
        }

        .pomodoro-checkbox:checked {
            background-color: var(--md-sys-color-primary);
            border-color: var(--md-sys-color-primary);
            transform: scale(0.95);
        }

        .pomodoro-checkbox::after {
            content: attr(data-index);
            font-size: 12px;
            font-weight: 700;
            color: var(--md-sys-color-outline);
        }

        .pomodoro-checkbox:checked::after {
            color: white;
        }

        .btn-complete {
            background-color: var(--md-sys-color-primary);
            color: var(--md-sys-color-on-primary);
            border-radius: 100px;
            padding: 16px 24px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            width: 100%;
            transition: all 0.2s;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .btn-complete:hover {
            box-shadow: 0 4px 12px rgba(186, 26, 26, 0.4);
            filter: brightness(1.1);
        }

        .btn-history {
            margin-top: 16px;
            background: none;
            border: none;
            color: var(--md-sys-color-outline);
            font-size: 14px;
            cursor: pointer;
            opacity: 0.8;
            transition: opacity 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            width: 100%;
        }
        
        .btn-history:hover {
            opacity: 1;
            text-decoration: underline;
        }

        /* Modal de Histórico */
        #history-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 100;
            padding: 20px;
        }

        .modal-content {
            background: var(--md-sys-color-surface);
            border-radius: 28px;
            width: 100%;
            max-width: 450px;
            max-height: 80vh;
            overflow-y: auto;
            padding: 24px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }

        .history-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--md-sys-color-surface-variant);
        }

        .weekend-text {
            color: var(--md-sys-color-outline);
            font-style: italic;
            font-size: 12px;
        }

        #tomato-fill {
            transition: height 0.6s cubic-bezier(0.34, 1.56, 0.64, 1), y 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .chart-container {
            margin-top: 20px;
            height: 200px;
        }
    </style>
</head>
<body>

    <div class="card" id="main-card">
        <h1 class="text-xl font-bold mb-1 text-gray-800">Foco Diário</h1>
        <p id="date-display" class="text-[10px] text-gray-400 mb-6 uppercase tracking-[0.2em] font-medium"></p>
        
        <div class="tomato-container">
            <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <clipPath id="tomato-clip">
                        <path d="M50 20 C30 20 15 35 15 55 C15 75 35 90 50 90 C65 90 85 75 85 55 C85 35 70 20 50 20 Z" />
                    </clipPath>
                </defs>
                <path d="M50 22 L45 10 L50 15 L55 10 L50 22 Z" fill="#2e7d32" stroke="#1b5e20" stroke-width="1"/>
                <path d="M50 22 L35 15 L45 18 Z" fill="#2e7d32" stroke="#1b5e20" stroke-width="1"/>
                <path d="M50 22 L65 15 L55 18 Z" fill="#2e7d32" stroke="#1b5e20" stroke-width="1"/>
                <path d="M50 20 C30 20 15 35 15 55 C15 75 35 90 50 90 C65 90 85 75 85 55 C85 35 70 20 50 20 Z" 
                      fill="none" stroke="#ba1a1a" stroke-width="3" />
                <rect id="tomato-fill" x="0" y="90" width="100" height="0" fill="#ba1a1a" clip-path="url(#tomato-clip)" />
            </svg>
        </div>

        <div class="grid-pomodoros" id="grid"></div>

        <button class="btn-complete" id="completeBtn">Completar Sessão</button>
        <button class="btn-history" id="viewHistoryBtn">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8.515 1.019A7 7 0 0 0 8 1V0a8 8 0 0 1 .589.022l-.074.997zm2.004.45a7.003 7.003 0 0 0-.985-.299l.219-.976c.383.086.76.2 1.126.342l-.36.933zm1.37.71a7.01 7.01 0 0 0-.439-.27l.493-.87a8.025 8.025 0 0 1 .979.654l-.615.789a6.996 6.996 0 0 0-.418-.302zm1.834 1.79a6.99 6.99 0 0 0-.653-.796l.724-.69c.27.285.52.59.747.91l-.818.576zm.744 1.352a7.08 7.08 0 0 0-.214-.468l.893-.45a7.976 7.976 0 0 1 .45 1.088l-.95.313a7.023 7.023 0 0 0-.179-.483zm.41 1.711a7.07 7.07 0 0 0-.045-.51l.98-.203c.04.195.07.394.09.596l-.993.05a7.02 7.02 0 0 0-.032-.443zM16 8h-1a7 7 0 0 0-.023.515l.997.074A8 8 0 0 1 16 8zM1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8zm7-5a.5.5 0 0 1 .5.5v3.793l1.354 1.353a.5.5 0 0 1-.708.708l-1.5-1.5A.5.5 0 0 1 7.5 6.5V3.5a.5.5 0 0 1 .5-.5z"/>
            </svg>
            Ver histórico
        </button>
    </div>

    <!-- Modal de Histórico -->
    <div id="history-modal">
        <div class="modal-content">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold">Histórico e Estatísticas</h2>
                <button id="closeHistoryBtn" class="text-gray-400 hover:text-gray-600">✕</button>
            </div>
            
            <div class="chart-container">
                <canvas id="historyChart"></canvas>
            </div>

            <div id="history-list" class="mt-6">
                <!-- Lista de dias será injetada aqui -->
            </div>
        </div>
    </div>

    <script>
        const totalPomodoros = 15;
        const grid = document.getElementById('grid');
        const fill = document.getElementById('tomato-fill');
        const completeBtn = document.getElementById('completeBtn');
        const dateDisplay = document.getElementById('date-display');
        const viewHistoryBtn = document.getElementById('viewHistoryBtn');
        const closeHistoryBtn = document.getElementById('closeHistoryBtn');
        const historyModal = document.getElementById('history-modal');
        const historyList = document.getElementById('history-list');
        
        const suggestedTimes = [
            "09:00", "09:30", "10:00", "10:30", "11:15",
            "11:45", "12:15", "12:45", "14:00", "14:30",
            "15:00", "15:30", "16:00", "16:30", "Extra"
        ];

        let state = JSON.parse(localStorage.getItem('pomodoro_state')) || Array(totalPomodoros).fill(false);
        let history = JSON.parse(localStorage.getItem('pomodoro_history_v2')) || {};

        function getTodayString() {
            const now = new Date();
            return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
        }

        function checkDailyReset() {
            const today = getTodayString();
            const lastDate = localStorage.getItem('pomodoro_date');
            
            if (lastDate && lastDate !== today) {
                // Antes de resetar, salva o estado do dia anterior no histórico se houver progresso
                const completedCount = state.filter(v => v).length;
                if (completedCount > 0 || lastDate) {
                    history[lastDate] = completedCount;
                    localStorage.setItem('pomodoro_history_v2', JSON.stringify(history));
                }
                
                state = Array(totalPomodoros).fill(false);
                save();
            }
            localStorage.setItem('pomodoro_date', today);
        }

        function init() {
            checkDailyReset();
            
            const options = { weekday: 'long', day: 'numeric', month: 'long' };
            dateDisplay.innerText = new Date().toLocaleDateString('pt-BR', options);

            grid.innerHTML = '';
            state.forEach((checked, i) => {
                const wrapper = document.createElement('div');
                wrapper.className = 'checkbox-wrapper';
                wrapper.setAttribute('data-time', suggestedTimes[i]);
                
                const cb = document.createElement('input');
                cb.type = 'checkbox';
                cb.className = 'pomodoro-checkbox';
                cb.checked = checked;
                cb.dataset.index = i + 1;
                cb.onclick = (e) => {
                    togglePomodoro(i);
                    if (cb.checked) triggerConfetti();
                };
                
                wrapper.appendChild(cb);
                grid.appendChild(wrapper);
            });
            updateTomato();
        }

        function togglePomodoro(index) {
            state[index] = !state[index];
            save();
            updateTomato();
            
            // Atualiza o histórico em tempo real para o dia atual
            const today = getTodayString();
            history[today] = state.filter(v => v).length;
            localStorage.setItem('pomodoro_history_v2', JSON.stringify(history));
        }

        function updateTomato() {
            const completedCount = state.filter(v => v).length;
            const percentage = completedCount / totalPomodoros;
            const fillHeight = percentage * 70;
            const newY = 90 - fillHeight;
            
            fill.setAttribute('height', fillHeight);
            fill.setAttribute('y', newY);
        }

        function save() {
            localStorage.setItem('pomodoro_state', JSON.stringify(state));
            localStorage.setItem('pomodoro_date', getTodayString());
        }

        function triggerConfetti() {
            confetti({
                particleCount: 80,
                spread: 60,
                origin: { y: 0.7 },
                colors: ['#ba1a1a', '#ffdad6', '#2e7d32']
            });
        }

        function isWeekend(dateStr) {
            const date = new Date(dateStr + 'T12:00:00'); // T12:00 para evitar problemas de fuso
            return date.getDay() === 0 || date.getDay() === 6;
        }

        function renderHistory() {
            historyList.innerHTML = '';
            const dates = Object.keys(history).sort().reverse();
            
            if (dates.length === 0) {
                historyList.innerHTML = '<p class="text-center text-gray-400 py-4">Nenhum registro ainda.</p>';
                return;
            }

            dates.forEach(date => {
                const count = history[date];
                const item = document.createElement('div');
                item.className = 'history-item';
                
                const dateObj = new Date(date + 'T12:00:00');
                const formattedDate = dateObj.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
                const dayName = dateObj.toLocaleDateString('pt-BR', { weekday: 'short' });

                const infoDiv = document.createElement('div');
                infoDiv.innerHTML = `<span class="font-medium">${formattedDate}</span> <span class="text-xs text-gray-400 ml-1">(${dayName})</span>`;
                
                const valueDiv = document.createElement('div');
                if (isWeekend(date)) {
                    valueDiv.className = 'weekend-text';
                    valueDiv.innerText = 'Final de semana';
                } else {
                    valueDiv.className = 'text-sm font-bold text-red-700';
                    valueDiv.innerText = `${count} pomodoros`;
                }

                item.appendChild(infoDiv);
                item.appendChild(valueDiv);
                historyList.appendChild(item);
            });

            renderChart(dates.slice(0, 7).reverse());
        }

        let chartInstance = null;
        function renderChart(recentDates) {
            const ctx = document.getElementById('historyChart').getContext('2d');
            
            if (chartInstance) chartInstance.destroy();

            const labels = recentDates.map(d => {
                const parts = d.split('-');
                return `${parts[2]}/${parts[1]}`;
            });
            const data = recentDates.map(d => history[d]);

            chartInstance = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Pomodoros',
                        data: data,
                        backgroundColor: '#ba1a1a',
                        borderRadius: 8,
                        barThickness: 20
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true, max: 15, ticks: { stepSize: 3 } },
                        x: { grid: { display: false } }
                    },
                    plugins: { legend: { display: false } }
                }
            });
        }

        completeBtn.onclick = () => {
            const nextIndex = state.findIndex(v => v === false);
            if (nextIndex !== -1) {
                state[nextIndex] = true;
                save();
                init();
                triggerConfetti();
                
                // Atualiza histórico
                const today = getTodayString();
                history[today] = state.filter(v => v).length;
                localStorage.setItem('pomodoro_history_v2', JSON.stringify(history));
            }
        };

        viewHistoryBtn.onclick = () => {
            renderHistory();
            historyModal.style.display = 'flex';
        };

        closeHistoryBtn.onclick = () => {
            historyModal.style.display = 'none';
        };

        window.onclick = (event) => {
            if (event.target == historyModal) historyModal.style.display = 'none';
        };

        setInterval(checkDailyReset, 60000);
        init();
    </script>
</body>
</html>
