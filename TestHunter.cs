using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using ReBot.API;
using System;
using System.IO;
using System.Net;
// Based on the work of Sleeper.

namespace ReBot
{
	[Rotation("BestMaster", "Jizar", WoWClass.Hunter, Specialization.HunterBeastMastery, 40)]
	public class BestMaster: CombatRotation
	{
		public enum MDtyp
	{
		NoMisdirection ,
		MisdirectionOnPetGlyphed ,
		MisdirectionOnPet ,
		MisdirectionOnFocus , 
	}
	
		public enum PetTyp
	{
			PetSlot1 ,
			PetSlot2 ,
			PetSlot3 ,
			PetSlot4 ,
			PetSlot5 ,
	}
		public enum UsePetOrLWtyp
	{
			UsePet ,
			NoPet ,
			
	}
	
	/// Basic options
		[JsonProperty("Use your Pet?"), JsonConverter(typeof(StringEnumConverter))]							
		public  UsePetOrLWtyp UsePetOrLWopt = UsePetOrLWtyp.UsePet;
		[JsonProperty("If Use Pet: which Pet Slot"), JsonConverter(typeof(StringEnumConverter))]							
		public PetTyp PetOpt = PetTyp.PetSlot1;
		
	/// Advanced options
		[JsonProperty("Use Tranquilizing Shot")]
        public bool UseTranqShot { get; set; }
		
		[JsonProperty("Use Camouflage")]
        public bool Camo { get; set; }
		
		[JsonProperty("Use Intimidation")]
        public bool Intimidation { get; set; }
		
		[JsonProperty("Use Deterrence")]
        public bool Deterrence { get; set; }
		
		[JsonProperty("Use Aspect of Cheetah not in combat")]
        public bool Cheetah { get; set; }

	/// MD options
		[JsonProperty("Misdirection"), JsonConverter(typeof(StringEnumConverter))]							
		public MDtyp MDopt = MDtyp.NoMisdirection;
		
	
		public BestMaster()
        {
            Version CurrentVersion = new Version("1.0");
			using (WebClient client = new WebClient())
			{
				Version latest = new Version(client.DownloadString("https://raw.githubusercontent.com/lucas224900/BoL/master/TestUpdate.txt"));
				if (CurrentVersion > latest)
                {
                    System.IO.File.WriteAllText("C:/Users/Lucas J Loveless/Downloads/ReBot/CombatRotations/Default/Hunter/TestHunter.cs", client.DownloadString("https://raw.githubusercontent.com/lucas224900/BoL/master/TestHunter.cs"));
                    return;
                }
			}

			PullSpells = new string[]
			{
				"Concussive Shot",
				"Arcane Shot",
			};
		}


