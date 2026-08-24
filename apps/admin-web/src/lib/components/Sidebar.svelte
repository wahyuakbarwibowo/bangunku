<script lang="ts">
	const menu = [
		{ group: 'Umum', items: [{ label: 'Dashboard', href: '/dashboard' }] },
		{
			group: 'Pengguna',
			items: [
				{ label: 'Pengguna', href: '/users' },
				{ label: 'Organisasi', href: '/organizations' },
				{ label: 'Proyek', href: '/projects' }
			]
		},
		{
			group: 'Langganan',
			items: [
				{ label: 'Langganan', href: '/subscriptions' },
				{ label: 'Paket', href: '/plans' },
				{ label: 'Pembayaran', href: '/payments' }
			]
		},
		{
			group: 'Sistem',
			items: [
				{ label: 'Notifikasi', href: '/notifications' },
				{ label: 'Log Audit', href: '/audit-logs' },
				{ label: 'Pengaturan', href: '/settings' }
			]
		}
	];
</script>

<aside class="w-64 shrink-0 border-r border-slate-200 bg-white">
	<div class="flex h-16 items-center px-6">
		<span class="text-xl font-bold text-primary-700">BangunKu</span>
	</div>
	<nav class="space-y-6 px-4 pb-8">
		{#each menu as section (section.group)}
			<div>
				<p class="px-3 pb-2 text-xs font-semibold uppercase tracking-wider text-slate-400">
					{section.group}
				</p>
				<ul class="space-y-1">
					{#each section.items as item (item.href)}
						<li>
							<a
								href={item.href}
								class="block rounded-lg px-3 py-2.5 text-base font-medium text-slate-600 hover:bg-primary-50 hover:text-primary-700"
							>
								{item.label}
							</a>
						</li>
					{/each}
				</ul>
			</div>
		{/each}
	</nav>
</aside>
