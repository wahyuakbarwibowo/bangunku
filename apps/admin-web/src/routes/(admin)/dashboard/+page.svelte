<script lang="ts">
	const stats = [
		{ label: 'Total Pengguna', value: '—' },
		{ label: 'Pengguna Aktif', value: '—' },
		{ label: 'Total Proyek', value: '—' },
		{ label: 'Proyek Aktif', value: '—' },
		{ label: 'Langganan Aktif', value: '—' },
		{ label: 'MRR', value: '—' }
	];
</script>

<h1 class="text-2xl font-bold text-slate-900">Dashboard</h1>
<p class="mt-1 text-base text-slate-500">
	Ringkasan platform. Data live tersambung pada Fase 1c.
</p>

<div class="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
	{#each stats as stat (stat.label)}
		<div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
			<p class="text-sm font-medium text-slate-500">{stat.label}</p>
			<p class="mt-2 text-3xl font-bold text-slate-900">{stat.value}</p>
		</div>
	{/each}
</div>