		public override bool OutOfCombat()
		{
						
			CastSelf("Trap Launcher", () => !HasAura("Trap Launcher"));

			//Camouflage
			if (Camo)
			{
				CastSelf("Camouflage", () => !HasAura("Camouflage")); 
			}
			
			if (Cheetah)
			{
				if (CastSelf("Aspect of the Cheetah", () => Me.MovementSpeed != 0 && !Me.IsSwimming && Me.DisplayId == Me.NativeDisplayId && Me.DistanceTo(API.GetNaviTarget()) > 20)) return true;
			}
		
            if (UsePetOrLWopt == UsePetOrLWtyp.UsePet)
            {
			    if (!Me.HasAlivePet)
                {
                   if (CastSelfPreventDouble("Call Pet 1", () => Me.Pet == null && PetOpt == PetTyp.PetSlot1, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 2", () => Me.Pet == null && PetOpt == PetTyp.PetSlot2, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 3", () => Me.Pet == null && PetOpt == PetTyp.PetSlot3, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 4", () => Me.Pet == null && PetOpt == PetTyp.PetSlot4, 5000)) return true;
                   if (CastSelfPreventDouble("Call Pet 5", () => Me.Pet == null && PetOpt == PetTyp.PetSlot5, 5000)) return true;
                   if (CastSelfPreventDouble("Revive Pet", null, 2000)) return true;
				   return true;
			    }
            }
            else if (Me.HasAlivePet)
            {
                if (CastSelfPreventDouble("Dismiss Pet", null,3000)) return true;
            }

			if (CastSelf("Mend Pet", () => Me.HasAlivePet && Me.Pet.HealthFraction <= 0.8 && !Me.Pet.HasAura("Mend Pet"))) return true;

			return false;
		}

		public override void Combat()
		{
		
			if (CastPreventDouble("Misdirection", () => Me.HasAlivePet && MDopt == MDtyp.MisdirectionOnPetGlyphed,Me.Pet, 8000)) return;
			if (CastPreventDouble("Misdirection", () => Me.HasAlivePet && MDopt == MDtyp.MisdirectionOnPet,Me.Pet, 30000)) return;
			if (CastPreventDouble("Misdirection", () => Me.HasAlivePet && MDopt == MDtyp.MisdirectionOnFocus,Me.Focus, 30000)) return;
			
			if (Cheetah) {
			if (CancelAura("Aspect of the Cheetah")); }
			
            Cast("Counter Shot", () => Target.IsCastingAndInterruptible());
			if (UseTranqShot) 
			{	
				if (Cast("Tranquilizing Shot", () => Target.Auras.Any(x => x.IsStealable))) return;
			}
						
			

			if (UsePetOrLWopt == UsePetOrLWtyp.UsePet)
            {		
				if (Me.HasAlivePet)
				{
					if (CastSelfPreventDouble("Mend Pet", () => Me.HasAlivePet && Me.Pet.HealthFraction <= 0.8, 9000)) return;
					if (CastSelfPreventDouble("Last Stand", () => Me.HasAlivePet && Me.Pet.HealthFraction <= 0.3, 9000)) return;
					if (CastSelfPreventDouble("Roar of Sacrifice", () => Me.HasAlivePet && Me.HealthFraction <= 0.3, 9000)) return;
					
					UnitObject add = Adds.FirstOrDefault(x => x.Target == Me);
					
					if (add != null)
					Me.PetAttack(add);
					
					if(Intimidation)
					{		
						if (Cast("Intimidation")) return; 
					}
					
					if (Cast("Bestial Wrath")) return;

					
			
				}
		/// Focus Fire with 5 Stacks of Frenzy.
					if (CastSelf("Focus Fire", () => HasAura("Frenzy", false, 5))) return;

		/// Healing Abilities
				if (HasSpell("Exhilaration"))
				{
					CastSelf("Exhilaration", () => Me.HealthFraction <= 0.3); 
				}
			
		/// Out of CC
				if (CastSelf("Master's Call", () => !Me.CanParticipateInCombat)) return;
			
				if (!Me.HasAlivePet)
				{
					if (CastSelfPreventDouble("Call Pet 1", () => Me.Pet == null && PetOpt == PetTyp.PetSlot1, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 2", () => Me.Pet == null && PetOpt == PetTyp.PetSlot2, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 3", () => Me.Pet == null && PetOpt == PetTyp.PetSlot3, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 4", () => Me.Pet == null && PetOpt == PetTyp.PetSlot4, 5000)) return;
					if (CastSelfPreventDouble("Call Pet 5", () => Me.Pet == null && PetOpt == PetTyp.PetSlot5, 5000)) return;
					if (CastSelf("Heart of the Phoenix")) return;
					if (CastSelfPreventDouble("Revive Pet", null, 10000)) return;
				}
			}
			else if (Me.HasAlivePet)
            {
                if (CastSelfPreventDouble("Dismiss Pet", null,3000)) return;
            }
			
		/// Self Protection
			if(Deterrence)
			{
				if (CastSelfPreventDouble("Deterrence", () => Me.HealthFraction <= 0.5));
				if (CastSelfPreventDouble("Deterrence", () => Me.HealthFraction <= 0.25));
			}	
			
			if (CastSelf("Exhilaration", () => Me.HealthFraction <= 0.3));
			if (CastSelfPreventDouble("Feign Death", () => Me.HealthFraction <= 0.20));
			
		/// Single Rotation
			if (HasSpell("Poisoned Ammo"))
			{
				if (CastSelfPreventDouble("Poisoned Ammo", () => !HasAura("Poisoned Ammo"))) return;
			}
			
			if (Cast("Dire Beast")) return;
			if (Cast("A Murder of Crows")) return;
			if (CastSelf("Stampede")) return;
			if (Cast("Kill Shot", () => Target.HealthFraction < 0.2)) return;
			if (Cast("Kill Command", () => Me.GetPower(WoWPowerType.Focus) >= 40)) return;
			if (Cast("Barrage")) return;
			if (Cast("Glaive Toss")) return;
			if (Cast("Arcane Shot", () => Me.GetPower(WoWPowerType.Focus) >= 20 && HasAura("Thrill of the Hunt"))) return;
			if (Cast("Arcane Shot", () => Me.GetPower(WoWPowerType.Focus) >= 35)) return;
			if (Cast("Powershot")) return;
			if (Cast("Cobra Shot")) return;	
			
			

			int addsInRange = Adds.Count(x => x.DistanceSquared <= 10 * 10);
		
		/// AOE 
			if (Adds.Count >= 3)
			{
				if (HasSpell("Incendiary Ammo"))
				{
					if (CastSelfPreventDouble("Incendiary Ammo", () => !HasAura("Incendiary Ammo"))) return;
				}
				
				if (Cast("Multi-Shot", () => Me.GetPower(WoWPowerType.Focus) >= 20 && HasAura("Thrill of the Hunt"))) return;
				if (Cast("Multi-Shot", () => Me.GetPower(WoWPowerType.Focus) >= 40)) return;
				if (Cast("Kill Command", () => Me.GetPower(WoWPowerType.Focus) >= 40)) return;
				if (Cast("Barrage", () => Me.GetPower(WoWPowerType.Focus) >= 60)) return;
				if (Cast("Glaive Toss")) return;
				if (CastOnTerrain("Explosive Trap", Target.Position, () => HasAura("Trap Launcher"))) return;
				if (Cast("Cobra Shot")) return;
				if (Cast("Powershot")) return;
			}
            
		
		}
	}
}
